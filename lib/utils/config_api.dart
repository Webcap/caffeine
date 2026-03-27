import 'dart:convert';

import 'package:caffiene/models/update.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<void> fetchConfigFromApi(
    AppDependencyProvider appDependencyProvider) async {
  try {
    // Provider getter already prefers .env in debug; use it for config fetch.
    final base = appDependencyProvider.caffeineAPIURL.trim().isNotEmpty &&
            !isCaffeineApiPreviewUrl(appDependencyProvider.caffeineAPIURL)
        ? appDependencyProvider.caffeineAPIURL
        : caffeineApiUrl;
    final baseUrl =
        base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final url = Uri.parse('$baseUrl/config');
    final response = await http.get(url).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Config fetch timeout'),
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      void setString(String key, void Function(String) setter) {
        final v = data[key];
        if (v != null && v.toString().trim().isNotEmpty) {
          setter(v.toString());
        }
      }

      void setBool(String key, void Function(bool) setter) {
        final v = data[key];
        if (v != null) {
          setter(v == true || v.toString().toLowerCase() == 'true');
        }
      }

      setString('consumet_url', (v) => appDependencyProvider.consumetUrl = v);
      setString('vidscr_api', (v) => appDependencyProvider.vidsrcapi = v);
      setString('opensubtitles_key',
          (v) => appDependencyProvider.opensubtitlesKey = v);
      setString('streaming_server_dcva',
          (v) => appDependencyProvider.streamingServerDCVA = v);
      setBool('ads_enabled', (v) => appDependencyProvider.enableADS = v);
      setString('route', (v) => appDependencyProvider.fetchRoute = v);
      setBool('use_external_subtitles',
          (v) => appDependencyProvider.useExternalSubtitles = v);
      setBool('ott_ads_enabled', (v) => appDependencyProvider.enableOTTADS = v);
      setBool('enable_stream',
          (v) => appDependencyProvider.displayWatchNowButton = v);
      setBool('enable_ott', (v) => appDependencyProvider.displayOTTDrawer = v);
      setBool('disable_revenuecat',
          (v) => appDependencyProvider.disableRevenueCat = v);
      setBool('enable_anonymous_signin',
          (v) => appDependencyProvider.enableAnonymousSignIn = v);
      setBool('enable_google_signin',
          (v) => appDependencyProvider.enableGoogleSignIn = v);
      setString('mixpanel_token', (v) => appDependencyProvider.mixpanelToken = v);
      setBool('display_premium_banner',
          (v) => appDependencyProvider.displayPremiumBanner = v);
      setString('caffeine_api_url', (v) {
        if (isCaffeineApiPreviewUrl(v)) return;
        // In debug, don't overwrite with localhost (API default); keep .env URL.
        if (kDebugMode && (v.contains('localhost') || v.contains('127.0.0.1')))
          return;
        appDependencyProvider.caffeineAPIURL = v;
      });
      setString('streaming_server_zoro',
          (v) => appDependencyProvider.streamingServerZoro = v);
      setBool('forced_update', (v) => appDependencyProvider.isForcedUpdate = v);
      setString(
          'latest_version', (v) => appDependencyProvider.latestVersion = v);
      setString('update_download_url',
          (v) => appDependencyProvider.updateDownloadUrl = v);
      setString(
          'update_store_url', (v) => appDependencyProvider.updateStoreUrl = v);
      setString(
          'update_changelog', (v) => appDependencyProvider.updateChangelog = v);
      setString('vidsrc_server', (v) => appDependencyProvider.vidSrcServer = v);
      setString(
          'vidsrcto_server', (v) => appDependencyProvider.vidSrcToServer = v);
      setString('tmdb_proxy', (v) => appDependencyProvider.tmdbProxy = v);
      setString('new_flixhq_url', (v) {
        if (!isCaffeineApiPreviewUrl(v)) {
          appDependencyProvider.newFlixHQUrl = v;
        }
      });
      setString('new_flixhq_server',
          (v) => appDependencyProvider.newFlixhqServer = v);
      setString('goku_server', (v) => appDependencyProvider.gokuServer = v);
      setString('sflix_server', (v) => appDependencyProvider.sflixServer = v);
      setString(
          'himovies_server', (v) => appDependencyProvider.himoviesServer = v);
      setString(
          'animekai_server', (v) => appDependencyProvider.animekaiServer = v);
      setString(
          'hianime_server', (v) => appDependencyProvider.hianimeServer = v);
      setString('revenuecat_public_sdk_key_android',
          (v) => appDependencyProvider.revenueCatApiKeyAndroid = v);
      setString('revenuecat_public_sdk_key_ios',
          (v) => appDependencyProvider.revenueCatApiKeyIOS = v);
      setString('revenuecat_entitlement_id',
          (v) => appDependencyProvider.revenueCatEntitlementId = v);
    }
  } catch (_) {
    // Keep .env / preferences defaults on fetch failure
  }
}

/// Refreshes config from API and applies it. Call when config may have changed (e.g. admin update).
Future<void> refreshConfig(AppDependencyProvider appDependencyProvider) async {
  await fetchConfigFromApi(appDependencyProvider);
}

/// Fetches config from API and returns update-related fields. Single source of truth for "is update available?" and links.
Future<AppUpdateInfo> fetchUpdateInfoFromApi(
    AppDependencyProvider appDependencyProvider) async {
  await fetchConfigFromApi(appDependencyProvider);
  final p = appDependencyProvider;
  String? opt(String s) => s.trim().isEmpty ? null : s;
  return AppUpdateInfo(
    latestVersion: p.latestVersion,
    forcedUpdate: p.isForcedUpdate,
    updateDownloadUrl: opt(p.updateDownloadUrl),
    updateStoreUrl: opt(p.updateStoreUrl),
    updateChangelog: opt(p.updateChangelog),
  );
}
