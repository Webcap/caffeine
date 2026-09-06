import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/models/custom_exceptions.dart';
import 'package:reelriot/utils/constant.dart' hide browserUserAgent;
import 'package:reelriot/utils/network_utils.dart';

import '../models/external_subtitles.dart';
import '../models/movie_models.dart';
import '../utils/config.dart';
import '../video_providers/flixapi_multi.dart';

import '/models/images.dart';
import '/models/person.dart';
import '/models/tv.dart';
import '/models/videos.dart';
import '/models/watch_providers.dart';
import 'package:http/http.dart' as http;
import '/models/credits.dart';
import '/models/genres.dart';
import '../models/espn_scoreboard.dart';
import '../models/live_tv.dart';

Future<List<Movie>> fetchMovies(
    String api, bool isProxyEnabled, String proxyUrl) async {
  MovieList movieList;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    movieList = MovieList.fromJson(decodeRes);
  } finally {
    // No-op: Do not close the global client
  }

  return movieList.movies ?? [];
}

Future<List<Movie>> fetchCollectionMovies(
    String api, bool isProxyEnabled, String proxyUrl) async {
  CollectionMovieList collectionMovieList;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    collectionMovieList = CollectionMovieList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return collectionMovieList.movies ?? [];
}

Future fetchCollectionDetails(
    String api, bool isProxyEnabled, String proxyUrl) async {
  CollectionDetails collectionDetails;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    collectionDetails = CollectionDetails.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return collectionDetails;
}

Future<List<Movie>> fetchPersonMovies(
    String api, bool isProxyEnabled, String proxyUrl) async {
  PersonMoviesList personMoviesList;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    personMoviesList = PersonMoviesList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return personMoviesList.movies ?? [];
}

Future<Images> fetchImages(
    String api, bool isProxyEnabled, String proxyUrl) async {
  Images images;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    images = Images.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return images;
}

Future<PersonImages> fetchPersonImages(
    String api, bool isProxyEnabled, String proxyUrl) async {
  PersonImages personImages;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    personImages = PersonImages.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return personImages;
}

Future<Videos> fetchVideos(
    String api, bool isProxyEnabled, String proxyUrl) async {
  Videos videos;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    videos = Videos.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return videos;
}

Future<Credits> fetchCredits(
    String api, bool isProxyEnabled, String proxyUrl) async {
  Credits credits;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    credits = Credits.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return credits;
}

Future<List<Person>> fetchPerson(
    String api, bool isProxyEnabled, String proxyUrl) async {
  PersonList credits;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    credits = PersonList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return credits.person ?? [];
}

Future<List<Genres>> fetchGenre(
    String api, bool isProxyEnabled, String proxyUrl) async {
  GenreList newGenreList;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    newGenreList = GenreList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return newGenreList.genre ?? [];
}

Future<ExternalLinks> fetchSocialLinks(
    String api, bool isProxyEnabled, String proxyUrl) async {
  ExternalLinks externalLinks;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    externalLinks = ExternalLinks.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return externalLinks;
}

Future fetchBelongsToCollection(
    String api, bool isProxyEnabled, String proxyUrl) async {
  BelongsToCollection belongsToCollection;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    belongsToCollection = BelongsToCollection.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return belongsToCollection;
}

Future<Moviedetail> fetchMovieDetails(
    String api, bool isProxyEnabled, String proxyUrl) async {
  Moviedetail movieDetails;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    movieDetails = Moviedetail.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return movieDetails;
}
// Future<Credits> fetchPerson(String api) async {
//   Credits credits;
//   var res = await http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent});
//   var decodeRes = jsonDecode(res.body);
//   credits = Credits.fromJson(decodeRes);
//   return credits;
// }

Future<PersonDetails> fetchPersonDetails(
    String api, bool isProxyEnabled, String proxyUrl) async {
  PersonDetails personDetails;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    personDetails = PersonDetails.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return personDetails;
}

Future<WatchProviders> fetchWatchProviders(
    String api, String country, bool isProxyEnabled, String proxyUrl) async {
  WatchProviders watchProviders;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    watchProviders = WatchProviders.fromJson(decodeRes, country);
  } finally {
    client.close();
  }
  return watchProviders;
}

