import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:retry/retry.dart';

const String TMDB_API_BASE_URL = "https://api.themoviedb.org/3";
String TMDB_API_KEY = 'b9c827ddc7e3741ed414d8731814ecc9';
const String TMDB_BASE_IMAGE_URL = "https://image.tmdb.org/t/p/";
const String EMBED_BASE_MOVIE_URL =
    "https://www.2embed.to/embed/tmdb/movie?id=";
const String EMBED_BASE_TV_URL = "https://www.2embed.to/embed/tmdb/tv?id=";
const String YOUTUBE_THUMBNAIL_URL = "https://i3.ytimg.com/vi/";
const String YOUTUBE_BASE_URL = "https://youtube.com/watch?v=";
const String FACEBOOK_BASE_URL = "https://facebook.com/";
const String INSTAGRAM_BASE_URL = "https://instagram.com/";
const String TWITTER_BASE_URL = "https://twitter.com/";
const String IMDB_BASE_URL = "https://imdb.com/title/";
const String TWOEMBED_BASE_URL = "https://2embed.biz";
const String opensubtitlesBaseUrl = "https://api.opensubtitles.com/api/v1";
const String CAFFEINE_UPDATE_URL =
    "https://webcap.github.io/caffiene/res/update.json";
const String TAG_LINE1 = "Unlimted, for free, anytime on Caffeine";
const String SIGN_IN = "Log In";
const String SIGN_UP = "Sign Up";
const String ERROROCCURRED = "an error has occurred";
const String CONSUMET_API = 'https://consumet-api-1p19.onrender.com/';
const String CONSUMET_INFO_API = 'https://consumet-api-1p19.onrender.com/';
const String PROCESSING_VIDEO = "Please Wait while we process the video";
const String STREAMING_SERVER = "vidcloud";
const String openSubtitlesKey = "v2D7GUfWFY8RQeWExzCqMla7P16Pq5zE";

final client = HttpClient();

class appConfig {
  static const app_icon = "assets/logo.png";
  static const app_name = "caffeine";
}

String mixpanelKey = "c8ff0b487c27b501b6524084dc0b83a9";

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

const bool showAds = false;

const kTextSmallHeaderStyle = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 17,
  overflow: TextOverflow.ellipsis,
);

const String currentAppVersion = '1.3.1-dev';

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
const retryOptions = RetryOptions(
    maxDelay: Duration(milliseconds: 300),
    delayFactor: Duration(seconds: 0),
    maxAttempts: 100000);
const timeOut = Duration(seconds: 10);

final List<String> appNames = [
  'caffiene-v1.3.0-dev.apk',
  'caffiene-v1.3.0.apk',
  'caffiene-v1.3.1.apk',
];

CacheManager cacheProp() {
  return CacheManager(
      Config('cacheKey', stalePeriod: const Duration(days: 10)));
}

enum MediaType { movie, tvShow }

enum StreamRoute { flixHQ, tmDB }