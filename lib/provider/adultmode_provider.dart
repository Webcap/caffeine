
import 'package:flutter/cupertino.dart';
import 'package:login/models/adultmode_preferences.dart';

class AdultmodeProvider with ChangeNotifier {
  AdultModePreferences adultModePreferences = AdultModePreferences();
  bool _isAdult = false;
  bool get isAdult => _isAdult;

  set isAdult(bool value) {
    _isAdult = value;
    adultModePreferences.setAdultMode(value);
    notifyListeners();
  }
}
