import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/models/custom_exceptions.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/video_providers/caffeine_api_source.dart';
import 'package:caffiene/video_providers/dcva.dart';
import 'package:caffiene/video_providers/flixhq.dart';

import '../models/external_subtitles.dart';
import '../models/movie_models.dart';
import '../utils/config.dart';
import '../video_providers/dramacool.dart';
import '../video_providers/flixapi_multi.dart';
import '../video_providers/zoro.dart';

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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    movieList = MovieList.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return movieList.movies ?? [];
}

Future<List<Movie>> fetchCollectionMovies(
    String api, bool isProxyEnabled, String proxyUrl) async {
  CollectionMovieList collectionMovieList;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
//   var res = await http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT});
//   var decodeRes = jsonDecode(res.body);
//   credits = Credits.fromJson(decodeRes);
//   return credits;
// }

Future<PersonDetails> fetchPersonDetails(
    String api, bool isProxyEnabled, String proxyUrl) async {
  PersonDetails personDetails;
  try {
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut)),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut),
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
    if (isProxyEnabled && proxyUrl.isNotEmpty) {
      api = "$proxyUrl?destination=$api";
    }
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOut),
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

Future<Channels> fetchChannels(String api) async {
  try {
    final res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    if (res.statusCode != 200) {
      throw ChannelsNotFoundException();
    }
    final decodeRes = jsonDecode(res.body);
    if (decodeRes is! Map<String, dynamic>) {
      throw ChannelsNotFoundException();
    }
    return Channels.fromJson(decodeRes);
  } catch (e) {
    rethrow;
  } finally {
    client.close();
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
  _EspnLeagueConfig('football', 'nfl', 'American Football', 'NFL'),
  _EspnLeagueConfig('baseball', 'mlb', 'Baseball', 'MLB'),
  _EspnLeagueConfig('mma', 'ufc', 'MMA', 'UFC'),
];

/// Fetches ESPN scoreboard for a league on a date.
Future<EspnScoreboardResponse?> fetchEspnScoreboard(
    String sport, String league, DateTime date) async {
  try {
    final url = Endpoints.getEspnScoreboardUrl(sport, league, date);
    final res =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) return null;
    return EspnScoreboardResponse.fromJson(decoded);
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

Future<List<DCVASearchEntry>> fetchMovieTVForStreamDCVA(String api) async {
  DCVASearch dcvaStream;
  print(api);
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    dcvaStream = DCVASearch.fromJson(decodeRes);

    if (dcvaStream.results == null || dcvaStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return dcvaStream.results ?? [];
}

Future<List<DCVAInfoEntries>> getMovieTVStreamEpisodesDCVA(String api) async {
  DCVAInfo dcvaInfo;
  print(api);
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    dcvaInfo = DCVAInfo.fromJson(decodeRes);

    if (dcvaInfo.episodes == null || dcvaInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }

  return dcvaInfo.episodes ?? [];
}

Future<DCVAStreamSources> getMovieTVStreamLinksAndSubsDCVA(String api) async {
  DCVAStreamSources dcvaVideoSources;
  int tries = 3;
  dynamic decodeRes;
  print(api);
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    dcvaVideoSources = DramacoolStreamSources.fromJson(decodeRes);

    if (dcvaVideoSources.videoLinks == null ||
        dcvaVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return dcvaVideoSources;
}

Future<List<ZoroSearchEntry>> fetchMovieTVForStreamZoro(String api) async {
  ZoroSearch zoroStream;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);

    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }

    zoroStream = ZoroSearch.fromJson(decodeRes);
    if (zoroStream.results == null || zoroStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return zoroStream.results ?? [];
}

Future<List<ZoroInfoEntries>> getMovieTVStreamEpisodesZoro(String api) async {
  ZoroInfo zoroInfo;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);

    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    zoroInfo = ZoroInfo.fromJson(decodeRes);

    if (zoroInfo.episodes == null || zoroInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }

  return zoroInfo.episodes ?? [];
}

Future<ZoroStreamSources> getMovieTVStreamLinksAndSubsZoro(String api) async {
  ZoroStreamSources zoroVideoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    zoroVideoSources = ZoroStreamSources.fromJson(decodeRes);

    if (zoroVideoSources.videoLinks == null ||
        zoroVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return zoroVideoSources;
}

Future<CaffeineAPIStreamSources> getCaffeineAPILinks(String api) async {
  CaffeineAPIStreamSources fqAPIStreamSources;
  int tries = 3;
  dynamic decodeRes;
  print(api);
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    fqAPIStreamSources = CaffeineAPIStreamSources.fromJson(decodeRes);

    if (fqAPIStreamSources.videoLinks == null ||
        fqAPIStreamSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return fqAPIStreamSources;
}

/// FlixAPI Multi-provider (vixsrc, pstream, showbox)
Future<FlixAPIMultiResponse> getStreamLinksFlixAPIMulti(String api) async {
  FlixAPIMultiResponse videoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('error') || decodeRes['success'] == false) {
        --tries;
      } else {
        break;
      }
    }

    if (res.statusCode == 500) throw ServerDownException();
    if (decodeRes.containsKey('error') || decodeRes['success'] == false) {
      throw NotFoundException();
    }

    if (!decodeRes.containsKey('links') ||
        decodeRes['links'] == null ||
        (decodeRes['links'] as List).isEmpty) {
      throw NotFoundException();
    }
    videoSources = FlixAPIMultiResponse.fromJson(decodeRes);

    if (videoSources.links == null || videoSources.links!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }

  return videoSources;
}

/// Goku provider (Consumet - same format as FlixHQ)
Future<List<FlixHQMovieSearchEntry>> fetchMoviesForStreamGoku(
    String api) async {
  FlixHQMovieSearch movieStream;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    movieStream = FlixHQMovieSearch.fromJson(decodeRes);
    if (movieStream.results == null || movieStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return movieStream.results ?? [];
}

Future<FlixHQMovieInfo> getMovieStreamEpisodesGoku(String api) async {
  FlixHQMovieInfo movieInfo;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    movieInfo = FlixHQMovieInfo.fromJson(decodeRes);
    if (movieInfo.episodes == null || movieInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return movieInfo;
}

Future<FlixHQTVInfo> getTVStreamEpisodesGoku(String api) async {
  FlixHQTVInfo tvInfo;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    tvInfo = FlixHQTVInfo.fromJson(decodeRes);
    if (tvInfo.episodes == null || tvInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return tvInfo;
}

Future<List<FlixHQTVSearchEntry>> fetchTVForStreamGoku(String api) async {
  FlixHQTVSearch tvStream;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    tvStream = FlixHQTVSearch.fromJson(decodeRes);
    if (tvStream.results == null || tvStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return tvStream.results ?? [];
}

Future<FlixHQStreamSources> getMovieStreamLinksAndSubsGoku(String api) async {
  FlixHQStreamSources movieVideoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    movieVideoSources = FlixHQStreamSources.fromJson(decodeRes);
    if (movieVideoSources.videoLinks == null ||
        movieVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return movieVideoSources;
}

Future<FlixHQStreamSources> getTVStreamLinksAndSubsGoku(String api) async {
  FlixHQStreamSources tvVideoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    tvVideoSources = FlixHQStreamSources.fromJson(decodeRes);
    if (tvVideoSources.videoLinks == null ||
        tvVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return tvVideoSources;
}

/// Sflix provider (Consumet - same format as FlixHQ)
Future<List<FlixHQMovieSearchEntry>> fetchMoviesForStreamSflix(
    String api) async {
  FlixHQMovieSearch movieStream;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    movieStream = FlixHQMovieSearch.fromJson(decodeRes);
    if (movieStream.results == null || movieStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return movieStream.results ?? [];
}

Future<FlixHQMovieInfo> getMovieStreamEpisodesSflix(String api) async {
  FlixHQMovieInfo movieInfo;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    movieInfo = FlixHQMovieInfo.fromJson(decodeRes);
    if (movieInfo.episodes == null || movieInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return movieInfo;
}

Future<FlixHQTVInfo> getTVStreamEpisodesSflix(String api) async {
  FlixHQTVInfo tvInfo;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    tvInfo = FlixHQTVInfo.fromJson(decodeRes);
    if (tvInfo.episodes == null || tvInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return tvInfo;
}

Future<List<FlixHQTVSearchEntry>> fetchTVForStreamSflix(String api) async {
  FlixHQTVSearch tvStream;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    tvStream = FlixHQTVSearch.fromJson(decodeRes);
    if (tvStream.results == null || tvStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return tvStream.results ?? [];
}

Future<FlixHQStreamSources> getMovieStreamLinksAndSubsSflix(String api) async {
  FlixHQStreamSources movieVideoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    movieVideoSources = FlixHQStreamSources.fromJson(decodeRes);
    if (movieVideoSources.videoLinks == null ||
        movieVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return movieVideoSources;
}

Future<FlixHQStreamSources> getTVStreamLinksAndSubsSflix(String api) async {
  FlixHQStreamSources tvVideoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    tvVideoSources = FlixHQStreamSources.fromJson(decodeRes);
    if (tvVideoSources.videoLinks == null ||
        tvVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return tvVideoSources;
}

/// HiMovies provider (Consumet - same format as FlixHQ)
Future<List<FlixHQMovieSearchEntry>> fetchMoviesForStreamHimovies(
    String api) async {
  FlixHQMovieSearch movieStream;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    movieStream = FlixHQMovieSearch.fromJson(decodeRes);
    if (movieStream.results == null || movieStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return movieStream.results ?? [];
}

Future<FlixHQMovieInfo> getMovieStreamEpisodesHimovies(String api) async {
  FlixHQMovieInfo movieInfo;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    movieInfo = FlixHQMovieInfo.fromJson(decodeRes);
    if (movieInfo.episodes == null || movieInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return movieInfo;
}

Future<FlixHQTVInfo> getTVStreamEpisodesHimovies(String api) async {
  FlixHQTVInfo tvInfo;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    tvInfo = FlixHQTVInfo.fromJson(decodeRes);
    if (tvInfo.episodes == null || tvInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return tvInfo;
}

Future<List<FlixHQTVSearchEntry>> fetchTVForStreamHimovies(String api) async {
  FlixHQTVSearch tvStream;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    tvStream = FlixHQTVSearch.fromJson(decodeRes);
    if (tvStream.results == null || tvStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return tvStream.results ?? [];
}

Future<FlixHQStreamSources> getMovieStreamLinksAndSubsHimovies(
    String api) async {
  FlixHQStreamSources movieVideoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api), headers: {'User-Agent': BROWSER_USER_AGENT}).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    movieVideoSources = FlixHQStreamSources.fromJson(decodeRes);
    if (movieVideoSources.videoLinks == null ||
        movieVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return movieVideoSources;
}

Future<FlixHQStreamSources> getTVStreamLinksAndSubsHimovies(String api) async {
  FlixHQStreamSources tvVideoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    tvVideoSources = FlixHQStreamSources.fromJson(decodeRes);
    if (tvVideoSources.videoLinks == null ||
        tvVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return tvVideoSources;
}
