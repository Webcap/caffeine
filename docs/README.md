# Ad Configuration Guide

This document explains how to configure ads in the Caffeine application using **Start.io**.

## 1. Remote Enablement (Admin Panel)

Ads are controlled exclusively by the admin via the remote configuration API. To enable ads globally, the API must return:

```json
{
  "ads_enabled": true
}
```

This flag is fetched at startup and updated periodically.

## 2. Start.io App ID

The app is currently configured with the Start.io App ID: **207904245**.

If you need to change this ID, update the `startAppId` constant in:
`lib/services/ad_service.dart`

```dart
static const String startAppId = 'YOUR_START_IO_APP_ID';
```

## 3. Platform Configuration

Unlike AdMob, Start.io for Flutter typically does not require adding the App ID to the `AndroidManifest.xml` or `Info.plist`. The ID is passed programmatically during initialization in `AdService`.

Ensure the following permissions are present in `AndroidManifest.xml`:
- `INTERNET`
- `ACCESS_NETWORK_STATE`
- `ACCESS_WIFI_STATE`

## 4. Implementation Details

- **Banner Ads**: Displayed using the `BannerAdWidget()`. It uses `StartAppBannerAd`.
- **Interstitial Ads**: Triggered automatically in `MovieVideoLoader` and `TVVideoLoader` before video playback if enabled.
- **Service**: Managed by the singleton `AdService.instance`. The SDK is initialized at startup in `main.dart`.
