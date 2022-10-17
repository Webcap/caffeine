import 'package:flutter/material.dart';
import 'package:login/models/image_preferences.dart';

class ImagequalityProvider with ChangeNotifier {
  ImagePreferences imagePreferences = ImagePreferences();
  String _imageQuality = "w500/";
  String get imageQuality => _imageQuality;

  set imageQuality(String value) {
    _imageQuality = value;
    imagePreferences.setImageQuality(value);
    notifyListeners();
  }
}
