# Repository Guidelines

## Project Structure & Modules
- `MarkSpark/`: App source (SwiftUI). Entry point `MarkSparkApp.swift`; menu UI in `MenuBarView.swift`.
- `MarkSpark/Assets.xcassets/`: App icons and image assets.
- `MarkSpark.xcodeproj/`: Xcode project files.
- `verify_conversion.sh`: Local script to sanity‑check Markdown→RTF clipboard conversion.
- Tests: No test targets yet; add `MarkSparkTests/` and `MarkSparkUITests/` when introduced.

## Build, Run, and Test
- Open in Xcode: `open MarkSpark.xcodeproj` (use the `MarkSpark` scheme, macOS target).
- CLI build: `xcodebuild -scheme MarkSpark -configuration Debug build`.
- Run locally: Launch from Xcode to start the menu bar app.
- Manual verification: `./verify_conversion.sh` then follow on‑screen steps.
- Tests (when available): `xcodebuild -scheme MarkSpark -destination 'platform=macOS' test`.

## Coding Style & Naming
- Indentation: 2 spaces; keep lines ≤ 120 chars.
- Swift conventions: Types `UpperCamelCase`; functions/vars `lowerCamelCase`; constants `let`.
- Files: One primary type per file; name files after the type (e.g., `MenuBarView.swift`).
- Organization: Group with `// MARK:`; minimize imports; prefer SwiftUI idioms.
- Lint/format: No repo‑enforced tool. Follow Swift API Design Guidelines. If you use SwiftFormat/SwiftLint locally, keep defaults and avoid adding config without discussion.

## Testing Guidelines
- Framework: `XCTest` (unit), `XCUITest` (UI) when added.
- Scope: Start with pure logic (formatting/parsing helpers) before UI.
- Naming: Mirror source types (e.g., `MarkdownFormatterTests`).
- Coverage: Target meaningful coverage on non‑UI code; avoid brittle UI tests.

## Commit & Pull Requests
- Commits: Imperative, concise subjects (≤ 72 chars). Optionally use Conventional Commits (`feat:`, `fix:`, `chore:`).
- PRs: Include a clear description, rationale, and screenshots/GIFs for UI changes. Link issues, describe test coverage or manual steps (mention `verify_conversion.sh`). Ensure project builds with no new warnings.

## Security & Configuration
- Do not commit secrets, signing certs, or provisioning profiles.
- Code signing: Use your local team for development; coordinate for release profiles.
- macOS permissions: If adding clipboard/file access changes, note them in the PR.
