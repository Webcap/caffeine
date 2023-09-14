// ignore_for_file: constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  static const CONSUMET_URL_KEY = "consumetUrlKey";
  static const CAFFIENE_LOGO_URL = "caffieneLogoUrl";

  setConsumetUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(CONSUMET_URL_KEY, value);
  }

  Future<String> getConsumetUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(CONSUMET_URL_KEY) ?? 'https://consumet.beamlak.dev';
  }

  setCaffieneUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(CAFFIENE_LOGO_URL, value);
  }

  Future<String> getCaffieneLogo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(CAFFIENE_LOGO_URL) ?? 'default';
  }
}