Future<List<TV>> fetchTV(
    String api, bool isProxyEnabled, String proxyUrl) async {
  TVList tvList;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    tvList = TVList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return tvList.tvSeries ?? [];
}

Future<TVDetails> fetchTVDetails(
    String api, bool isProxyEnabled, String proxyUrl) async {
  TVDetails tvDetails;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    tvDetails = TVDetails.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return tvDetails;
}

Future<List<TV>> fetchPersonTV(
    String api, bool isProxyEnabled, String proxyUrl) async {
  PersonTVList personTVList;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    personTVList = PersonTVList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return personTVList.tv ?? [];
}

Future<Movie> getMovie(String api, bool isProxyEnabled, String proxyUrl) async {
  Movie movie;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    movie = Movie.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return movie;
}

Future<TV> getTV(String api, bool isProxyEnabled, String proxyUrl) async {
  TV tv;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty && !api.startsWith(proxyUrl)) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {'User-Agent': browserUserAgent}).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    tv = TV.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return tv;
}

Future<String> getVttFileAsString(String url) async {
  try {
    var response = await retryOptions.retry(
      () => http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'caffiene v2.0.0',
        },
      ),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final decoded = utf8.decode(bytes);
      if (decoded.startsWith('<')) {
        return '';
      } else {
        return decoded;
      }
    } else {
      return "";
    }
  } catch (e) {
    rethrow;
  }
}


const String _espnNbaScoreboardUrl =
    'https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard';

class _EspnLeagueConfig {
  const _EspnLeagueConfig(
      this.sport, this.league, this.sportLabel, this.leagueLabel);
  final String sport;
  final String league;
  final String sportLabel;
  final String leagueLabel;
}

const List<_EspnLeagueConfig> _espnLeagues = [
  _EspnLeagueConfig('basketball', 'nba', 'Basketball', 'NBA'),
  _EspnLeagueConfig('basketball', 'wnba', 'Basketball', 'WNBA'),
  _EspnLeagueConfig('basketball', 'mens-college-basketball', 'Basketball', 'NCAAM'),
  _EspnLeagueConfig('basketball', 'womens-college-basketball', 'Basketball', 'NCAAW'),
  _EspnLeagueConfig('football', 'nfl', 'NFL', 'NFL'),
  _EspnLeagueConfig('football', 'college-football', 'NCAAF', 'NCAAF'),
  _EspnLeagueConfig('baseball', 'mlb', 'Baseball', 'MLB'),
  _EspnLeagueConfig('hockey', 'nhl', 'Hockey', 'NHL'),
  _EspnLeagueConfig('mma', 'ufc', 'MMA', 'UFC'),
  // --- Club Leagues ---
  _EspnLeagueConfig('soccer', 'eng.1', 'Soccer', 'EPL'),
  _EspnLeagueConfig('soccer', 'esp.1', 'Soccer', 'La Liga'),
  _EspnLeagueConfig('soccer', 'ger.1', 'Soccer', 'Bundesliga'),
  _EspnLeagueConfig('soccer', 'ita.1', 'Soccer', 'Serie A'),
  _EspnLeagueConfig('soccer', 'fra.1', 'Soccer', 'Ligue 1'),
  _EspnLeagueConfig('soccer', 'ned.1', 'Soccer', 'Eredivisie'),
  _EspnLeagueConfig('soccer', 'por.1', 'Soccer', 'Primeira Liga'),
  _EspnLeagueConfig('soccer', 'usa.1', 'Soccer', 'MLS'),
  _EspnLeagueConfig('soccer', 'mex.1', 'Soccer', 'Liga MX'),
  _EspnLeagueConfig('soccer', 'uefa.champions', 'Soccer', 'Champions League'),
  _EspnLeagueConfig('soccer', 'uefa.europa', 'Soccer', 'Europa League'),
  _EspnLeagueConfig('soccer', 'uefa.europa.conf', 'Soccer', 'Conference League'),
  // --- International / FIFA tournaments ---
  _EspnLeagueConfig('soccer', 'fifa.world', 'Soccer', 'FIFA World Cup'),
  _EspnLeagueConfig('soccer', 'fifa.cwc', 'Soccer', 'Club World Cup'),
  _EspnLeagueConfig('soccer', 'fifa.friendly', 'Soccer', 'Int\'l Friendlies'),
  _EspnLeagueConfig('soccer', 'fifa.worldq.concacaf', 'Soccer', 'WC Qual. CONCACAF'),
  _EspnLeagueConfig('soccer', 'fifa.worldq.conmebol', 'Soccer', 'WC Qual. CONMEBOL'),
  _EspnLeagueConfig('soccer', 'fifa.worldq.uefa', 'Soccer', 'WC Qual. UEFA'),
  // --- UEFA & Confederation tournaments ---
  _EspnLeagueConfig('soccer', 'uefa.euro', 'Soccer', 'UEFA Euro'),
  _EspnLeagueConfig('soccer', 'uefa.euroq', 'Soccer', 'Euro Qualifiers'),
  _EspnLeagueConfig('soccer', 'uefa.nations', 'Soccer', 'UEFA Nations League'),
  _EspnLeagueConfig('soccer', 'concacaf.gold', 'Soccer', 'CONCACAF Gold Cup'),
  _EspnLeagueConfig('soccer', 'concacaf.nations.league', 'Soccer', 'CONCACAF Nations'),
  _EspnLeagueConfig('soccer', 'conmebol.america', 'Soccer', 'Copa América'),
  _EspnLeagueConfig('soccer', 'conmebol.libertadores', 'Soccer', 'Copa Libertadores'),
];

