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

## Build Number & Version Generator

Run the build number generator to update `pubspec.yaml` and generate `lib/utils/app_version.g.dart`:

```bash
# Update date to today (YYYY.MM.DD) and increment build number (+1):
dart run tools/build_number_gen.dart

# Use Git commit count as build number:
dart run tools/build_number_gen.dart --git

# Use timestamp (YYMMddHHmm) as build number:
dart run tools/build_number_gen.dart --timestamp

# Set custom build number or version:
dart run tools/build_number_gen.dart --build 1750 --version 2026.08.22

# Only sync pubspec.yaml into lib/utils/app_version.g.dart without changing versions:
dart run tools/build_number_gen.dart --sync

# Dry run to preview changes:
dart run tools/build_number_gen.dart --dry-run
## Commit-Based Changelog Generator

Automatically parse and categorize commits since the last release tag:

```bash
# Print generated changelog to terminal:
dart run tools/changelog_gen.dart

# Prepend new release section directly into CHANGELOG.md:
dart run tools/changelog_gen.dart --write

# Output markdown to a specific file:
dart run tools/changelog_gen.dart --output release_notes.md
```

## Release Build Pipeline

Automate full release builds locally using `tools/release.ps1`:

```powershell
# Build production AAB and all APK formats:
.\tools\release.ps1 -Flavor prod -Target All

# Auto-bump build number, update CHANGELOG.md, and compile APKs:
.\tools\release.ps1 -Flavor prod -Target Apk -BumpVersion

# Perform clean development build:
.\tools\release.ps1 -Flavor dev -Clean
```

For complete technical specifications and CI/CD architecture, see [`docs/RELEASE_PIPELINE.md`](../docs/RELEASE_PIPELINE.md).