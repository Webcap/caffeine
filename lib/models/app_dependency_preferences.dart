// ignore_for_file: constant_identifier_names

import 'package:caffiene/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  static const CONSUMET_URL_KEY = "consumetUrlKey";
  static const CAFFIENE_LOGO_URL = "caffieneLogoUrl";
  static const STREAM_SERVER_FLIXHQ = "vidcloud";
  static const STREAM_SERVER_DCVA = "asianload";
  static const OPENSUBTITLES_KEY = "opensubtitlesKey";
  static const SHOWBOX_URL = "showbox_url";
  static const STREAM_ROUTE = "streamRoute";
  static const CAFFEINE_API_URL = "caffeineAPIURL";

  setConsumetUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(CONSUMET_URL_KEY, value);
  }

  Future<String> getConsumetUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(CONSUMET_URL_KEY) ??
        'https://consumet-api-beryl.vercel.app/';
  }

  setCaffieneUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(CAFFIENE_LOGO_URL, value);
  }

  Future<String> getFQURL() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(CAFFEINE_API_URL) ??
        'https://flixquest-api.beamlak.dev';
  }

  setCaffeineAPIUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(CAFFEINE_API_URL, value);
  }

  Future<String> getCaffieneLogo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(CAFFIENE_LOGO_URL) ?? 'default';
  }

  setOpenSubKey(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(OPENSUBTITLES_KEY, value);
  }

  Future<String> getOpenSubtitlesKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(OPENSUBTITLES_KEY) ?? openSubtitlesKey;
  }

  setStreamServerFlixHQ(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(STREAM_SERVER_FLIXHQ, value);
  }

  Future<String> getStreamServerFlixHQ() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(STREAM_SERVER_FLIXHQ) ?? STREAMING_SERVER_FLIXHQ;
  }

  setStreamServerDCVA(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(STREAM_SERVER_DCVA, value);
  }

  Future<String> getStreamServerDCVA() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(STREAM_SERVER_DCVA) ?? STREAMING_SERVER_DCVA;
  }

  Future<bool> enableAD(bool enable) async {
    return enable;
  }

  Future<bool> enableTrendingHoliday(bool enable) async {
    return enable;
  }

  Future<String> getShowboxUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SHOWBOX_URL) ?? "";
  }

  setShowboxUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SHOWBOX_URL, value);
  }

  Future<String> getStreamRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(STREAM_ROUTE) ?? 'flixHQ';
  }

  setStreamRoute(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(STREAM_ROUTE, value);
  }
}
