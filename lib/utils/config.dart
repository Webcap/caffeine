import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class appConfig {
  static const app_icon = "assets/logo.png";
  static const app_name = "caffeine";
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

//********************************* */
// ** VERSION CONTROL BUDDY //
const String currentAppVersion = '1.6.2';
//*********************************** */

const kTextHeaderStyle = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 22,
);

final kApiUrl = GetPlatform.isAndroid ? 'http://144.62.246.54:4242' : 'http://localhost:4242';

final client = HttpClient();
const retryOptions = RetryOptions(
    maxDelay: Duration(milliseconds: 300),
    delayFactor: Duration(seconds: 0),
    maxAttempts: 100000);
const timeOut = Duration(seconds: 15);

final List<String> appNames = [
  'caffeine-v1.5.0.apk',
  'caffeine-v1.6.0.apk',
  'caffeine-v1.6.0-6.apk',
  'caffeine-v1.6.1.apk',
  'caffeine-v1.6.2.apk',
];

CacheManager cacheProp() {
  return CacheManager(
      Config('cacheKey', stalePeriod: const Duration(days: 15)));
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
