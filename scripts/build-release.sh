#!/bin/bash
set -e

# Configuration
APP_NAME="Scratchpad"
VERSION="${SCRATCHPAD_DMG_VERSION:-$(grep 'MARKETING_VERSION:' project.yml | grep -v CFBundle | sed 's/.*: *\"\(.*\)\"/\1/')}"
TEAM_ID="${TEAM_ID:-$(grep -m1 'DEVELOPMENT_TEAM:' project.yml | sed 's/.*: *\"\(.*\)\"/\1/')}"
BUNDLE_ID="${BUNDLE_ID:-$(grep -m1 'PRODUCT_BUNDLE_IDENTIFIER:' project.yml | sed 's/.*: *\"\(.*\)\"/\1/')}"
SIGNING_IDENTITY="${SIGNING_IDENTITY:-${MACOS_SIGNING_IDENTITY:-}}"

if [ -z "$TEAM_ID" ]; then
    echo "ERROR: TEAM_ID is not set and could not be detected from project.yml."
    echo "Set TEAM_ID or PRODUCT_BUNDLE_IDENTIFIER/DEVELOPMENT_TEAM in project.yml."
    exit 1
fi

if [ -z "$BUNDLE_ID" ]; then
    echo "ERROR: BUNDLE_ID is not set and could not be detected from project.yml."
    echo "Set BUNDLE_ID or PRODUCT_BUNDLE_IDENTIFIER in project.yml."
    exit 1
fi

if [ -z "$SIGNING_IDENTITY" ]; then
    echo "ERROR: SIGNING_IDENTITY is required."
    echo "Set SIGNING_IDENTITY to the exact Developer ID Application identity from Keychain."
    echo "Example: Developer ID Application: \"Your Name (TEAMID)\""
    exit 1
fi

# Paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PROJECT_DIR/dist"
ARCHIVE_PATH="$DIST_DIR/scratchpad.xcarchive"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
DMG_PATH="$DIST_DIR/$APP_NAME-$VERSION.dmg"

# Notarization (required to avoid Gatekeeper quarantine warnings)
SKIP_NOTARIZATION="${SKIP_NOTARIZATION:-0}"
REQUIRE_NOTARIZATION="${REQUIRE_NOTARIZATION:-1}"
NOTARY_APPLE_ID="${NOTARY_APPLE_ID:-}"
NOTARY_TEAM_ID="${NOTARY_TEAM_ID:-$TEAM_ID}"
NOTARY_PASSWORD="${NOTARY_PASSWORD:-}"
NOTARY_KEY_ID="${NOTARY_KEY_ID:-}"
NOTARY_ISSUER_ID="${NOTARY_ISSUER_ID:-}"
NOTARY_KEY_PATH="${NOTARY_KEY_PATH:-}"

cd "$PROJECT_DIR"
mkdir -p "$DIST_DIR"

echo "==> Version: $VERSION"

# Find Developer ID provisioning profile
PROFILE_PATH=$(
  find ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles \
    \( -name "*.mobileprovision" -o -name "*.provisionprofile" \) \
    -exec sh -c 'security cms -D -i "$1" 2>/dev/null | grep -q "Developer ID Application" && echo "$1"' _ {} \;
)
if [ -z "$PROFILE_PATH" ]; then
    echo "ERROR: 'Developer ID Application' provisioning profile not found."
    echo "Download it from developer.apple.com and double-click to install."
    exit 1
fi
echo "==> Profile: $PROFILE_PATH"
if ! security find-identity -v -p codesigning | grep -q "\"$SIGNING_IDENTITY\""; then
    echo "ERROR: Signing identity not found in keychain: $SIGNING_IDENTITY"
    echo "Install/import your Developer ID Application certificate or set SIGNING_IDENTITY to an installed identity."
    exit 1
fi

# Generate Xcode project from project.yml
echo "==> Generating Xcode project..."
xcodegen generate

# Archive without signing (avoids profile conflicts with dependencies)
echo "==> Archiving..."
xcodebuild -scheme scratchpad -configuration Release \
    -destination 'generic/platform=macOS' \
    -archivePath "$ARCHIVE_PATH" \
    archive \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    -quiet

ARCHIVE_APP="$ARCHIVE_PATH/Products/Applications/Scratchpad.app"

# Embed provisioning profile
echo "==> Embedding provisioning profile..."
cp "$PROFILE_PATH" "$ARCHIVE_APP/Contents/embedded.provisionprofile"

# Sign frameworks and dylibs first
echo "==> Signing with Developer ID..."
find "$ARCHIVE_APP" \( -name "*.framework" -o -name "*.dylib" \) | while read -r item; do
    codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$item"
done

# Create resolved entitlements (Xcode variables aren't available during manual signing)
# Also inject application-identifier, team-identifier, and keychain-access-groups
# which Xcode adds automatically but manual codesign does not. Without these,
# CloudKit fails with CKError.missingEntitlement (code 8).
RESOLVED_ENTITLEMENTS="$DIST_DIR/scratchpad-resolved.entitlements"
KEYCHAIN_ACCESS_GROUP="${TEAM_ID}.${BUNDLE_ID}"
sed -e "s|\\\$(TeamIdentifierPrefix)|${TEAM_ID}.|g" \
    -e "s|\\\$(CFBundleIdentifier)|${BUNDLE_ID}|g" \
    "$PROJECT_DIR/Sources/scratchpad-direct.entitlements" > "$RESOLVED_ENTITLEMENTS"

