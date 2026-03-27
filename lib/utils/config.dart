import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caffiene/utils/flavor_config.dart';

part 'app_version.g.dart';

class appConfig {
  static const app_icon = "assets/logo.png";
  static String get app_name => FlavorConfig.instance.appName;
}

const Color darkmode = Colors.white;
Color uppermodecolor = darkmode;
Color oppositecolor = Colors.black;

const maincolor = Color(0xfffea575e);
const maincolor2 = Color(0xfff371124);
const maincolor3 = Color(0xfff832f3c);
const maincolor4 = Color(0xfff501b2c);

const kTextSmallHeaderStyle = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 17,
  overflow: TextOverflow.ellipsis,
);

const kTextHeaderStyle = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 22,
);

final kApiUrl = FlavorConfig.instance.baseUrl;

final client = HttpClient();
const retryOptions = RetryOptions(
    maxDelay: Duration(milliseconds: 300),
    delayFactor: Duration(seconds: 0),
    maxAttempts: 100000);
const timeOut = Duration(seconds: 15);

final List<String> appNames = [
  'caffeine-v1.6.5.apk',
  'caffeine-v1.7.0.apk',
  'caffeine-v1.7.1.apk',
];

CacheManager cacheProp() {
  return CacheManager(Config('cacheKey',
      stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 500));
}

enum MediaType { movie, tvShow }

enum StreamRoute { flixHQ, tmDB }

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

late SharedPreferences sharedPrefsSingleton;

final DateFormat formatter = DateFormat('MM-dd-yyyy');
