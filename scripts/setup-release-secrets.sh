#!/usr/bin/env bash
set -euo pipefail

# Configure release secrets for the scratchpad GitHub Actions pipeline.
# Usage examples:
#   export MACOS_SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)'
#   export MACOS_SIGNING_IDENTITY_NAME="$MACOS_SIGNING_IDENTITY"
#   export MACOS_SIGNING_CERT_P12_FILE=./Developer-ID.p12
#   export MACOS_KEYCHAIN_PASSWORD=...
#   export MACOS_SIGNING_CERT_PASSWORD=...
#   export MACOS_DEVELOPER_ID_PROFILE_FILE=./scratchpad-developer-id.mobileprovision
#   export NOTARY_KEY_ID=...
#   export NOTARY_ISSUER_ID=...
#   export NOTARY_KEY_P8_FILE=./AuthKey_XXXX.p8
#   scripts/setup-release-secrets.sh
#
# Optional (Apple ID notarization path, use instead of API key):
#   export NOTARY_APPLE_ID=...
#   export NOTARY_TEAM_ID=...
#   export NOTARY_PASSWORD=...
# Or run:
#   scripts/setup-release-secrets.sh --bootstrap scripts/release-secrets.env
# then fill in values and:
#   source scripts/release-secrets.env
#   bash scripts/setup-release-secrets.sh

if [[ "${1:-}" == "--bootstrap" ]]; then
  OUTPUT_FILE="${2:-scripts/release-secrets.env}"
  cat > "$OUTPUT_FILE" <<'EOF'
# Fill these values with your own release credentials.
# Keep this file private and never commit it.

export REPO="euforicio/scratchpad"

# Required signing inputs
export MACOS_SIGNING_IDENTITY=""
export MACOS_SIGNING_CERT_P12_FILE=""
export MACOS_KEYCHAIN_PASSWORD=""
export MACOS_SIGNING_CERT_PASSWORD=""
export MACOS_DEVELOPER_ID_PROFILE_FILE=""

# API-key notarization (recommended)
# export NOTARY_KEY_ID=""
# export NOTARY_ISSUER_ID=""
# export NOTARY_KEY_P8_FILE=""

# Or Apple ID notarization
# export NOTARY_APPLE_ID=""
# export NOTARY_TEAM_ID=""
# export NOTARY_PASSWORD=""
EOF
  chmod 600 "$OUTPUT_FILE"
  echo "Created bootstrap env file: $OUTPUT_FILE"
  echo "Fill every required value, then run:"
  echo "  source $OUTPUT_FILE"
  echo "  bash scripts/setup-release-secrets.sh"
  echo "Do not commit this file."
  exit 0
fi

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  sed -n '1,120p' "$0" | sed -n '1,120p'
  exit 0
fi

REPO="${REPO:-euforicio/scratchpad}"

required_env=(
  MACOS_SIGNING_IDENTITY
  MACOS_SIGNING_CERT_P12_FILE
  MACOS_KEYCHAIN_PASSWORD
  MACOS_SIGNING_CERT_PASSWORD
  MACOS_DEVELOPER_ID_PROFILE_FILE
)

for name in "${required_env[@]}"; do
  if [[ -z "${!name:-}" ]]; then
    echo "ERROR: missing required variable $name"
    echo "Set all required variables before running: ${required_env[*]}"
    exit 1
  fi
done

if [[ ! -f "${MACOS_SIGNING_CERT_P12_FILE}" ]]; then
  echo "ERROR: MACOS_SIGNING_CERT_P12_FILE not found: ${MACOS_SIGNING_CERT_P12_FILE}"
  exit 1
fi

if [[ ! -f "${MACOS_DEVELOPER_ID_PROFILE_FILE}" ]]; then
  echo "ERROR: MACOS_DEVELOPER_ID_PROFILE_FILE not found: ${MACOS_DEVELOPER_ID_PROFILE_FILE}"
  exit 1
fi

encode_file_base64() {
  local file="$1"
  if command -v base64 >/dev/null 2>&1; then
    base64 -i "$file"
  else
    openssl base64 -in "$file" -A
  fi
}

