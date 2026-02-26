# Scratchpad

[![Tests](https://github.com/euforicio/scratchpad/actions/workflows/tests.yml/badge.svg)](https://github.com/euforicio/scratchpad/actions/workflows/tests.yml)
[![Release](https://img.shields.io/github/v/release/euforicio/scratchpad)](https://github.com/euforicio/scratchpad/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/euforicio/scratchpad/total)](https://github.com/euforicio/scratchpad/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Swift 5.9](https://img.shields.io/badge/swift-5.9-orange.svg)](https://swift.org)
[![macOS 14+](https://img.shields.io/badge/macOS-14%2B-brightgreen.svg)](https://www.apple.com/macos/sonoma/)
[![Homebrew](https://img.shields.io/badge/homebrew-tap-yellow.svg)](https://github.com/euforicio/homebrew-taps)

A tiny, fast scratchpad and clipboard manager for Mac. [scratchpad.euforic.io](https://scratchpad.euforic.io)

![Scratchpad screenshot](scratchpad-screenshot-v2.png)

❤️ You can download Scratchpad from [GitHub releases](https://github.com/euforicio/scratchpad/releases) or install via Homebrew.

## Features

- **Text editor** — syntax highlighting, multi-tab, split view, find and replace, clickable links, lists and checklists
- **Clipboard manager** — 1,000-item history, searchable, keyboard navigable, grid or panels layout, iCloud sync (text entries)
- **Global hotkeys** — tap left ⌥ three times to show/hide, or define your own hotkey
- **Lightweight** — nearly zero CPU and memory usage
- **No AI, no telemetry** — your data stays on your machine
- **Menu bar icon** — show or hide in menu bar
- **Dock icon** — show or hide in Dock, as you prefer
- **Open at login** — optional auto-start
- **iCloud sync** — sync scratch tabs and clipboard history (text only) across Macs via iCloud
- **12 languages** — English, Spanish, French, German, Russian, Japanese, Simplified Chinese, Traditional Chinese, Korean, Portuguese (Brazil), Italian, Polish

## Editor
- **Multi-tab and split view** — work on multiple files/notes at once, drag to reorder, pin tabs to keep them visible (tab bar by [Bonsplit](https://github.com/almonk/bonsplit))
- **Syntax highlighting** — 185+ languages via [highlight.js](https://highlightjs.org), with automatic language detection
- **Find and replace** — built-in find bar with next/previous match and use selection for find
- **Session persistence** — all tabs, content, and cursor positions are preserved across restarts
- **Auto-save** — content is continuously saved to session, never lose your work
- **Markdown preview** — side-by-side rendered preview for `.md` tabs (⇧⌘P), live-updates as you type, themed code blocks, local images
- **Clickable links** — URLs in plain text and markdown tabs are highlighted and underlined; click to open in browser
- **Always on top** — pin the window above all other apps (⇧⌘T)
- **Syntax themes** — 9 curated themes (Atom One, Catppuccin, GitHub, Gruvbox, IntelliJ / Darcula, Scratchpad, Stack Overflow, Tokyo Night, Visual Studio) with dark and light variants
- **Vim mode** — opt-in libvim-powered editing with status bar command feedback

### Vim mode

Enable in **Settings → Editor → Enable Vim mode**.

- Vim editing is backed by `libvim` and keeps the text model in sync with the main editor.
- Normal and insert flows are supported, including special keys such as Escape, Enter, Tab, arrows, page up/down, Home/End, Delete, and ctrl-combinations.
- Command-mode text is surfaced in the editor status line while typing `:` commands.
- `:w`, `:q`, `:x`, `:wq`, `:qa`, `:wqall`, and related variants are wired to app behavior (save, close current/all tabs, etc.).
- Vim mode can be toggled at any time and the setting is persisted in app preferences.

## Lists and checklists

Scratchpad supports markdown-compatible lists and checklists directly in the editor. All state lives in the text itself — no hidden metadata, fully portable.

### Syntax

```
- bullet item
* also a bullet
1. numbered item
- [ ] unchecked task
- [x] completed task
```

### How it works

Type a list prefix and start writing. Press **Enter** to auto-continue with the next item. Press **Enter** on an empty item to exit list mode. Use **Tab** / **Shift+Tab** to indent and outdent list items.

For checklists, press **⇧⌘L** to convert any line(s) to a checklist, or type `- [ ] ` manually. Toggle checkboxes with **⌘Return** or by clicking directly on the `[ ]` / `[x]` brackets. Checked items appear with ~~strikethrough~~ and dimmed text.

Move lines up or down with **⌥⌘↑** / **⌥⌘↓**. Wrapped list lines align to the content start, not the bullet.

### Visual styling

| Element | Appearance |
|---|---|
| Bullet dashes `-`, `*` | 🔴 Magenta/red (`bulletDashColor`) |
| Ordered numbers `1.` | 🔴 Magenta/red (`bulletDashColor`) |
| Checkbox brackets `[ ]`, `[x]` | 🟣 Purple |
| Checked item content | ~~Strikethrough~~ + dimmed |
| URLs `https://...` | 🔵 Blue underlined (`linkColor`) |

## Clipboard manager
- **Text and images** — stores up to 1,000 clipboard entries
- **Searchable** — filter history with highlighted search matches
- **Click to copy** — click any entry to copy it back to clipboard (or paste directly — configurable in settings)
- **Quick-access shortcuts** — ⌘1–9 to copy the Nth item, ⌥1–9 to paste it into the previously active app
- **Zoom preview** — hover a tile and click the magnifying glass to view full content in a near-fullscreen overlay
- **Keyboard navigation** — arrow keys to browse items, Enter to copy, Space to preview/unpreview, Escape to deselect
- **Grid or panels** — switch between a multi-column grid and full-width panel rows
- **Configurable cards** — adjust preview line count and font size in settings
- **Delete entries** — remove individual items on hover
- **Separate hotkey** — assign a dedicated global hotkey to show/hide
- **iCloud sync** — text entries sync across devices alongside scratch tabs (up to 200 most recent)

## Install

```bash
brew install --cask euforicio/taps/scratchpad
```

Or download the latest DMG from [GitHub releases](https://github.com/euforicio/scratchpad/releases).

## Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘T / ⌘N | New tab |
| ⌘W | Close tab |
| ⌘O | Open file |
| ⌘S | Save |
| ⇧⌘S | Save as |
| ⌃Tab | Next tab |
| ⇧⌃Tab | Previous tab |
| ⌘F | Find |
| ⌥⌘F | Find and replace |
| ⌘G | Find next |
| ⇧⌘G | Find previous |
| ⌘E | Use selection for find |
| ⌘D | Duplicate line |
| ⌘Return | Toggle checkbox |
| ⇧⌘L | Toggle checklist |
| ⌥⌘↑ | Move line up |
| ⌥⌘↓ | Move line down |
| ⌘1–9 | Switch to tab by position |
| ⇧⌘T | Always on top |
| ⇧⌘D | Split right |
| ⇧⌃⌘D | Split down |
| ⌘+ | Increase font size |
| ⌘- | Decrease font size |
| ⌘0 | Reset font size |
| Tab | Indent line/selection |
| ⇧Tab | Unindent line/selection |
| Fn↓ / Fn↑ | Page down / up (moves cursor) |

### Clipboard

| Shortcut | Action |
|----------|--------|
| ↓ | Move focus from search to first item |
| ↑↓←→ | Navigate between items |
| Return | Copy selected item (or paste — see settings) |
| Space | Toggle preview overlay |
| Escape | Deselect item / close preview |
| ⌘1–9 | Copy Nth visible item to clipboard |
| ⌥1–9 | Copy Nth item and paste into active app |

## Distribution

Scratchpad ships as a direct/DMG build downloaded from GitHub/Homebrew.

### Schemes and configs

| Scheme | Configs | Entitlements | Use |
|---|---|---|---|
| `scratchpad` | `Debug` / `Release` | `scratchpad-direct.entitlements` | Direct/DMG distribution |
| `scratchpad-appstore` | `Debug-AppStore` / `Release-AppStore` | `scratchpad.entitlements` | Reserved for future App Store work |

### Entitlements

The direct distribution entitlement set is:

| Entitlement | Direct/DMG |
|---|---|
| `app-sandbox` | yes |
| `files.user-selected.read-write` | yes |
| `files.bookmarks.app-scope` | yes |
| `cs.allow-unsigned-executable-memory` | yes (highlight.js JSContext) |
| `network.client` | yes (update checker) |
| `ubiquity-kvstore-identifier` | yes (legacy, unused) |
| `icloud-container-identifiers` | `iCloud.io.euforic.scratchpad` |
| `icloud-container-environment` | `Production` |
| `icloud-services` | `CloudKit` |

`network.client` is used so direct builds can check GitHub releases.

### Signing

- **Direct/DMG:** Signed with "Developer ID Application" certificate and a Developer ID provisioning profile. The build script (`scripts/build-release.sh`) archives unsigned, embeds the profile, then manually signs with resolved entitlements (Xcode variables like `$(TeamIdentifierPrefix)` are expanded to literal values).
- `scripts/build-release.sh` requires `SIGNING_IDENTITY` to be set to the exact Developer ID Application identity in Keychain, for example `Developer ID Application: Your Name (TEAMID)`.
- A valid `TEAM_ID` and `BUNDLE_ID` are read from `project.yml` (`DEVELOPMENT_TEAM` and `PRODUCT_BUNDLE_IDENTIFIER`) and can be overridden with env vars when needed.
- For direct/DMG releases, do not publish unsigned/un-notarized artifacts.
- `xcrun codesign --verify --deep --strict --verbose=1 dist/Scratchpad-<VERSION>.app`
- `xcrun stapler validate dist/Scratchpad-<VERSION>.dmg`
- `xcrun spctl -a -vvv -t install dist/Scratchpad-<VERSION>.dmg`

### iCloud sync

Both versions use CloudKit via `CKSyncEngine` for syncing scratch tabs and clipboard history. The `CloudSyncEngine` singleton manages the sync lifecycle. See the record schema and sync flow in the [iOS migration docs](../itsypad-ios/docs/cloudkit-sync.md).

## Architecture

```
Sources/
├── App/
│   ├── AppDelegate.swift                # Menu bar, toolbar, window, and panel setup
│   ├── BonsplitRootView.swift           # SwiftUI root view rendering editor and clipboard tabs
│   ├── CloudSyncEngine.swift            # CloudKit sync via CKSyncEngine for tabs and clipboard
│   ├── G2SyncEngine.swift              # Even Realities G2 glasses sync (Labs)
│   ├── KVSMigration.swift              # Legacy iCloud KVS data migration
│   ├── Launch.swift                     # App entry point
│   ├── MenuBuilder.swift                # Main menu bar construction
│   ├── Models.swift                     # ShortcutKeys and shared data types
│   ├── TabStore.swift                   # Tab data model with persistence
│   └── UpdateChecker.swift              # GitHub release check for new versions
├── Editor/
│   ├── EditorContentView.swift          # NSViewRepresentable wrapping text view, scroll view, and gutter
│   ├── EditorCoordinator.swift          # Tab/pane orchestrator bridging TabStore and Bonsplit
│   ├── EditorStateFactory.swift         # Editor state creation and theme application
│   ├── EditorTextView.swift             # NSTextView subclass with editing helpers and file drops
│   ├── EditorTheme.swift                # Dark/light color palettes with CSS-derived theme cache
│   ├── FileWatcher.swift                # DispatchSource-based file change monitoring
│   ├── HighlightJS.swift                # JSContext wrapper for highlight.js with CSS/HTML parsing
│   ├── LanguageDetector.swift           # File extension → language mapping for highlight.js
│   ├── LayoutSerializer.swift           # Split layout capture and restore for session persistence
│   ├── LineNumberGutterView.swift       # Line number gutter drawn alongside the text view
│   ├── ListHelper.swift                 # List/checklist parsing, continuation, and toggling
│   ├── MarkdownPreviewManager.swift     # Markdown preview lifecycle and toolbar integration
│   ├── MarkdownPreviewView.swift        # WKWebView wrapper for rendered markdown preview
│   ├── MarkdownRenderer.swift           # Markdown-to-HTML via marked.js + highlight.js in JSContext
│   ├── SessionRestorer.swift            # Session restore logic for tabs and editor state
│   ├── SyntaxHighlightCoordinator.swift # Syntax highlighting coordinator using HighlightJS
│   └── SyntaxThemeRegistry.swift        # Curated syntax theme definitions with dark/light CSS mapping
├── Clipboard/
│   ├── ClipboardStore.swift             # Clipboard monitoring, history persistence, and CloudKit sync
│   ├── ClipboardContentView.swift       # NSCollectionView grid with search, keyboard nav, and layout
│   ├── ClipboardCollectionView.swift    # NSCollectionView subclass with key event delegation
│   ├── ClipboardCardItem.swift          # NSCollectionViewItem wrapper for card views
│   ├── ClipboardCardView.swift          # Individual clipboard card with preview, delete, and zoom
│   ├── ClipboardPreviewOverlay.swift    # Near-fullscreen zoom preview overlay
│   ├── ClipboardTabView.swift           # NSViewRepresentable wrapper for ClipboardContentView
│   ├── CardTextField.swift              # Non-interactive text field (suppresses I-beam cursor)
│   └── AccessibilityHelper.swift        # Accessibility check and CGEvent paste simulation
├── Settings/
│   ├── SettingsStore.swift              # UserDefaults-backed settings with change notifications
│   ├── SettingsView.swift               # SwiftUI settings window (general, editor, appearance, clipboard)
│   └── ShortcutRecorder.swift           # SwiftUI hotkey recorder control
├── Hotkey/
│   ├── HotkeyManager.swift              # Global hotkeys and triple-tap modifier detection
│   └── ModifierKeyDetection.swift       # Left/right modifier key identification from key codes
├── Resources/
│   ├── Assets.xcassets                  # App icon and custom images
│   └── Localizable.xcstrings           # String catalog for 12 languages
├── Info.plist                           # Bundle metadata and document types
├── scratchpad.entitlements                 # App Store entitlements (sandbox, CloudKit, iCloud)
└── scratchpad-direct.entitlements          # Direct/DMG entitlements (adds network.client for update checker)
Executable/
└── main.swift                           # Executable target entry point
Packages/
└── Bonsplit/                            # Local package: split pane and tab bar framework
Tests/
├── AutoDetectTests.swift
├── ClipboardShortcutTests.swift
├── ClipboardStoreTests.swift
├── CloudSyncEngineTests.swift
├── EditorThemeTests.swift
├── FileWatcherTests.swift
├── HighlightJSTests.swift
├── KVSMigrationTests.swift
├── LanguageDetectorTests.swift
├── LineNumberGutterViewTests.swift
├── ListHelperTests.swift
├── MarkdownPreviewManagerTests.swift
├── MarkdownRendererTests.swift
├── ModifierKeyDetectionTests.swift
├── SettingsStoreTests.swift
├── ShortcutKeysTests.swift
├── SyntaxThemeRegistryTests.swift
└── TabStoreTests.swift
scripts/
├── build-release.sh                    # Build, sign, and package DMG for direct distribution
├── pull-translations.sh                # Pull translations from Lokalise into xcstrings
└── push-translations.sh               # Push English source strings to Lokalise
```

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 16.0 or later
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) for Xcode project generation

## Building

```bash
xcodegen generate
open scratchpad.xcodeproj
```

Then build and run with ⌘R in Xcode. Tests run with ⌘U.

## Releasing

### Both versions

1. Bump `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `project.yml`
2. Run `xcodegen generate`

### Direct/DMG release

3. Build, sign, package, notarize, and staple (recommended):

```bash
SKIP_NOTARIZATION=0 \
SIGNING_IDENTITY=<SIGNING_IDENTITY> \
NOTARY_APPLE_ID=<APPLE_ID> \
NOTARY_TEAM_ID=<TEAM_ID> \
NOTARY_PASSWORD=<APP_SPECIFIC_PASSWORD> \
bash scripts/build-release.sh
```

or with API key auth:

```bash
SKIP_NOTARIZATION=0 \
SIGNING_IDENTITY=<SIGNING_IDENTITY> \
NOTARY_KEY_ID=<NOTARY_KEY_ID> \
NOTARY_ISSUER_ID=<NOTARY_ISSUER_ID> \
NOTARY_KEY_PATH=<PATH_TO_P8_KEY> \
bash scripts/build-release.sh
```

`scripts/build-release.sh` archives with the `scratchpad` scheme (`Release` config), embeds the Developer ID provisioning profile, signs with `scratchpad-direct.entitlements`, and creates a DMG. It then submits for notarization and staples the ticket when credentials are provided.

4. Verify the artifact is ready:

```bash
xcrun codesign --verify --deep --strict --verbose=1 dist/Scratchpad-<VERSION>.app
xcrun stapler validate dist/Scratchpad-<VERSION>.dmg
xcrun spctl -a -vvv -t install dist/Scratchpad-<VERSION>.dmg
```

5. Optional: disable notarization locally (CI/testing only):

```bash
SKIP_NOTARIZATION=1 bash scripts/build-release.sh
```

To fail fast when credentials are missing in CI, set `REQUIRE_NOTARIZATION=1`.

### Required GitHub Action secrets for release workflow

The release workflow on tag push requires these repository secrets to be set:

- `MACOS_SIGNING_IDENTITY`
- `MACOS_SIGNING_CERT_P12`
- `MACOS_KEYCHAIN_PASSWORD`
- `MACOS_SIGNING_CERT_PASSWORD`
- `MACOS_DEVELOPER_ID_PROFILE`
- `NOTARY_APPLE_ID` + `NOTARY_TEAM_ID` + `NOTARY_PASSWORD`
- OR `NOTARY_KEY_ID` + `NOTARY_ISSUER_ID` + `NOTARY_KEY_P8`

The workflow fails fast with a clear error if any required secret is missing.

To prepare those secrets locally:

```bash
bash scripts/setup-release-secrets.sh --bootstrap scripts/release-secrets.env
source scripts/release-secrets.env
bash scripts/setup-release-secrets.sh
```

`scripts/release-secrets.env` should be treated as a local, sensitive file and not committed.

6. Create the GitHub release:

```bash
gh release create v<VERSION> dist/Scratchpad-<VERSION>.dmg \
    --title "v<VERSION>" --notes "Release notes here"
git fetch --tags
```

7. Update the Homebrew tap:

```bash
shasum -a 256 dist/Scratchpad-<VERSION>.dmg
# Update Casks/scratchpad.rb in homebrew-tap with new version and sha256
```

## Localization

Scratchpad uses a Swift String Catalog (`Sources/Resources/Localizable.xcstrings`) for localization. Translations are managed via [Lokalise](https://lokalise.com).

Languages: English (base), Spanish, French, German, Russian, Japanese, Simplified Chinese, Traditional Chinese, Korean, Portuguese (Brazil), Italian, Polish.

### Setup

```bash
brew tap lokalise/cli-2
brew install lokalise2
cp lokalise.yml.example lokalise.yml
# Edit lokalise.yml and add your API token
```

### Push source strings to Lokalise

Extracts English keys and values from the xcstrings file and uploads to Lokalise:

```bash
scripts/push-translations.sh
```

### Pull translations from Lokalise

Downloads all translations from Lokalise and merges them into the xcstrings file:

```bash
scripts/pull-translations.sh
```

### Adding new strings

All user-facing strings use `String(localized:defaultValue:)` with a structured key:

```swift
// SwiftUI
Toggle(String(localized: "settings.general.show_in_menu_bar", defaultValue: "Show in menu bar"), isOn: $store.showInMenuBar)
Section(String(localized: "settings.editor.spacing", defaultValue: "Spacing")) { ... }

// AppKit
NSMenuItem(title: String(localized: "menu.file.new_tab", defaultValue: "New tab"), ...)
alert.messageText = String(localized: "alert.save_changes.title", defaultValue: "Do you want to save changes to \"\(name)\"?")
```

### Key naming convention

Keys use dot-separated structured names: `{area}.{context}.{name}`

| Area | Example keys |
|---|---|
| `menu.*` | `menu.file.new_tab`, `menu.edit.copy`, `menu.view.always_on_top` |
| `alert.*` | `alert.save_changes.title`, `alert.file_changed.reload` |
| `settings.*` | `settings.general.title`, `settings.editor.font_size` |
| `toolbar.*` | `toolbar.settings.label`, `toolbar.clipboard.tooltip` |
| `clipboard.*` | `clipboard.empty_state`, `clipboard.search_placeholder` |
| `tab.*` | `tab.context.copy_path`, `tab.context.pin` |
| `time.*` | `time.just_now`, `time.minutes_ago` |
| `accessibility.*` | `accessibility.alert.title` |
| `update.*` | `update.available.message` |

### Workflow after adding new strings

1. Build the project – Xcode auto-populates new keys in `Localizable.xcstrings`
2. Push source strings to Lokalise: `scripts/push-translations.sh`
3. Translate in [Lokalise](https://app.lokalise.com) (or let translators handle it)
4. Pull translations back: `scripts/pull-translations.sh`
5. Build and verify

### How it works

- All strings (SwiftUI and AppKit) use `String(localized:defaultValue:)` with structured keys
- Xcode populates the `.xcstrings` file with discovered keys on each build
- Push extracts English as `.strings` and uploads to Lokalise
- Pull downloads `.strings` per language and merges back into the xcstrings file

## License

MIT — see [LICENSE](LICENSE).

## Acknowledgements

Scratchpad is based on the original open-source app ItsyPad by [Nikolajs Ustinovs](https://github.com/nickustinov/itsypad-macos).
