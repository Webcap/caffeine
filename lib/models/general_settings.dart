import 'package:shared_preferences/shared_preferences.dart';

class GeneralSettingsPreferences {
  static const SUBTITLES = "subtitleStatus";

  setSubtitleStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(SUBTITLES, value);
  }

  Future<bool> getSubtitleStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SUBTITLES) ?? false;
  }
}
