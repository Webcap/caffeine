import 'package:shared_preferences/shared_preferences.dart';

class tvModePreferences {
  static const TV_MODE_STATUS = 'tvModeStatus';

  setTvMode(bool tvModeValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(TV_MODE_STATUS, tvModeValue);
  }

  Future<bool> getTVModeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(TV_MODE_STATUS) ?? false;
  }
}
