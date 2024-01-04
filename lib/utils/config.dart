import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class appConfig {
  static const app_icon = "assets/logo.png";
  static const app_name = "caffeine";
}

String mixpanelKey = dotenv.env['MIXPANEL_API_KEY']!;

const Color darkmode = Colors.white;
const List<String> backimage = [
  'https://www.asianpaints.com/content/dam/asian_paints/colours/swatches/K085.png.transform/cc-width-720-height-540/image.png',
  'https://images.pexels.com/videos/3045163/free-video-3045163.jpg?auto=compress&cs=tinysrgb&dpr=1&w=500',
];

Color uppermodecolor = darkmode;
String selectedbackimg = backimage[1];
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
//********************************* */
// ** VERSION CONTROL BUDDY //
const String currentAppVersion = '1.5.0';
//*********************************** */

const kTextHeaderStyle = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 22,
);

const kBoldItemTitleStyle = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 19,
);

const kTextHeaderStyleTV = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 30,
  color: Colors.white,
);

const kTextVerySmallBodyStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  overflow: TextOverflow.ellipsis,
);

const kTextSmallBodyStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 17,
  overflow: TextOverflow.ellipsis,
);

const kTextSmallAboutBodyStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  overflow: TextOverflow.ellipsis,
);

const kTextStyleColorBlack = TextStyle(color: Colors.black);

const kTableLeftStyle =
    TextStyle(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold);

const String grid_landing_photo = "assets/images/grid_final.jpg";

final client = HttpClient();
const retryOptions = RetryOptions(
    maxDelay: Duration(milliseconds: 300),
    delayFactor: Duration(seconds: 0),
    maxAttempts: 100000);
const timeOut = Duration(seconds: 15);

final List<String> appNames = [
  'caffeine-v1.4.0.apk',
  'caffeine-v1.4.1.apk',
  'caffeine-v1.4.2.apk',
  'caffeine-v1.5.0.apk',
];

CacheManager cacheProp() {
  return CacheManager(
      Config('cacheKey', stalePeriod: const Duration(days: 10)));
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
