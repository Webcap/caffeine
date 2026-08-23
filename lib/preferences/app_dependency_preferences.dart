// ignore_for_file: constant_identifier_names
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'dart:math' as math;

class AppDependencies {
  static const VIDSRC_API_URL = "vidsrcApi";
  static const CAFFIENE_LOGO_URL = "caffieneLogoUrl";
  static const STREAM_SERVER_FLIXHQ = "vidcloud";
  static const STREAM_SERVER_DCVA = "asianload";
  static const STREAM_SERVER_ZORO = "vidcloud";
  static const OPENSUBTITLES_KEY = "opensubtitlesKey";
  static const SHOWBOX_URL = "showbox_url";
  static const STREAM_ROUTE = "streamRoute";
  static const CAFFEINE_API_URL = "caffeineAPIURL";
  static const NEW_FLIXHQ_URL = "newFlixHQUrl";
  static const NEW_FLIXHQ_SERVER = "newFlixHQServer";
  static const TMDB_PROXY = "tmdb_proxy";
  static const ANIMEKAI_SERVER = "animekai_server";
  static const HIANIME_SERVER = "hianime_server";
  static const ENABLE_LIVE_SPORTS = "enable_live_sports";
  static const DISABLE_REVENUECAT = "disableRevenueCat";
  static const String ENABLE_ANONYMOUS_SIGNIN = 'enable_anonymous_signin';
  static const String ENABLE_GOOGLE_SIGNIN = 'enable_google_signin';
  static const String MIXPANEL_TOKEN = 'mixpanel_token';
  static const String DISPLAY_PREMIUM_BANNER = "display_premium_banner";
  static const String ANONYMOUS_ID = "anonymous_id";

  Future<String> getAnonymousId() async {
    String? id = sharedPrefsSingleton.getString(ANONYMOUS_ID);
    if (id == null || id.isEmpty) {
      id = DateTime.now().millisecondsSinceEpoch.toString() +
          (1000 + (math.Random().nextInt(9000))).toString();
      await sharedPrefsSingleton.setString(ANONYMOUS_ID, id);
    }
    return id;
  }

  Future<void> setEnableAnonymousSignIn(bool value) async {
    await sharedPrefsSingleton.setBool(ENABLE_ANONYMOUS_SIGNIN, value);
  }

  Future<void> setEnableGoogleSignIn(bool value) async {
    await sharedPrefsSingleton.setBool(ENABLE_GOOGLE_SIGNIN, value);
  }

  Future<void> setMixpanelToken(String value) async {
    await sharedPrefsSingleton.setString(MIXPANEL_TOKEN, value);
  }

  Future<void> setDisplayPremiumBanner(bool value) async {
    await sharedPrefsSingleton.setBool(DISPLAY_PREMIUM_BANNER, value);
  }

  Future<bool> getEnableAnonymousSignIn() async {
    return sharedPrefsSingleton.getBool(ENABLE_ANONYMOUS_SIGNIN) ?? false;
  }

  Future<bool> getEnableGoogleSignIn() async {
    return sharedPrefsSingleton.getBool(ENABLE_GOOGLE_SIGNIN) ?? false;
  }

  Future<String> getMixpanelToken() async {
    return sharedPrefsSingleton.getString(MIXPANEL_TOKEN) ?? '';
  }

  Future<bool> getDisplayPremiumBanner() async {
    return sharedPrefsSingleton.getBool(DISPLAY_PREMIUM_BANNER) ?? true;
  }

  Future<void> setDisableRevenueCat(bool value) async {
    sharedPrefsSingleton.setBool(DISABLE_REVENUECAT, value);
  }

  Future<bool> getDisableRevenueCat() async {
    return sharedPrefsSingleton.getBool(DISABLE_REVENUECAT) ?? false;
  }

  Future<void> setEnableOtt(bool value) async {
    sharedPrefsSingleton.setBool(ENABLE_LIVE_SPORTS, value);
  }

  Future<bool> getEnableOtt() async {
    return sharedPrefsSingleton.getBool(ENABLE_LIVE_SPORTS) ?? true;
  }

  Future<void> setNewFlixHQUrl(String value) async {
    sharedPrefsSingleton.setString(NEW_FLIXHQ_URL, value);
  }

  Future<String> getNewFlixHQUrl() async {
    final stored = sharedPrefsSingleton.getString(NEW_FLIXHQ_URL);
    if (stored == null || stored.isEmpty) {
      return defaultCaffeineApiUrl;
    }
    if (isCaffeineApiPreviewUrl(stored)) {
      return defaultCaffeineApiUrl;
    }
    return stored;
  }

  Future<void> setvidSrcApi(String value) async {
    sharedPrefsSingleton.setString(VIDSRC_API_URL, value);
  }