/// Fetches ESPN scoreboard for a league on a date (prefers Caffeine API with direct fallback).
Future<EspnScoreboardResponse?> fetchEspnScoreboard(
    String sport, String league, DateTime date, {String? caffeineBaseUrl}) async {
  try {
    final String url = caffeineBaseUrl != null && caffeineBaseUrl.trim().isNotEmpty
        ? Endpoints.getCaffeineScoreboardUrl(caffeineBaseUrl, sport: sport, league: league, date: date)
        : Endpoints.getEspnScoreboardUrl(sport, league, date);
    final res = await http.get(Uri.parse(url), headers: caffeineApiHeaders).timeout(const Duration(seconds: 8));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return EspnScoreboardResponse.fromJson(decoded);
      }
    }
    
    // Direct ESPN fallback if Caffeine API returned non-200
    final fallbackUrl = Endpoints.getEspnScoreboardUrl(sport, league, date);
    final fallbackRes = await http.get(Uri.parse(fallbackUrl)).timeout(const Duration(seconds: 8));
    if (fallbackRes.statusCode == 200) {
      final decodedFallback = jsonDecode(fallbackRes.body);
      if (decodedFallback is Map<String, dynamic>) {
        return EspnScoreboardResponse.fromJson(decodedFallback);
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}

/// Fetches events for the date across multiple leagues and merges into EspnListEvent list.
/// [date] should be in the user's local timezone (e.g. DateTime.now()) so "today" matches their calendar.
Future<List<EspnListEvent>> fetchEspnEventsForDayMultiLeague(
    DateTime date) async {
  debugPrint(
      '[ESPN] multi-league fetch for ${date.year}-${date.month}-${date.day} (local date)');
  final futures = _espnLeagues
      .map((l) => fetchEspnScoreboard(l.sport, l.league, date).then((r) =>
          r?.games
              .map((g) => EspnListEvent(
                    game: g,
                    sport: l.sportLabel,
                    league: l.leagueLabel,
                  ))
              .toList() ??
          <EspnListEvent>[]));
  final results = await Future.wait(futures);
  final merged = <EspnListEvent>[];
  final seen = <String>{};
  for (final list in results) {
    for (final ev in list) {
      if (ev.game.id.isNotEmpty && seen.add(ev.game.id)) {
        // Safety: verify the game's actual start date (local) matches the requested date.
        // This prevents out-of-season leagues from leaking "relevant" games.
        if (ev.game.startTimeUtc != null) {
          final gameDate = ev.game.startTimeUtc!.toLocal();
          if ((gameDate.year == date.year &&
                  gameDate.month == date.month &&
                  gameDate.day == date.day) ||
              ev.game.isActuallyLive) {
            merged.add(ev);
          }
        } else {
          // If no start time, we trust the API returned it for this date request.
          merged.add(ev);
        }
      }
    }
  }
  merged.sort((a, b) {
    final ta = a.game.timeOrStatus ?? '';
    final tb = b.game.timeOrStatus ?? '';
    return ta.compareTo(tb);
  });
  debugPrint('[ESPN] multi-league merged total: ${merged.length} events');
  return merged;
}

/// Fetches NBA scoreboard from ESPN API. Returns null on failure.
Future<EspnScoreboardResponse?> fetchNbaScoreboard() async {
  try {
    final res = await http
        .get(Uri.parse(_espnNbaScoreboardUrl))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) return null;
    return EspnScoreboardResponse.fromJson(decoded);
  } catch (_) {
    return null;
  }
}

