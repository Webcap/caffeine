// ignore_for_file: constant_identifier_names
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/constant.dart';

class AppDependencies {
  static const CONSUMET_URL_KEY = "consumetUrlKey";
  static const CAFFIENE_LOGO_URL = "caffieneLogoUrl";
  static const STREAM_SERVER_FLIXHQ = "vidcloud";
  static const STREAM_SERVER_DCVA = "asianload";
  static const STREAM_SERVER_ZORO = "vidcloud";
  static const OPENSUBTITLES_KEY = "opensubtitlesKey";
  static const SHOWBOX_URL = "showbox_url";
  static const STREAM_ROUTE = "streamRoute";
  static const CAFFEINE_API_URL = "caffeineAPIURL";
  static const TMDB_PROXY = "tmdb_proxy";

  setConsumetUrl(String value) async {
    sharedPrefsSingleton.setString(CONSUMET_URL_KEY, value);
  }

  Future<String> getConsumetUrl() async {
    return sharedPrefsSingleton.getString(CONSUMET_URL_KEY) ??
        'https://consumet-api-beryl.vercel.app/';
  }

  setCaffieneUrl(String value) async {
    sharedPrefsSingleton.setString(CAFFIENE_LOGO_URL, value);
  }

  Future<String> getFQURL() async {
    return sharedPrefsSingleton.getString(CAFFEINE_API_URL) ??
        'https://caffeine-api.vercel.app/';
  }

  setCaffeineAPIUrl(String value) async {
    sharedPrefsSingleton.setString(CAFFEINE_API_URL, value);
  }

  Future<String> getCaffieneLogo() async {
    return sharedPrefsSingleton.getString(CAFFIENE_LOGO_URL) ?? 'default';
  }

  setOpenSubKey(String value) async {
    sharedPrefsSingleton.setString(OPENSUBTITLES_KEY, value);
  }

  Future<String> getOpenSubtitlesKey() async {
    return sharedPrefsSingleton.getString(OPENSUBTITLES_KEY) ??
        openSubtitlesKey;
  }

  setStreamServerFlixHQ(String value) async {
    sharedPrefsSingleton.setString(STREAM_SERVER_FLIXHQ, value);
  }

  Future<String> getStreamServerFlixHQ() async {
    return sharedPrefsSingleton.getString(STREAM_SERVER_FLIXHQ) ??
        STREAMING_SERVER_FLIXHQ;
  }

  setStreamServerDCVA(String value) async {
    sharedPrefsSingleton.setString(STREAM_SERVER_DCVA, value);
  }

  Future<String> getStreamServerDCVA() async {
    return sharedPrefsSingleton.getString(STREAM_SERVER_DCVA) ??
        STREAMING_SERVER_DCVA;
  }

  Future<bool> enableAD(bool enable) async {
    return enable;
  }

  Future<bool> enableTrendingHoliday(bool enable) async {
    return enable;
  }

  Future<String> getShowboxUrl() async {
    return sharedPrefsSingleton.getString(SHOWBOX_URL) ?? "";
  }

  setShowboxUrl(String value) async {
    sharedPrefsSingleton.setString(SHOWBOX_URL, value);
  }

  Future<String> getStreamRoute() async {
    return sharedPrefsSingleton.getString(STREAM_ROUTE) ?? 'flixHQ';
  }

  setStreamRoute(String value) async {
    sharedPrefsSingleton.setString(STREAM_ROUTE, value);
  }

  setStreamServerZoro(String value) async {
    sharedPrefsSingleton.setString(STREAM_SERVER_ZORO, value);
  }

  Future<String> getStreamServerZoro() async {
    return sharedPrefsSingleton.getString(STREAM_SERVER_ZORO) ??
        STREAMING_SERVER_ZORO;
  }

  setTmdbProxy(String value) async {
    sharedPrefsSingleton.setString(TMDB_PROXY, value);
  }

  Future<String> getTmdbProxy() async {
    return sharedPrefsSingleton.getString(TMDB_PROXY) ?? "";
  }
}
