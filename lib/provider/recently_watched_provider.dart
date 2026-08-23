import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/controller/recently_watched_database_controller.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/models/tv.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reelriot/widgets/mobile_context_menu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/api/endpoints.dart';

class RecentProvider extends ChangeNotifier {
  RecentProvider() {
    _loadCachedWatchStats();
  }

  final RecentlyWatchedMoviesController _movieController =
      RecentlyWatchedMoviesController();
  final RecentlyWatchedEpisodeController _episodeController =
      RecentlyWatchedEpisodeController();

  int? _apiMovieWatchTimeMinutes;
  int? _apiTvWatchTimeMinutes;
  bool _isLoadingWatchStats = false;
  bool get isLoadingWatchStats => _isLoadingWatchStats;

  List<RecentMovie> _movies = [];
  List<RecentMovie> get movies => _movies;
  List<RecentMovie> get continueWatchingMovies => _movies
      .where((m) => shouldShowInContinueWatching(m.elapsed, m.remaining))
      .toList();

  List<RecentEpisode> _episodes = [];
  List<RecentEpisode> get episodes => _episodes;
  List<RecentEpisode> get continueWatchingEpisodes => _episodes
      .where((e) => shouldShowInContinueWatching(e.elapsed, e.remaining))
      .toList();

  List<RecentEpisode> _inProgressEpisodes = [];
  List<RecentEpisode> get inProgressEpisodes => continueWatchingEpisodes;

  List<RecentEpisode> _upNextEpisodes = [];
  List<RecentEpisode> get upNextEpisodes => _upNextEpisodes;

  final Map<int, TVDetails> _tvDetailsCache = {};
  final Map<int, RecentEpisode> _nextEpisodeCache = {};
  bool _isCalculatingUpNext = false;

  bool _isProxyEnabled = false;
  String _proxyUrl = '';
  String _language = 'en';

  void updateConfig(
      {required bool isProxyEnabled,
      required String proxyUrl,
      required String language}) {
    _isProxyEnabled = isProxyEnabled;
    _proxyUrl = proxyUrl;
    _language = language;
  }