  Future<String> getvidSrcApi() async {
    return sharedPrefsSingleton.getString(VIDSRC_API_URL) ??
        'https://vidsrc-api-sage.vercel.app/';
  }

  Future<void> setCaffieneUrl(String value) async {
    sharedPrefsSingleton.setString(CAFFIENE_LOGO_URL, value);
  }

  /// Old production Vercel URL; if user had this saved, use current default (AWS).
  static const String _legacyVercelProductionUrl =
      'https://caffeine-api.vercel.app';
  static const String _legacyVercelProductionUrlSlash =
      'https://caffeine-api.vercel.app/';

  Future<String> getFQURL() async {
    final stored = sharedPrefsSingleton.getString(CAFFEINE_API_URL);
    if (stored == null || stored.isEmpty) {
      return defaultCaffeineApiUrl;
    }
    if (isCaffeineApiPreviewUrl(stored)) {
      return defaultCaffeineApiUrl;
    }
    final normalized = stored.endsWith('/') ? stored : '$stored/';
    if (normalized == _legacyVercelProductionUrlSlash ||
        stored == _legacyVercelProductionUrl ||
        stored == _legacyVercelProductionUrlSlash) {
      return defaultCaffeineApiUrl;
    }
    return stored;
  }

  Future<void> setCaffeineAPIUrl(String value) async {
    sharedPrefsSingleton.setString(CAFFEINE_API_URL, value);
  }

  Future<String> getCaffieneLogo() async {
    return sharedPrefsSingleton.getString(CAFFIENE_LOGO_URL) ?? 'default';
  }

  Future<void> setOpenSubKey(String value) async {
    sharedPrefsSingleton.setString(OPENSUBTITLES_KEY, value);
  }

  Future<String> getOpenSubtitlesKey() async {
    return sharedPrefsSingleton.getString(OPENSUBTITLES_KEY) ??
        openSubtitlesKey;
  }

  Future<void> setStreamServerFlixHQ(String value) async {
    sharedPrefsSingleton.setString(STREAM_SERVER_FLIXHQ, value);
  }

  Future<String> getStreamServerFlixHQ() async {
    return sharedPrefsSingleton.getString(STREAM_SERVER_FLIXHQ) ??
        streamingServerFlixhq;
  }

  Future<void> setStreamServerNewFlixHQ(String value) async {
    sharedPrefsSingleton.setString(NEW_FLIXHQ_SERVER, value);
  }

  Future<String> getStreamServerNewFlixHQ() async {
    return sharedPrefsSingleton.getString(NEW_FLIXHQ_SERVER) ??
        streamingServerNewFlixhq;
  }

  Future<void> setStreamServerDCVA(String value) async {
    sharedPrefsSingleton.setString(STREAM_SERVER_DCVA, value);
  }

  Future<String> getStreamServerDCVA() async {
    return sharedPrefsSingleton.getString(STREAM_SERVER_DCVA) ??
        streamingServerDcva;
  }

  Future<String> getShowboxUrl() async {
    return sharedPrefsSingleton.getString(SHOWBOX_URL) ?? "";
  }

  Future<void> setShowboxUrl(String value) async {
    sharedPrefsSingleton.setString(SHOWBOX_URL, value);
  }

  Future<String> getStreamRoute() async {
    return sharedPrefsSingleton.getString(STREAM_ROUTE) ?? 'tmDB';
  }

  Future<void> setStreamRoute(String value) async {
    sharedPrefsSingleton.setString(STREAM_ROUTE, value);
  }

  Future<void> setStreamServerZoro(String value) async {
    sharedPrefsSingleton.setString(STREAM_SERVER_ZORO, value);
  }

  Future<String> getStreamServerZoro() async {
    return sharedPrefsSingleton.getString(STREAM_SERVER_ZORO) ??
        streamingServerZoro;
  }

  Future<void> setTmdbProxy(String value) async {
    sharedPrefsSingleton.setString(TMDB_PROXY, value);
  }

  Future<String> getTmdbProxy() async {
    return sharedPrefsSingleton.getString(TMDB_PROXY) ?? "";
  }

  Future<void> setAnimekaiServer(String value) async {
    sharedPrefsSingleton.setString(ANIMEKAI_SERVER, value);
  }

  Future<String> getAnimekaiServer() async {
    return sharedPrefsSingleton.getString(ANIMEKAI_SERVER) ?? 'vidcloud';
  }

  Future<void> setHianimeServer(String value) async {
    sharedPrefsSingleton.setString(HIANIME_SERVER, value);
  }

  Future<String> getHianimeServer() async {
    return sharedPrefsSingleton.getString(HIANIME_SERVER) ?? 'vidcloud';
  }
}