MACOS_SIGNING_CERT_P12="$(encode_file_base64 "${MACOS_SIGNING_CERT_P12_FILE}")"
MACOS_DEVELOPER_ID_PROFILE="$(encode_file_base64 "${MACOS_DEVELOPER_ID_PROFILE_FILE}")"

gh secret set MACOS_SIGNING_IDENTITY --repo "$REPO" --body "${MACOS_SIGNING_IDENTITY}"
echo "Set MACOS_SIGNING_IDENTITY"

gh secret set MACOS_SIGNING_CERT_P12 --repo "$REPO" --body "$MACOS_SIGNING_CERT_P12"
echo "Set MACOS_SIGNING_CERT_P12"

gh secret set MACOS_KEYCHAIN_PASSWORD --repo "$REPO" --body "${MACOS_KEYCHAIN_PASSWORD}"
echo "Set MACOS_KEYCHAIN_PASSWORD"

gh secret set MACOS_SIGNING_CERT_PASSWORD --repo "$REPO" --body "${MACOS_SIGNING_CERT_PASSWORD}"
echo "Set MACOS_SIGNING_CERT_PASSWORD"

gh secret set MACOS_DEVELOPER_ID_PROFILE --repo "$REPO" --body "$MACOS_DEVELOPER_ID_PROFILE"
echo "Set MACOS_DEVELOPER_ID_PROFILE"

if [[ -n "${NOTARY_KEY_ID:-}" && -n "${NOTARY_ISSUER_ID:-}" && -n "${NOTARY_KEY_P8_FILE:-}" ]]; then
  if [[ ! -f "${NOTARY_KEY_P8_FILE}" ]]; then
    echo "ERROR: NOTARY_KEY_P8_FILE not found: ${NOTARY_KEY_P8_FILE}"
    exit 1
  fi
  NOTARY_KEY_P8="$(encode_file_base64 "${NOTARY_KEY_P8_FILE}")"
  gh secret set NOTARY_KEY_ID --repo "$REPO" --body "${NOTARY_KEY_ID}"
  gh secret set NOTARY_ISSUER_ID --repo "$REPO" --body "${NOTARY_ISSUER_ID}"
  gh secret set NOTARY_KEY_P8 --repo "$REPO" --body "$NOTARY_KEY_P8"
  echo "Set API-key notarization secrets (NOTARY_KEY_ID/ISSUER_ID/KEY_P8)"
  # Optional cleanup for Apple ID path
  gh secret delete NOTARY_APPLE_ID --repo "$REPO" >/dev/null 2>&1 || true
  gh secret delete NOTARY_TEAM_ID --repo "$REPO" >/dev/null 2>&1 || true
  gh secret delete NOTARY_PASSWORD --repo "$REPO" >/dev/null 2>&1 || true
elif [[ -n "${NOTARY_APPLE_ID:-}" && -n "${NOTARY_TEAM_ID:-}" && -n "${NOTARY_PASSWORD:-}" ]]; then
  gh secret set NOTARY_APPLE_ID --repo "$REPO" --body "${NOTARY_APPLE_ID}"
  gh secret set NOTARY_TEAM_ID --repo "$REPO" --body "${NOTARY_TEAM_ID}"
  gh secret set NOTARY_PASSWORD --repo "$REPO" --body "${NOTARY_PASSWORD}"
  echo "Set Apple-ID notarization secrets (NOTARY_APPLE_ID/TEAM_ID/PASSWORD)"
  # Optional cleanup for API-key path
  gh secret delete NOTARY_KEY_ID --repo "$REPO" >/dev/null 2>&1 || true
  gh secret delete NOTARY_ISSUER_ID --repo "$REPO" >/dev/null 2>&1 || true
  gh secret delete NOTARY_KEY_P8 --repo "$REPO" >/dev/null 2>&1 || true
else
  echo "ERROR: provide either API key secrets (NOTARY_KEY_ID/NOTARY_ISSUER_ID/NOTARY_KEY_P8_FILE)"
  echo "or Apple ID secrets (NOTARY_APPLE_ID/NOTARY_TEAM_ID/NOTARY_PASSWORD)."
  exit 1
fi

echo "All requested release secrets configured for ${REPO}."
