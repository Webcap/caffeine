import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:retry/retry.dart';

const String TMDB_API_BASE_URL = "https://api.themoviedb.org/3";
String TMDB_API_KEY = dotenv.env['TMDB_API_KEY']!;
const TMDB_BASE_IMAGE_URL = "https://image.tmdb.org/t/p/";
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
const String ERROROCCURRED = "an error has occurred";

//API KEYS//
String CONSUMET_API = dotenv.env['CONSUMET_URL']!;
String CONSUMET_INFO_API = dotenv.env['CONSUMET_URL']!;
String caffeineApiUrl = dotenv.env['CAFFEINE_API_URL']!;
const String SUPABASE_URL = 'https://quzrpdvpbnydfjzigcoi.supabase.co';
const String STREAMING_SERVER = "vidcloud";
String openSubtitlesKey = dotenv.env['OPENSUBTITLES_API_KEY']!;
String mixpanelKey = dotenv.env['MIXPANEL_API_KEY']!;
String stripeSecret = dotenv.env['STRIPE_SECRET']!;
String stripePublic = dotenv.env['STRIPE_PUBLIC']!;

//VIDEO PROVIDERS//
const String STREAMING_SERVER_FLIXHQ = "vidcloud";
const String STREAMING_SERVER_DCVA = "asianload";
const String STREAMING_SERVER_ZORO = "vidcloud";

const providerPreference =
    'flixhq-FlixHQ showbox-ShowBox vidsrcto-VidSrcTo vidsrc-VidSrc gomovies-GoMovies flixhqS2-FlixHQ_S2 zoe-Zoechip zoro-Zoro dramacool-Dramacool viewasian-ViewAsian';

const retryOptionsStream = RetryOptions(
    maxDelay: Duration(milliseconds: 300),
    delayFactor: Duration(seconds: 0),
    maxAttempts: 1);
const timeOutStream = Duration(seconds: 15);

class AppStaticData {
  static const List<String> subscriptionCardFeaturesTitle = [
    'Watch all you want. Ad-free.',
    'Allows streaming of 4K.',
    'Video & Audio Quality is Better.',
    'Live TV',
    '24/7 Customer Support.'
  ];
}

bool enabled = true;

/// easy localization run command
// flutter pub run easy_localization:generate -S assets/translations -f keys -O lib/translations -o locale_keys.g.dart