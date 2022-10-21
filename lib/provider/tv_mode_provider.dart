import 'package:flutter/material.dart';
import 'package:login/models/tv_mode_pref.dart';

class tvModeProvider with ChangeNotifier {
  tvModePreferences tvModePref = tvModePreferences();
  bool _tvModeValue = false;
  bool get tvModeValue => _tvModeValue;

  set tvModeValue(bool value) {
    _tvModeValue = value;
    tvModePref.setTvMode(value);
    notifyListeners();
  }
}
