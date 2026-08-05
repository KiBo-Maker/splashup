# Contributing to SplashUp

[🇮🇹 Italiano](CONTRIBUTING.md) | 🇬🇧 English

Thanks for your interest in contributing! SplashUp is open source (MIT license, see [LICENSE](LICENSE)) and contributions are welcome: bug fixes, new features, support for new platforms, translations, and more.

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (see `environment.sdk` in `pubspec.yaml` for the minimum version).
- An editor with Dart/Flutter support (VS Code or Android Studio recommended).

## Getting started

1. Fork the repository and clone it locally.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on an emulator/device (or desktop/web):
   ```bash
   flutter run
   ```
4. Create a branch for your change:
   ```bash
   git checkout -b descriptive-branch-name
   ```

## Before opening a Pull Request

- Run static analysis and tests:
  ```bash
  flutter analyze
  flutter test
  ```
- If you add user-facing text, update the localization keys in `lib/l10n/app_it.arb` and `lib/l10n/app_en.arb` and **regenerate** the translation files:
  ```bash
  flutter gen-l10n
  ```
  The generated files (`lib/l10n/app_localizations*.dart`) are checked in, and CI verifies they match the `.arb` sources.
- If the change is user-facing, update [CHANGELOG.md](CHANGELOG.md).
- Describe what changes and why in the PR; for bug fixes, explain how to reproduce the original issue.


## Publishing a release

For maintainers with write access only.

1. Update `version:` in `pubspec.yaml` (e.g. `2.5.0+31`) and add the entry to [CHANGELOG.md](CHANGELOG.md).
2. Commit, then create and push the tag:
   ```bash
   git tag v2.5.0
   git push origin v2.5.0
   ```
3. The [`release.yml`](.github/workflows/release.yml) workflow builds the signed APK and creates a **draft** GitHub Release with the APK attached.
4. Write the release notes in the draft and hit "Publish release".

The tag must match `version:` in `pubspec.yaml` (build number aside): the workflow stops if they diverge, because the in-app update check compares exactly those two numbers.

While the release stays a draft the app will not announce it: `GET /releases/latest` skips drafts and prereleases.

### Required secrets

To sign the APK the repository needs these secrets (Settings -> Secrets and variables -> Actions):

| Secret | Content |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | the `.jks` file, base64 encoded |
| `ANDROID_KEYSTORE_PASSWORD` | `storePassword` |
| `ANDROID_KEY_PASSWORD` | `keyPassword` |
| `ANDROID_KEY_ALIAS` | `keyAlias` (e.g. `upload`) |

To produce the base64 blob:

```powershell
# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\splashupkey.jks")) | Set-Clipboard
```

```bash
# Linux/macOS
base64 -w0 splashupkey.jks
```

To build a signed APK locally, copy `android/key.properties.example` to `android/key.properties` and fill it in: the file is git-ignored.

## Reporting bugs or proposing ideas

Open an [Issue](../../issues) describing the problem (with reproduction steps, if possible) or the proposed idea. For new platforms or major features, it's best to open a discussion Issue before writing code, to align on the approach first.

## Note on branding

The code is MIT licensed, but the "SplashUp" name and app icon are reserved for the official release (see [LICENSE](LICENSE)). If you publish a fork on a store, use a different name and icon.