  /// Fetches cloud watch_history from Caffeine API, merges with local (highest progress wins),
  /// replaces local DB, then refreshes. No-op if user not signed in.
  Future<void> syncFromCloud() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    try {
      final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$base/v1/user/$uid/history?limit=100');

      final res = await http
          .get(url, headers: caffeineApiHeaders)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['history'] != null) {
          final List<dynamic> history = body['history'];
          final List<RecentMovie> cloudMovies = [];
          final List<RecentEpisode> cloudEpisodes = [];

          for (var row in history) {
            final isTv = row['media_type'] == 'tv';
            final isCompleted = row['completed'] == true;
            final elapsed = _ensureMs((row['elapsed_ms'] as num?)?.toInt() ?? 0);
            final remaining = (row['remaining_ms'] as num?)?.toInt() ?? 0;

            if (isTv) {
              cloudEpisodes.add(RecentEpisode(
                id: (row['id'] as num?)?.toInt(),
                seriesId: (row['id'] as num?)?.toInt(),
                seriesName: row['title'],
                episodeName: row['episode_name'],
                posterPath: row['poster_path'],
                seasonNum: (row['season_num'] as num?)?.toInt(),
                episodeNum: (row['episode_num'] as num?)?.toInt(),
                elapsed: elapsed,
                remaining: isCompleted ? 0 : remaining,
                dateTime: row['updated_at'],
              ));
            } else {
              cloudMovies.add(RecentMovie(
                id: (row['id'] as num?)?.toInt(),
                title: row['title'],
                posterPath: row['poster_path'],
                backdropPath: row['backdrop_path'],
                releaseYear: null,
                elapsed: elapsed,
                remaining: isCompleted ? 0 : remaining,
                dateTime: row['updated_at'],
              ));
            }
          }

          final localMovies = await _movieController.getRecentMovieList();
          final localEpisodes = await _episodeController.getEpisodeList();

          final mergedMovies = _mergeMovies(cloudMovies, localMovies);
          final mergedEpisodes = _mergeEpisodes(cloudEpisodes, localEpisodes);

          await _movieController.replaceAllMovies(mergedMovies);
          await _episodeController.replaceAllEpisodes(mergedEpisodes);
        }
      }
    } catch (e) {
      debugPrint('[WatchHistory] ❌ syncFromCloud API error: $e');
    }

    await fetchMovies();
    await fetchEpisodes();
  }

  List<RecentMovie> _mergeMovies(
      List<RecentMovie> cloud, List<RecentMovie> local) {
    final byId = <int, RecentMovie>{};
    for (final m in local) {
      if (m.id != null) byId[m.id!] = m;
    }
    for (final m in cloud) {
      if (m.id == null) continue;
      final existing = byId[m.id!];
      if (existing != null) {
        bool mComp = m.remaining == 0;
        bool exComp = existing.remaining == 0;
        if (mComp && !exComp) {
          byId[m.id!] = m;
        } else if (!mComp && exComp) {
          // Keep local
        } else if ((m.elapsed ?? 0) > (existing.elapsed ?? 0)) {
          byId[m.id!] = m;
        }
      } else {
        byId[m.id!] = m;
      }
    }
    final list = byId.values.toList();
    list.sort((a, b) {
      final da = a.dateTime ?? '';
      final db = b.dateTime ?? '';
      return db.compareTo(da);
    });
    return list;
  }

  List<RecentEpisode> _mergeEpisodes(
      List<RecentEpisode> cloud, List<RecentEpisode> local) {
    String key(RecentEpisode e) =>
        '${e.seriesId ?? e.id}_${e.seasonNum}_${e.episodeNum}';
    final byKey = <String, RecentEpisode>{};
    for (final e in local) {
      if ((e.id == null && e.seriesId == null) ||
          e.seasonNum == null ||
          e.episodeNum == null) {
        continue;
      }
      byKey[key(e)] = e;
    }
    for (final e in cloud) {
      if (e.id == null || e.seasonNum == null || e.episodeNum == null) {
        continue;
      }
      final k = key(e);
      final existing = byKey[k];
      if (existing != null) {
        bool eComp = e.remaining == 0;
        bool exComp = existing.remaining == 0;
        if (eComp && !exComp) {
          byKey[k] = e;
        } else if (!eComp && exComp) {
          // Keep local
        } else if ((e.elapsed ?? 0) > (existing.elapsed ?? 0)) {
          byKey[k] = e;
        }
      } else {
        byKey[k] = e;
      }
    }
    final list = byKey.values.toList();
    list.sort((a, b) {
      final da = a.dateTime ?? '';
      final db = b.dateTime ?? '';
      return db.compareTo(da);
    });
    return list;
  }


  Future<void> fetchMovies() async {
    _movies = await _movieController.getRecentMovieList();
    notifyListeners();
  }

  Future<void> addMovie(RecentMovie movie) async {
    await _movieController.insertMovie(movie);
    await fetchMovies();
  }

  Future<void> updateMovie(RecentMovie movie, int id) async {
    await _movieController.updateMovie(movie, id);
    await fetchMovies();
  }

  Future<void> deleteMovie(int id) async {
    await _movieController.deleteMovie(id);
    await fetchMovies();
    await invalidateAndRefreshWatchStats();
  }

  Future<void> markMovieAsCompleted(RecentMovie movie) async {
    final updated = RecentMovie(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      releaseYear: movie.releaseYear,
      elapsed: (movie.elapsed ?? 0) + (movie.remaining ?? 0),
      remaining: 0,
      dateTime: DateTime.now().toIso8601String(),
    );
    if ((updated.elapsed ?? 0) == 0) {
      updated.elapsed = 7200000; // default 2hr if no progress
    }
    await updateMovie(updated, movie.id!);
    await invalidateAndRefreshWatchStats();
  }

  /// Episode

  Future<void> fetchEpisodes(
      {bool? isProxyEnabled, String? proxyUrl, String? language}) async {
    if (isProxyEnabled != null) _isProxyEnabled = isProxyEnabled;
    if (proxyUrl != null) _proxyUrl = proxyUrl;
    if (language != null) _language = language;

    _episodes = await _episodeController.getEpisodeList();
    await _calculateUpNext();
    notifyListeners();
  }

  Future<void> _calculateUpNext() async {
    if (_isCalculatingUpNext) return;
    _isCalculatingUpNext = true;

    try {
      final Map<int, RecentEpisode> latestBySeries = {};
      for (final e in _episodes) {
        if (e.seriesId == null) continue;
        final existing = latestBySeries[e.seriesId!];
        if (existing == null) {
          latestBySeries[e.seriesId!] = e;
        } else {
          final exDate =
              DateTime.tryParse(existing.dateTime ?? '') ?? DateTime(0);
          final eDate = DateTime.tryParse(e.dateTime ?? '') ?? DateTime(0);
          if (eDate.isAfter(exDate)) {
            latestBySeries[e.seriesId!] = e;
          }
        }
      }

      final List<RecentEpisode> result = [];
      final List<RecentEpisode> inProgressList = [];
      final episodesToAdvance = <RecentEpisode>[];

      for (var e in latestBySeries.values) {
        if (!shouldShowInContinueWatching(e.elapsed, e.remaining)) {
          episodesToAdvance.add(e);
        } else {
          inProgressList.add(e);
        }
      }

      // Handle advancement for completed episodes
      for (var completedEp in episodesToAdvance) {
        final seriesId = completedEp.seriesId!;

        // Try to find/fetch next episode metadata
        RecentEpisode? nextEp = _nextEpisodeCache[seriesId];

        // If nextEp's season/episode matches what we just finished, it's stale
        if (nextEp != null &&
            nextEp.seasonNum == completedEp.seasonNum &&
            nextEp.episodeNum == completedEp.episodeNum) {
          nextEp = null;
        }

        if (nextEp == null) {
          try {
            // 1. Fetch show-level details to see season structure
            TVDetails? showDetails = _tvDetailsCache[seriesId];
            if (showDetails == null) {
              showDetails = await fetchTVDetails(
                  Endpoints.tvDetailsUrl(seriesId, _language),
                  _isProxyEnabled,
                  _proxyUrl);
              _tvDetailsCache[seriesId] = showDetails;
            }

            if (showDetails.seasons != null) {
              final s = completedEp.seasonNum ?? 1;
              final e = completedEp.episodeNum ?? 1;

              // Find current season info
              final currentSeasonInfo = showDetails.seasons!.firstWhere(
                (se) => se.seasonNumber == s,
                orElse: () => Seasons(),
              );

              int targetSeason = s;
              int targetEpisode = e + 1;

              // If finished last episode of season, try next season
              if (currentSeasonInfo.episodeCount != null &&
                  e >= currentSeasonInfo.episodeCount!) {
                targetSeason = s + 1;
                targetEpisode = 1;
              }

              // Check if target season exists
              final targetSeasonExists = showDetails.seasons!
                  .any((se) => se.seasonNumber == targetSeason);

              if (targetSeasonExists) {
                // Fetch Season Details
                final seasonDetails = await fetchTVDetails(
                    Endpoints.getSeasonDetails(
                        seriesId, targetSeason, _language),
                    _isProxyEnabled,
                    _proxyUrl);

                if (seasonDetails.episodes != null) {
                  final nextMetadata = seasonDetails.episodes!.firstWhere(
                    (ep) => ep.episodeNumber == targetEpisode,
                    orElse: () => EpisodeList(),
                  );

                  if (nextMetadata.episodeId != null) {
                    nextEp = RecentEpisode(
                      id: nextMetadata.episodeId,
                      seriesId: seriesId,
                      seriesName: completedEp.seriesName,
                      episodeName: nextMetadata.name,
                      episodeNum: nextMetadata.episodeNumber,
                      seasonNum: nextMetadata.seasonNumber,
                      posterPath: completedEp.posterPath,
                      elapsed: 0,
                      remaining: 3600,
                      dateTime: completedEp.dateTime,
                    );
                    _nextEpisodeCache[seriesId] = nextEp;
                  }
                }
              }
            }
          } catch (e) {
            debugPrint('Error advancing next episode for $seriesId: $e');
          }
        }

        if (nextEp != null) {
          result.add(nextEp);
        } else {
          // If no next episode, keep the completed one
          result.add(completedEp);
        }
      }

      _upNextEpisodes = result;
      _inProgressEpisodes = inProgressList;

      _upNextEpisodes.sort((a, b) {
        final da = a.dateTime ?? '';
        final db = b.dateTime ?? '';
        return db.compareTo(da);
      });
      _inProgressEpisodes.sort((a, b) {
        final da = a.dateTime ?? '';
        final db = b.dateTime ?? '';
        return db.compareTo(da);
      });
    } finally {
      _isCalculatingUpNext = false;
    }
  }

  Future<void> addEpisode(RecentEpisode episode) async {
    await _episodeController.insertTV(episode);
    await fetchEpisodes();
  }

  Future<void> updateEpisode(
      RecentEpisode episode, int id, int episodeNum, int seasonNum) async {
    await _episodeController.updateTV(episode, id, episodeNum, seasonNum);
    await fetchEpisodes();
  }

  Future<void> deleteEpisode(int id, int episodeNum, int seasonNum) async {
    await _episodeController.deleteTV(id, episodeNum, seasonNum);
    await fetchEpisodes();
    await invalidateAndRefreshWatchStats();
  }

  Future<void> markEpisodeAsCompleted(RecentEpisode episode) async {
    final updated = RecentEpisode(
      id: episode.id,
      seriesId: episode.seriesId,
      seriesName: episode.seriesName,
      episodeName: episode.episodeName,
      episodeNum: episode.episodeNum,
      seasonNum: episode.seasonNum,
      posterPath: episode.posterPath,
      elapsed: (episode.elapsed ?? 0) + (episode.remaining ?? 0),
      remaining: 0,
      dateTime: DateTime.now().toIso8601String(),
    );
    if ((updated.elapsed ?? 0) == 0) {
      updated.elapsed = 3600000; // default 1hr if no progress
    }
    await updateEpisode(
        updated, episode.id!, episode.episodeNum!, episode.seasonNum!);
    await invalidateAndRefreshWatchStats();
  }

  Future<void> markUntilEpisodeAsCompleted({
    required List<EpisodeList> allEpisodes,
    required EpisodeList targetEpisode,
    required int? tvId,
    required String? seriesName,
    required String? posterPath,
  }) async {
    for (var ep in allEpisodes) {
      if (ep.seasonNumber! < targetEpisode.seasonNumber! ||
          (ep.seasonNumber == targetEpisode.seasonNumber &&
              ep.episodeNumber! <= targetEpisode.episodeNumber!)) {
        final recentEp = RecentEpisode(
          id: ep.episodeId,
          seriesId: tvId,
          seriesName: seriesName,
          episodeName: ep.name,
          episodeNum: ep.episodeNumber,
          seasonNum: ep.seasonNumber,
          posterPath: posterPath,
          elapsed: 3600000,
          remaining: 0,
          dateTime: DateTime.now().toIso8601String(),
        );
        await _episodeController.insertTV(recentEp);
      }
    }
    await fetchEpisodes();
    await invalidateAndRefreshWatchStats();
  }

  /// Invalidates both local and server cache, then fetches fresh stats from the API
  Future<void> invalidateAndRefreshWatchStats() async {
    try {
      sharedPrefsSingleton.remove('cached_movie_watch_mins');
      sharedPrefsSingleton.remove('cached_tv_watch_mins');

      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
        final url = Uri.parse('$base/v1/user/$uid/watch-stats/cache');
        await http
            .delete(url, headers: caffeineApiHeaders)
            .timeout(const Duration(seconds: 4))
            .catchError((_) => http.Response('', 500));
      }
    } catch (e) {
      debugPrint('[RecentProvider] ⚠️ invalidateAndRefreshWatchStats error: $e');
    }

    // Immediately fetch updated watch stats and notify listeners
    await fetchWatchStatsFromApi();
  }


  void _loadCachedWatchStats() {
    try {
      _apiMovieWatchTimeMinutes =
          sharedPrefsSingleton.getInt('cached_movie_watch_mins');
      _apiTvWatchTimeMinutes =
          sharedPrefsSingleton.getInt('cached_tv_watch_mins');
    } catch (_) {}
  }

  /// Fetches server-side watch stats for completed items from Caffeine API
  Future<void> fetchWatchStatsFromApi() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
    final url = Uri.parse('$base/v1/user/$uid/watch-stats?days=14');

    try {
      _isLoadingWatchStats = true;
      final response = await http
          .get(url, headers: caffeineApiHeaders)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['stats'] != null) {
          final stats = data['stats'];
          _apiMovieWatchTimeMinutes =
              (stats['movies']?['minutes'] as num?)?.toInt() ?? 0;
          _apiTvWatchTimeMinutes =
              (stats['tv']?['minutes'] as num?)?.toInt() ?? 0;

          // Cache on client
          await sharedPrefsSingleton.setInt(
              'cached_movie_watch_mins', _apiMovieWatchTimeMinutes!);
          await sharedPrefsSingleton.setInt(
              'cached_tv_watch_mins', _apiTvWatchTimeMinutes!);

          notifyListeners();
        }
      }
    } catch (_) {
      // Keep cached or fallback to local
    } finally {
      _isLoadingWatchStats = false;
    }
  }

  static bool _isWithinLast2Weeks(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return false;
    final dt = DateTime.tryParse(dateTimeStr);
    if (dt == null) return false;
    return DateTime.now().difference(dt).inDays <= 14;
  }

  static int _ensureMs(int? value) {
    if (value == null) return 0;
    if (value > 0 && value < 50000) {
      return value * 1000;
    }
    return value;
  }

  String formatWatchTime(int totalMinutes) {
    if (totalMinutes <= 0) return '0m';
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    if (hours > 0) {
      return '${hours}h${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Watch time (minutes) in last 2 weeks for movies.
  /// Strictly counts completed items (remaining == 0).
  int get movieWatchTimeMinutesLast2Weeks {
    if (_apiMovieWatchTimeMinutes != null) return _apiMovieWatchTimeMinutes!;
    int total = 0;
    for (final m in _movies) {
      if (!_isWithinLast2Weeks(m.dateTime)) continue;
      // Only count completed movies
      if (m.remaining != 0) continue;
      total += _ensureMs(m.elapsed);
    }
    return total ~/ 60000;
  }

  /// Watch time (minutes) in last 2 weeks for TV episodes.
  /// Strictly counts completed items (remaining == 0).
  int get tvWatchTimeMinutesLast2Weeks {
    if (_apiTvWatchTimeMinutes != null) return _apiTvWatchTimeMinutes!;
    int total = 0;
    for (final e in _episodes) {
      if (!_isWithinLast2Weeks(e.dateTime)) continue;
      // Only count completed episodes
      if (e.remaining != 0) continue;
      total += _ensureMs(e.elapsed);
    }
    return total ~/ 60000;
  }
}
