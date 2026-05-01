import 'dart:convert';

import 'package:reelriot/models/update.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/utils/flavor_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> fetchConfigFromApi(
    AppDependencyProvider appDependencyProvider, {bool skipUpdateFields = false}) async {
  try {
    // Provider getter already prefers .env in debug; use it for config fetch.
    final base = appDependencyProvider.caffeineAPIURL.trim().isNotEmpty &&
            !isCaffeineApiPreviewUrl(appDependencyProvider.caffeineAPIURL)
        ? appDependencyProvider.caffeineAPIURL
        : caffeineApiUrl;
    final baseUrl =
        base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final url = Uri.parse('$baseUrl/config');
    final response = await http.get(url, headers: caffeineApiHeaders).timeout(
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
      setString('streamingServerDcva',
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
        if (kDebugMode && (v.contains('localhost') || v.contains('127.0.0.1'))) {
          return;
        }
        appDependencyProvider.caffeineAPIURL = v;
      });
      setString('streamingServerZoro',
          (v) => appDependencyProvider.streamingServerZoro = v);
      if (!skipUpdateFields) {
        setBool('forced_update', (v) => appDependencyProvider.isForcedUpdate = v);
        setString(
            'latest_version', (v) => appDependencyProvider.latestVersion = v);
        setString('update_download_url',
            (v) => appDependencyProvider.updateDownloadUrl = v);
        setString(
            'update_store_url', (v) => appDependencyProvider.updateStoreUrl = v);
        setString(
            'update_changelog', (v) => appDependencyProvider.updateChangelog = v);
      }
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
          
      // Success: Now fetch feature flags too
      await fetchFeatureFlagsFromApi(appDependencyProvider);
    }
  } catch (e) {
    debugPrint('Error fetching config: $e');
    // Keep .env / preferences defaults on fetch failure
  }
}

/// Fetches evaluated feature flags from the new system.
Future<void> fetchFeatureFlagsFromApi(AppDependencyProvider provider) async {
  try {
    final base = provider.caffeineAPIURL;
    final baseUrl = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    
    String getPlatformString() {
      if (kIsWeb) return 'web';
      switch (defaultTargetPlatform) {
        case TargetPlatform.android: return 'android';
        case TargetPlatform.iOS: return 'ios';
        default: return 'tv';
      }
    }
    
    final platform = getPlatformString();
    final env = FlavorConfig.instance.flavor.name;
    final userId = Supabase.instance.client.auth.currentSession?.user.id;
    final anonymousId = provider.anonymousId;

    final uri = Uri.parse('$baseUrl/v1/feature-flags').replace(queryParameters: {
      'platform': platform,
      'env': env,
      'detailed': 'true',
      if (userId != null) 'userId': userId,
      if (anonymousId.isNotEmpty) 'anonymousId': anonymousId,
    });

    final response = await http.get(uri, headers: caffeineApiHeaders).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      provider.featureFlags = data;
    }

  } catch (e) {
    debugPrint('Error fetching feature flags: $e');
  }
}

/// Refreshes config from API and applies it. Call when config may have changed (e.g. admin update).
Future<void> refreshConfig(AppDependencyProvider appDependencyProvider) async {
  await fetchConfigFromApi(appDependencyProvider);
}

/// Fetches config from API and returns update-related fields. Single source of truth for "is update available?" and links.
Future<AppUpdateInfo> fetchUpdateInfoFromApi(
    AppDependencyProvider appDependencyProvider) async {
  try {
    final base = appDependencyProvider.caffeineAPIURL;
    final baseUrl = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    
    String getPlatformString() {
      if (kIsWeb) return 'web';
      switch (defaultTargetPlatform) {
        case TargetPlatform.android: return 'android';
        case TargetPlatform.iOS: return 'ios';
        default: return 'tv';
      }
    }

    final platform = getPlatformString();
    final env = FlavorConfig.instance.flavor.name;

    final userId = Supabase.instance.client.auth.currentSession?.user.id;
    final anonymousId = appDependencyProvider.anonymousId;

    final uri = Uri.parse('$baseUrl/v1/updates').replace(queryParameters: {
      'platform': platform,
      'environment': env,
      if (userId != null) 'userId': userId,
      if (anonymousId.isNotEmpty) 'anonymousId': anonymousId,
    });


    final response = await http.get(uri, headers: caffeineApiHeaders).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final info = AppUpdateInfo.fromJson(data);
      
      debugPrint('[UpdateAPI] Success: latestVersion=${info.latestVersion}, hash=${identityHashCode(appDependencyProvider)}');
      
      // Update provider so listeners (like the update card) react immediately
      appDependencyProvider.latestVersion = info.latestVersion;
      appDependencyProvider.isForcedUpdate = info.forcedUpdate;
      appDependencyProvider.updateDownloadUrl = info.updateDownloadUrl ?? '';
      appDependencyProvider.updateStoreUrl = info.updateStoreUrl ?? '';
      appDependencyProvider.updateChangelog = info.updateChangelog ?? '';
      
      // Still fetch the rest of the config (feature flags, ads, etc.) but skip update fields
      // to avoid overwriting the fresh info we just got.
      await fetchConfigFromApi(appDependencyProvider, skipUpdateFields: true);
      
      return info;
    } else {
      debugPrint('[UpdateAPI] Error: HTTP ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('[UpdateAPI] Error fetching updates from new API: $e. Falling back to /config fields.');
  }

  // Fallback to the old /config monolithic response if the new one fails.
  await fetchConfigFromApi(appDependencyProvider, skipUpdateFields: false);
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