Future<List<SubtitleData>> getExternalSubtitle(String api, String key) async {
  ExternalSubtitle subData;

  try {
    debugPrint('[OpenSubtitles Search] Request: $api');
    debugPrint('[OpenSubtitles Search] API Key present: ${key.isNotEmpty}');
    final headers = {
      "Api-Key": key,
      'User-Agent': 'caffiene v2.0.0',
      'X-User-Agent': 'caffiene v2.0.0',
      'Accept': 'application/json',
    };
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: headers).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    debugPrint('[OpenSubtitles Search] Status: ${res.statusCode}');
    
    dynamic decodeRes;
    try {
      decodeRes = jsonDecode(res.body);
    } catch (e) {
      debugPrint('[OpenSubtitles Search] JSON Decode Failed. Body preview: ${res.body.substring(0, min(500, res.body.length))}');
      rethrow;
    }

    if (res.statusCode != 200 || (decodeRes is Map && decodeRes.containsKey('message'))) {
      throw ServerDownException();
    }
    subData = ExternalSubtitle.fromJson(decodeRes);
  } catch (e) {
    debugPrint('[OpenSubtitles Search] Error: $e');
    rethrow;
  }

  return subData.data ?? [];
}

Future<SubtitleDownload> downloadExternalSubtitle(
    String api, int fileId, String key) async {
  SubtitleDownload sub;
  debugPrint('[OpenSubtitles Download] Request: $api | file_id: $fileId');
  debugPrint('[OpenSubtitles Download] API Key present: ${key.isNotEmpty}');
  final Map<String, String> headers = {
    'User-Agent': 'caffiene v2.0.0',
    'X-User-Agent': 'caffiene v2.0.0',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Api-Key': key
  };
  var body = '{"file_id":$fileId}';
  try {
    var response = await retryOptions.retry(
      () => http.post(Uri.parse(api), headers: headers, body: body),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    
    debugPrint('[OpenSubtitles Download] Status: ${response.statusCode}');
    
    dynamic decodeRes;
    try {
      decodeRes = jsonDecode(response.body);
    } catch (e) {
      debugPrint('[OpenSubtitles Download] JSON Decode Failed. Body preview: ${response.body.substring(0, min(500, response.body.length))}');
      rethrow;
    }
    
    sub = SubtitleDownload.fromJson(decodeRes);
  } catch (e) {
    debugPrint('[OpenSubtitles Download] Error: $e');
    rethrow;
  } finally {
    client.close();
  }

  return sub;
}

/// FlixAPI Multi-provider (vixsrc, vidfun, vidlink, etc.)
Future<FlixAPIMultiResponse> getStreamLinksFlixAPIMulti(String api) async {
  try {
    debugPrint('[Network] fetching stream links from $api');
    final response = await http
        .get(Uri.parse(api), headers: caffeineApiHeaders)
        .timeout(timeOutStream);

    if (response.statusCode == 500) throw ServerDownException();
    if (response.statusCode != 200 || response.body.isEmpty) {
      throw NotFoundException();
    }

    final dynamic decodeRes = jsonDecode(response.body);
    if (decodeRes is! Map ||
        decodeRes['success'] == false ||
        decodeRes['error'] != null ||
        decodeRes['links'] == null ||
        (decodeRes['links'] as List).isEmpty) {
      throw NotFoundException();
    }

    final videoSources = FlixAPIMultiResponse.fromJson(decodeRes as Map<String, dynamic>);
    if (videoSources.links == null || videoSources.links!.isEmpty) {
      throw NotFoundException();
    }

    return videoSources;
  } catch (e) {
    debugPrint('[Network] Stream resolution error for $api: $e');
    rethrow;
  }
}