# Inject entitlements that Xcode normally adds during signing
sed -i '' 's|</dict>|    <key>com.apple.application-identifier</key>\
    <string>'"${TEAM_ID}"'.'"${BUNDLE_ID}"'</string>\
    <key>com.apple.developer.team-identifier</key>\
    <string>'"${TEAM_ID}"'</string>\
    <key>keychain-access-groups</key>\
    <array>\
        <string>'"${KEYCHAIN_ACCESS_GROUP}"'</string>\
    </array>\
</dict>|' "$RESOLVED_ENTITLEMENTS"

# Sign the app bundle with resolved entitlements
codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" \
    --entitlements "$RESOLVED_ENTITLEMENTS" \
    "$ARCHIVE_APP"
rm "$RESOLVED_ENTITLEMENTS"

# Extract signed app
echo "==> Extracting app bundle..."
rm -rf "$APP_BUNDLE"
cp -R "$ARCHIVE_APP" "$APP_BUNDLE"
rm -rf "$ARCHIVE_PATH"

# Verify
echo "==> Checking architectures..."
lipo -info "$APP_BUNDLE/Contents/MacOS/Scratchpad"

echo "==> Verifying signature..."
codesign --verify --deep --strict --verbose=1 "$APP_BUNDLE"

# Create DMG
echo "==> Creating DMG..."
rm -f "$DMG_PATH"
DMG_STAGING="$DIST_DIR/dmg-staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
cp -R "$APP_BUNDLE" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_PATH"
rm -rf "$DMG_STAGING"

echo "==> Signing DMG..."
codesign --force --sign "$SIGNING_IDENTITY" "$DMG_PATH"
codesign --verify --strict --verbose=1 "$DMG_PATH"

if [[ "$SKIP_NOTARIZATION" == "1" ]]; then
    echo "==> Skipping notarization (SKIP_NOTARIZATION=1)"
else
    if [[ -n "$NOTARY_KEY_ID" && -n "$NOTARY_ISSUER_ID" && -n "$NOTARY_KEY_PATH" ]]; then
        echo "==> Submitting DMG for notarization (API key authentication)..."
        xcrun notarytool submit "$DMG_PATH" \
            --key "$NOTARY_KEY_PATH" \
            --key-id "$NOTARY_KEY_ID" \
            --issuer "$NOTARY_ISSUER_ID" \
            --wait
    elif [[ -n "$NOTARY_APPLE_ID" && -n "$NOTARY_TEAM_ID" && -n "$NOTARY_PASSWORD" ]]; then
        echo "==> Submitting DMG for notarization (Apple ID authentication)..."
        xcrun notarytool submit "$DMG_PATH" \
            --apple-id "$NOTARY_APPLE_ID" \
            --team-id "$NOTARY_TEAM_ID" \
            --password "$NOTARY_PASSWORD" \
            --wait
    elif [[ "$REQUIRE_NOTARIZATION" == "1" ]]; then
        echo "ERROR: Notarization requested but credentials are missing. Set NOTARY_KEY_ID/NOTARY_ISSUER_ID/NOTARY_KEY_PATH or NOTARY_APPLE_ID/NOTARY_TEAM_ID/NOTARY_PASSWORD."
        exit 1
    else
        echo "WARN: Notarization skipped. Set NOTARY_* env vars or set REQUIRE_NOTARIZATION=1 to fail without it."
    fi

    if [[ "$NOTARY_KEY_ID" != "" || "$NOTARY_APPLE_ID" != "" ]]; then
        echo "==> Stapling notarization ticket to DMG..."
        xcrun stapler staple "$DMG_PATH"
        xcrun stapler validate "$DMG_PATH"
    fi
fi

SHA256=$(shasum -a 256 "$DMG_PATH" | cut -d' ' -f1)

echo ""
echo "==> Build complete!"
echo "    App: $APP_BUNDLE"
echo "    DMG: $DMG_PATH"
echo "    SHA256: $SHA256"
echo ""
if [[ "$SKIP_NOTARIZATION" == "1" ]] || [[ "$NOTARY_KEY_ID" == "" && "$NOTARY_APPLE_ID" == "" ]]; then
    echo "To notarize (recommended):"
    echo "    SKIP_NOTARIZATION=0 NOTARY_APPLE_ID=... NOTARY_TEAM_ID=... NOTARY_PASSWORD=... bash scripts/build-release.sh"
    echo "    or"
    echo "    SKIP_NOTARIZATION=0 NOTARY_KEY_ID=... NOTARY_ISSUER_ID=... NOTARY_KEY_PATH=... bash scripts/build-release.sh"
else
    echo "DMG was notarized and stapled during this build."
fi
echo ""
echo "To create a GitHub release:"
echo "    gh release create v$VERSION \"$DMG_PATH\" --title \"v$VERSION\" --generate-notes"
echo ""
echo "To update Homebrew tap (after notarizing and uploading to GitHub):"
echo "    1. Get SHA256 of the NOTARIZED DMG: shasum -a 256 \"$DMG_PATH\""
echo "    2. Update Casks/scratchpad.rb in homebrew-tap with version \"$VERSION\" and new sha256"
echo "    3. Commit and push the tap"
