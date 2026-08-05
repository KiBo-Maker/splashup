<p align="center">
  <img src="assets/images/SplashUp_Icon.png" alt="SplashUp" width="120">
</p>

<h1 align="center">SplashUp</h1>

<p align="center">
  <a href="README.md">🇮🇹 Italiano</a> | 🇬🇧 English
</p>

<p align="center">
  The easy app for swim coaches 🏊
</p>

SplashUp is a Flutter app built for swim coaches who want to time athletes in the pool and track their progress, with no internet connection required: all data stays on the device.

## Key features

- **Teams and athletes management**: create teams, add athletes, move them between teams, or deactivate/delete them once no longer active.
- **Stopwatch with splits**: start, stop, and record lap times with configurable haptic and sound feedback, and keep the screen on while using it.
- **Splits analysis**: dedicated charts to visualize time trends across training sessions and races.
- **Works offline**: data is stored in a local database (Sembast), no connection required.
- **Backup and restore**: export teams, athletes and times to a JSON file wherever you like (including a folder synced with your own cloud) and restore them on another device.
- **Customization and accessibility**: light/dark/system theme, 6 color palettes, adjustable text size, and OpenDyslexic font for users with dyslexia.
- **Multi-language**: interface available in Italian and English, following the system language or set manually.
- **Update check**: the app tells you when a new version is released on GitHub. It is the only internet connection the app makes, and it can be turned off.

## Screenshots

<p align="center">
  <img src="assets/Screenshots/Squadre.jpg" alt="Teams" width="18%">
  <img src="assets/Screenshots/Modifica.jpg" alt="Edit" width="18%">
  <img src="assets/Screenshots/Crono.jpg" alt="Chrono" width="18%">
  <img src="assets/Screenshots/Impostazioni.jpg" alt="Settings" width="18%">
  <img src="assets/Screenshots/Personalizzazione.jpg" alt="Customization" width="18%">
</p>

## Tech stack

- [Flutter](https://flutter.dev) / Dart
- [Provider](https://pub.dev/packages/provider) for state management
- [Sembast](https://pub.dev/packages/sembast) as local database
- [fl_chart](https://pub.dev/packages/fl_chart) for charts
- [shared_preferences](https://pub.dev/packages/shared_preferences) for user settings
- [file_selector](https://pub.dev/packages/file_selector) and [flutter_file_dialog](https://pub.dev/packages/flutter_file_dialog) for backup/restore through the system dialogs
- [http](https://pub.dev/packages/http) to read the public releases on GitHub

## Getting started

Requirements: [Flutter SDK](https://docs.flutter.dev/get-started/install) (see `environment.sdk` in `pubspec.yaml` for the minimum version).

```bash
flutter pub get
flutter run
```

## Project structure

```
lib/
├── models/       # Data models (athlete, team, timing)
├── repositories/ # Local database access
├── screens/      # App screens
├── services/     # Services (theme, language, stopwatch, backup, updates)
├── l10n/         # Localization files (it/en)
└── utils/        # Various utilities
```

## Build and releases

Every push to `main` runs `flutter analyze` and `flutter test` on GitHub Actions.
Pushing a `vX.Y.Z` tag builds a signed release APK and attaches it to a draft GitHub
Release, ready to review and publish. See [.github/workflows](.github/workflows) and
[CONTRIBUTING.en.md](CONTRIBUTING.en.md#publishing-a-release).

## Changelog

Release notes are documented in [CHANGELOG.md](CHANGELOG.md).

## Contributing

Contributions are welcome! See [CONTRIBUTING.en.md](CONTRIBUTING.en.md) to get started.

## License

Distributed under the [MIT](LICENSE) license. The "SplashUp" name and app icon are reserved for the official release (see the note in the [LICENSE](LICENSE) file).
