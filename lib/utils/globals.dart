import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global shared preferences instance initialized in main.dart
late SharedPreferences sharedPrefsSingleton;

/// Primary brand color used across the app (Crimson-style)
const Color maincolor = Color(0xFFDC2626);

/// Application name variants
const Map<String, String> appNames = {
  'default': 'Reelriot',
  'full': 'Reelriot Premium',
};

class _AppConfig {
  const _AppConfig();
  final String appIcon = 'assets/images/app_icon.jpg';
}

const appConfig = _AppConfig();
 
enum MediaType { movie, tvShow }
 
enum StreamRoute { flixHQ, tmDB }
