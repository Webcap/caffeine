import 'package:flutter/material.dart';

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
const String CAFFEINE_UPDATE_URL = "coming soon";

class Config {
  static final app_icon = "assets/logo.png";
}

String mixpanelKey = "4e597266d3068a1a7951bd1d1631637d";

const Color darkmode = Colors.white;
const List<String> backimage = [
  'https://www.asianpaints.com/content/dam/asian_paints/colours/swatches/K085.png.transform/cc-width-720-height-540/image.png',
  'https://images.pexels.com/videos/3045163/free-video-3045163.jpg?auto=compress&cs=tinysrgb&dpr=1&w=500',
];

late Color uppermodecolor = darkmode;
late String selectedbackimg = backimage[1];
late Color oppositecolor = Colors.black;

const maincolor = Color(0xFFFea575e);
const maincolor2 = Color(0xFFF371124);
const maincolor3 = Color(0xFFF832f3c);
const maincolor4 = Color(0xFFF501b2c);

const kTextSmallHeaderStyle = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 17,
  overflow: TextOverflow.ellipsis,
);

const String currentAppVersion = '1.0.0';

const kTextHeaderStyle = TextStyle(
  //fontFamily: 'PoppinsSB',
  fontSize: 22,
);

const kTextHeaderStyleTV = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 30,
  color: Colors.white,
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

const kTableLeftStyle =
    TextStyle(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold);

