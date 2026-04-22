import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:retry/retry.dart';

const String TMDB_API_BASE_URL = "https://api.themoviedb.org/3";
String get TMDB_API_KEY => dotenv.env['TMDB_API_KEY'] ?? '';
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

/// Deprecated: Update flow is API-driven via GET /config (fetchUpdateInfoFromApi). Kept for optional fallback only.
@Deprecated(
    'Use API config (update_download_url, update_store_url, latest_version) via fetchUpdateInfoFromApi')
const String CAFFEINE_UPDATE_URL =
    "https://webcap.github.io/caffiene/res/update.json";
const String ERROROCCURRED = "an error has occurred";

/// Default production Caffeine API URL. Used when .env is unset or stored URL is a Vercel preview.
const String DEFAULT_CAFFEINE_API_URL = 'https://caffeine.synqholdings.com/';

/// Standard desktop browser User-Agent for scraper compatibility.
const String BROWSER_USER_AGENT =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

/// True if [url] is a Vercel preview deployment (e.g. caffeine-xxx-projects.vercel.app).
bool isCaffeineApiPreviewUrl(String url) {
  final host = Uri.tryParse(url)?.host ?? '';
  return host.contains('projects.vercel.app');
}

//API KEYS - lazy getters so dotenv is loaded first
String get CONSUMET_API => dotenv.env['CONSUMET_URL'] ?? '';
String get CONSUMET_INFO_API => dotenv.env['CONSUMET_URL'] ?? '';
String get caffeineApiUrl =>
    dotenv.env['CAFFEINE_API_URL'] ?? DEFAULT_CAFFEINE_API_URL;

/// API key for authenticating with the Caffeine API.
String get caffeineApiKey => dotenv.env['CAFFEINE_API_KEY'] ?? '';

/// Headers to attach to every Caffeine API request.
/// Includes the Authorization bearer token when a key is configured.
Map<String, String> get caffeineApiHeaders {
  final headers = <String, String>{
    'User-Agent': BROWSER_USER_AGENT,
  };
  final key = caffeineApiKey;
  if (key.isNotEmpty) {
    headers['Authorization'] = 'Bearer $key';
  }
  return headers;
}

String get vidSrcApi => dotenv.env['VIDSRC_API'] ?? '';

// RevenueCat (Keys now provided via API config)
String get revenueCatApiKeyAndroid =>
    dotenv.env['REVENUECAT_PUBLIC_SDK_KEY_ANDROID'] ?? '';
String get revenueCatApiKeyIOS =>
    dotenv.env['REVENUECAT_PUBLIC_SDK_KEY_IOS'] ?? '';
String get revenueCatEntitlementId =>
    dotenv.env['REVENUECAT_ENTITLEMENT_ID'] ?? 'premium';

/// FlixAPI is fully merged into Caffeine API; always use the main API URL.
String get flixApiUrl => caffeineApiUrl;
String get flixhqNewUrl => dotenv.env['FLIXHQ_NEW_URL'] ?? '';
String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
const String STREAMING_SERVER = "vidcloud";
String get openSubtitlesKey => dotenv.env['OPENSUBTITLES_API_KEY'] ?? '';
//VIDEO PROVIDERS//
const String STREAMING_SERVER_FLIXHQ = "vidcloud";
const String STREAMING_SERVER_DCVA = "asianload";
const String STREAMING_SERVER_ZORO = "vidcloud";
const String STREAMING_SERVER_NEW_FLIXHQ = "megacloud";


const retryOptionsStream = RetryOptions(
    maxDelay: Duration(milliseconds: 300),
    delayFactor: Duration(seconds: 0),
    maxAttempts: 1);
const timeOutStream = Duration(seconds: 15);


bool enabled = true;

/// easy localization run command
// flutter pub run easy_localization:generate -S assets/translations -f keys -O lib/translations -o locale_keys.g.dart
