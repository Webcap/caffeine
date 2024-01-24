import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:retry/retry.dart';

const String TMDB_API_BASE_URL = "https://api.themoviedb.org/3";
String TMDB_API_KEY = dotenv.env['TMDB_API_KEY']!;
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
const String ERROROCCURRED = "an error has occurred";
String CONSUMET_API = dotenv.env['CONSUMET_URL']!;
String CONSUMET_INFO_API = dotenv.env['CONSUMET_URL']!;
String caffeineApiUrl = dotenv.env['CAFFEINE_API_URL']!;
const String SUPABASE_URL = 'https://quzrpdvpbnydfjzigcoi.supabase.co';
const String STREAMING_SERVER = "vidcloud";
String openSubtitlesKey = dotenv.env['OPENSUBTITLES_API_KEY']!;

const String STREAMING_SERVER_FLIXHQ = "vidcloud";
const String STREAMING_SERVER_DCVA = "asianload";
const String STREAMING_SERVER_ZORO = "vidcloud";

const providerPreference =
    'flixhqS2-FlixHQ_S2 superstream-Superstream flixhq-FlixHQ viewasian-ViewAsian dramacool-Dramacool zoro-Zoro ';

const retryOptionsStream = RetryOptions(
    maxDelay: Duration(milliseconds: 300),
    delayFactor: Duration(seconds: 0),
    maxAttempts: 1);
const timeOutStream = Duration(seconds: 15);
