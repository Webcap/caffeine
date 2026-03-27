<p align="center">
    <img alt="Consumet" src="https://github.com/Webcap/webcap.github.io/blob/trunk/caffiene/res/assets/images/logo.png?raw=true" width="200">
</p>
<h1 align="center">Caffeine</h1>

Caffeine is a modern media tracking and streaming client designed for mobile and TV platforms. Built with Flutter, it provides a seamless experience for managing your favorite content across devices.

## 🚀 Features

- **Multi-Platform Support**: Optimized for both Mobile and Android TV.
- **Remote Configuration**: Feature flags and app updates managed via the Caffeine Admin panel.
- **Flavor Support**: Seamlessly switch between Development and Production environments.
- **Bookmark Sync**: Background synchronization for your favorites.
- **Update System**: Robust, internal APK update system with download progress and automated status management.

## 🛠️ Development

### Running the App (Flavors)

Caffeine uses Flutter flavors to manage different environments.

**Development**
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

**Production**
```bash
flutter run --flavor prod -t lib/main_prod.dart
```

### Setup

1. Copy `.env.example` to `.env` (if applicable).
2. Ensure your Supabase keys are correctly configured.
3. Run `flutter pub get`.

## 📦 Building

To build the APKs for distribution:

**Dev APK**
```bash
flutter build apk --flavor dev -t lib/main_dev.dart
```

**Prod APK**
```bash
flutter build apk --flavor prod -t lib/main_prod.dart
```

## 📜 Credits

- Most of the code is based on [Consumet API](https://github.com/consumet/api.consumet.org/)
- Uses [@movie-web/providers](https://www.npmjs.com/package/@movie-web/providers)


