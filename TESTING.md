# Testing Caffeine App

This document explains how to run tests and the structure of the test suite.

## Test Structure

- `test/provider/`: Unit tests for state management providers.
- `test/services/`: Unit tests for backend services (mocked).
- `test/widgets/`: Widget tests for UI components.

## Running Tests

To run all unit and widget tests, use:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/provider/settings_provider_test.dart
```

## Mocking

We use `mocktail` for mocking. If you add new services or providers, make sure to add them to `test/test_helper.dart` to easily wrap them in `MultiProvider` for widget testing.

## Current Status

- **SettingsProvider**: Fully tested (initialization, updates, notification).
- **AdService**: Unit tested with mock SDK.
- **BannerAdWidget**: Basic visibility tests implemented.

> [!NOTE]
> Some SDK-provided widgets (like `StartAppBanner`) may not be fully unit-testable due to platform-specific dependencies. These are best tested via integration tests on a real device or emulator.
