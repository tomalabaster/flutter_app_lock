# AGENTS.md

## Cursor Cloud specific instructions

### Product overview

This repo is a **Flutter/Dart library** (`flutter_app_lock`) with an **example mobile app** in `example/`. There is no backend or database. Primary development is the library at the repo root; the example app targets Android and iOS only (no committed web/desktop targets).

### Flutter SDK

- **Version:** Flutter **3.35.1** (matches `.fvmrc`). Installed at `~/flutter` with `PATH` including `$HOME/flutter/bin` in `~/.bashrc`.
- `flutter doctor` may warn about the detached git checkout and missing Android/iOS toolchains; that is expected in this VM. Unit tests and web demos do not require Android Studio.

### Dependencies

From repo root:

```bash
flutter pub get
(cd example && flutter pub get)
```

The update script runs these automatically on VM startup.

### Lint / analyze

```bash
flutter analyze
```

Uses `analysis_options.yaml` and `flutter_lints`. A deprecation info in `lib/src/app_lock.dart` is known and does not fail CI-style checks by itself.

### Tests

**Library (headless, no device):**

```bash
flutter test
```

**Example integration tests (device/emulator required):**

```bash
cd example
flutter test integration_test/integration_test.dart -d <device-id>
```

README references `integration_tests.dart` (typo); the real path is `integration_test/integration_test.dart`.

### Running the example app in this VM

The committed example only includes `android/` and `ios/`. To run on Chrome in the cloud VM:

```bash
cd example
flutter create . --platforms=web   # generates web/ locally; do not commit unless intentional
flutter run -d chrome --web-port=8080
```

Demo unlock password is **`0000`**. Use tmux for long-running `flutter run` sessions.

Linux desktop builds need extra system packages (`ninja-build`, `libgtk-3-dev`, `build-essential`) and may require a `libstdc++.so` symlink for clang; Chrome/web is the simpler path here.

### Services

| Service | Required? | Notes |
|---------|-----------|-------|
| Flutter SDK + Dart | Yes | Only hard dependency for library work |
| Chrome | Optional | For web demo of `example/` |
| Android SDK / emulator | Optional | For mobile example + integration tests |
| Xcode / iOS simulator | Optional | macOS only |
