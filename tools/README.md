# Local Config Server

Emulates the Caffeine API `/config` endpoint for local development.

## Run

1. Start the config server:
   ```bash
   node tools/run_config_server.js
   ```

2. Ensure `.env` has:
   ```
   CAFFEINE_API_URL=http://localhost:8080
   ```

3. Run the Flutter app:
   ```bash
   flutter run
   ```

## Android Emulator

Use the host machine IP instead of localhost:
```
CAFFEINE_API_URL=http://10.0.2.2:8080
```

## Edit config

Modify `tools/config.json` to change values returned by the mock server.

## Version Control

run `dart run tools/version_gen.dart` to update the version in `pubspec.yaml` and `lib/screens/common/update_screen.dart`