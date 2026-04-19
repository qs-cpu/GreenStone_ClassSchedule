# AGENTS.md

## Setup

- **Enable direnv**: Run `direnv allow` after entering the project to load Java/Android/Flutter env vars from `.envrc`
- **One-time init**: `just init` (runs `flutter clean && flutter pub get`)

## Dev Commands

| Task | Command |
|------|---------|
| Analyze | `just analyze` or `flutter analyze` |
| Format | `just fmt` or `dart format .` |
| Run web | `just run-web` |
| Run Android | `just run-android` |
| Build APK | `just build-apk` |
| Build Web | `just build-web` |

## Build Config

- Android SDK: 36 / build-tools: 36.0.0
- Flutter SDK: ^3.11.3
- Uses `flutter_lints` (analysis_options.yaml includes `package:flutter_lints/flutter.yaml`)