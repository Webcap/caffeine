import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecentlyWatchedMoviesController {
  static RecentlyWatchedMoviesController? _recentlyWatchedMoviesController;
  Database? _database;
  String tableName = 'recently_watched_movies_table';
  String colId = 'id';
  String colTitle = 'title';
  String colReleaseYear = 'release_year';
  String elapsedCol = 'elapsed';
  String remainingCol = 'remaining';
  String dateTimeCol = 'date_watched';
  String posterPathCol = 'poster_path';
  String backdropPathCol = 'backdrop_path';
  String watchEventsTable = 'movie_watch_events';
  String? get uid => _auth.currentUser?.id;

  RecentlyWatchedMoviesController._createInstance();

  /// Timestamp of the last successful cloud write. Used to debounce the API
  /// so progress saves during active playback don't hammer the server
  /// (periodic saves happen every 10 s). Completion writes always bypass this.
  DateTime? _lastCloudSync;

  factory RecentlyWatchedMoviesController() {
    _recentlyWatchedMoviesController ??=
        RecentlyWatchedMoviesController._createInstance();
    return _recentlyWatchedMoviesController!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String properPath = '${directory.path}/recent_movies.db';
    String legacyPath = '${directory.path}recent_movies.db';
    if (!await File(properPath).exists() && await File(legacyPath).exists()) {
      try {
        await File(legacyPath).copy(properPath);
      } catch (_) {}
    }
    var recentMoviesDatabase = await openDatabase(properPath,
        version: 2, onCreate: _createDb, onUpgrade: _onUpgrade);
    return recentMoviesDatabase;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableName($colId INTEGER PRIMARY KEY, $colTitle TEXT, $posterPathCol TEXT, $backdropPathCol TEXT, $colReleaseYear INTEGER, $elapsedCol NUMERIC, $remainingCol NUMERIC, $dateTimeCol TEXT)');
    await _createWatchEventsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createWatchEventsTable(db);
    }
  }

  Future<void> _createWatchEventsTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $watchEventsTable(event_id TEXT PRIMARY KEY, movie_id INTEGER NOT NULL, watched_at TEXT NOT NULL, synced INTEGER NOT NULL DEFAULT 0)');
  }

  Future<List<Map<String, dynamic>>> getMovieMapList() async {
    Database db = await database;
    var result = await db.query(tableName, orderBy: '$dateTimeCol DESC');
    return result;
  }

  Future<int> insertMovie(RecentMovie rMovie) async {
    Database db = await database;
    var result = await db.insert(tableName, rMovie.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await addWatchedMovietoFirebase(rMovie);
    return result;
  }

  Future<int> updateMovie(RecentMovie rMovie, int id) async {
    var db = await database;
    var result =
        await db.update(tableName, rMovie.toMap(), where: '$colId = $id');
    await addWatchedMovietoFirebase(rMovie);
    return result;
  }

  Future<int> deleteMovie(int id) async {
    var db = await database;
    int result =
        await db.rawDelete('DELETE FROM $tableName WHERE $colId = $id');
    await removeMovieFromCloud(id);
    return result;
  }

  Future<void> removeMovieFromCloud(int movieId) async {
    if (uid == null) return;
    try {
      final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$base/v1/user/$uid/history');
      await http
          .delete(
            url,
            headers: {
              ...caffeineApiHeaders,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'media_type': 'movie',
              'media_id': movieId,
            }),
          )
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('[WatchHistory] ❌ API Delete Error: $e');
    }
  }

  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $tableName');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  Future<List<RecentMovie>> getRecentMovieList() async {
    var movieMapList = await getMovieMapList();
    int count = movieMapList.length;
    List<RecentMovie> movieList = [];

    for (int i = 0; i < count; i++) {
      movieList.add(RecentMovie.fromMapObject(movieMapList[i]));
    }
    return movieList;
  }

  Future<bool> contain(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> x = await db
        .rawQuery('SELECT COUNT (*) from $tableName WHERE $colId = $id');
    int result = Sqflite.firstIntValue(x)!;
    if (result == 0) return false;
    return true;
  }

  GoTrueClient get _auth => Supabase.instance.client.auth;

  /// Upserts movie by id (replaces existing, no duplicates) via Caffeine API.
  Future<void> addWatchedMovietoFirebase(RecentMovie rMovie) async {
    if (uid == null) return;
    try {
      final elapsed = rMovie.elapsed ?? 0;
      final remaining = rMovie.remaining ?? 0;
      final total = elapsed + remaining;
      final isFinished =
          remaining == 0 && elapsed > 0 || (total > 0 && (elapsed / total) >= 0.9);

      // Debounce: skip non-completion syncs that happened within the last 15 s.
      // This prevents hammering the API every 10 s during active playback.
      final now = DateTime.now();
      if (!isFinished &&
          _lastCloudSync != null &&
          now.difference(_lastCloudSync!).inSeconds < 15) {
        return;
      }
      _lastCloudSync = now;

      final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$base/v1/user/$uid/history');

      final payload = {
        'session_id': rMovie.sessionId,
        'media_type': 'movie',
        'media_id': rMovie.id,
        'title': rMovie.title,
        'poster_path': rMovie.posterPath,
        'backdrop_path': rMovie.backdropPath,
        'elapsed_ms': elapsed,
        'duration_ms': total,
        'completed': isFinished,
        'started_at': rMovie.startedAt ?? rMovie.dateTime,
        'platform': Platform.isAndroid ? 'mobile_android' : (Platform.isIOS ? 'mobile_ios' : 'mobile'),
      };

      await http
          .post(
            url,
            headers: {
              ...caffeineApiHeaders,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('[WatchHistory] ❌ API Sync Error: $e');
    }
  }

  Future<void> setWatchHistoryCollection() async {
    // No-op: uid dynamically retrieves _auth.currentUser?.id
  }

  Future<bool> checkIfDocExists(String docId) async {
    return true; // Deprecated single blob validation
  }

  /// Inserts a new watch event (a "play") for [movieId] and fires the cloud sync.
  /// Unlike [insertMovie], this never replaces an existing row — every call adds a
  /// new event, powering rewatch counts.
  Future<void> insertWatchEvent(WatchEvent event, {
    required String? title,
    String? posterPath,
    String? backdropPath,
  }) async {
    final db = await database;
    await db.insert(watchEventsTable, event.toMap()..['movie_id'] = event.mediaId,
        conflictAlgorithm: ConflictAlgorithm.replace);
    await addWatchEventToCloud(event,
        title: title, posterPath: posterPath, backdropPath: backdropPath);
  }

  Future<List<WatchEvent>> getWatchEvents(int movieId) async {
    final db = await database;
    final rows = await db.query(watchEventsTable,
        where: 'movie_id = ?', whereArgs: [movieId], orderBy: 'watched_at DESC');
    return rows
        .map((m) => WatchEvent.fromMapObject(m, idColumn: 'movie_id'))
        .toList();
  }

  Future<int> getWatchCount(int movieId) async {
    final db = await database;
    final x = await db.rawQuery(
        'SELECT COUNT (*) from $watchEventsTable WHERE movie_id = ?', [movieId]);
    return Sqflite.firstIntValue(x) ?? 0;
  }

  Future<void> deleteWatchEvent(String eventId) async {
    final db = await database;
    await db.delete(watchEventsTable, where: 'event_id = ?', whereArgs: [eventId]);
    await removeWatchEventFromCloud(eventId);
  }

  Future<void> deleteAllWatchEvents(int movieId) async {
    final db = await database;
    await db.delete(watchEventsTable, where: 'movie_id = ?', whereArgs: [movieId]);
  }

  /// Creates a new watch event on the Caffeine API. Unlike [addWatchedMovietoFirebase]
  /// (which upserts the progress row), this always creates a new history entry.
  ///
  /// Contract (to be implemented server-side):
  ///   POST /v1/user/{uid}/history/watches
  ///   body: {event_id, media_type: 'movie', media_id, title, poster_path?,
  ///          backdrop_path?, watched_at, platform}
  ///   -> {success, watch_id, watch_count}
  /// The server should dedupe on event_id so retried requests don't double-count.
  Future<void> addWatchEventToCloud(WatchEvent event, {
    required String? title,
    String? posterPath,
    String? backdropPath,
  }) async {
    if (uid == null) return;
    try {
      final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$base/v1/user/$uid/history/watches');
      final payload = {
        'event_id': event.eventId,
        'media_type': 'movie',
        'media_id': event.mediaId,
        'title': title,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        // Empty string means the user picked "Unknown date" — send null so the
        // server can distinguish "no date" from an actual timestamp.
        'watched_at': event.watchedAt.isEmpty ? null : event.watchedAt,
        'platform': Platform.isAndroid
            ? 'mobile_android'
            : (Platform.isIOS ? 'mobile_ios' : 'mobile'),
      };
      await http
          .post(
            url,
            headers: {
              ...caffeineApiHeaders,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('[WatchHistory] ❌ Watch event API sync error: $e');
    }
  }

  /// Contract: DELETE /v1/user/{uid}/history/watches/{eventId} -> {success, watch_count}
  Future<void> removeWatchEventFromCloud(String eventId) async {
    if (uid == null) return;
    try {
      final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$base/v1/user/$uid/history/watches/$eventId');
      await http
          .delete(url, headers: caffeineApiHeaders)
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('[WatchHistory] ❌ Watch event API delete error: $e');
    }
  }

  Future<void> clearAllMovies() async {
    final db = await database;
    await db.delete(tableName);
    await db.delete(watchEventsTable);
  }

  Future<void> replaceAllMovies(List<RecentMovie> movies) async {
    final db = await database;
    await db.delete(tableName);
    for (final m in movies) {
      await db.insert(
        tableName,
        m.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}

class RecentlyWatchedEpisodeController {
  static RecentlyWatchedEpisodeController? _recentlyWatchedEpisodeController;
  static Database? _database;
  String tableName = 'recently_watched_tv_shows_table';
  String colId = 'id';
  String colBackdropPath = 'backdrop_path';
  String colTitle = 'series_name';
  String colEpisodeTitle = 'episode_name';
  String colEpisodeNum = 'episode_num';
  String colSeasonNum = 'season_num';
  String colPosterPath = 'poster_path';
  String colElapsed = 'elapsed';
  String colRemaining = 'remaining';
  String colDateAdded = 'date_added';
  String colSeriesId = 'series_id';
  String watchEventsTable = 'episode_watch_events';
  RecentlyWatchedEpisodeController._createInstance();
  String? get uid => _auth.currentUser?.id;

  GoTrueClient get _auth => Supabase.instance.client.auth;

  /// Timestamp of the last successful cloud write. Used to debounce the API
  /// so progress saves during active playback don’t hammer the server
  /// (periodic saves happen every 10 s). Completion writes always bypass this.
  DateTime? _lastCloudSync;

  factory RecentlyWatchedEpisodeController() {
    _recentlyWatchedEpisodeController ??=
        RecentlyWatchedEpisodeController._createInstance();
    return _recentlyWatchedEpisodeController!;
  }
  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String properPath = '${directory.path}/recent_episodes_v2.db';
    String legacyPath = '${directory.path}recent_episodes_v2.db';
    if (!await File(properPath).exists() && await File(legacyPath).exists()) {
      try {
        await File(legacyPath).copy(properPath);
      } catch (_) {}
    }
    var episodesDatabase = await openDatabase(properPath,
        version: 2, onCreate: _createDb, onUpgrade: _onUpgrade);
    return episodesDatabase;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableName($colId INTEGER PRIMARY KEY, $colSeriesId INTEGER, $colTitle TEXT, $colEpisodeTitle TEXT, $colEpisodeNum INTEGER, $colSeasonNum INTEGER, $colElapsed NUMERIC, $colRemaining NUMERIC, $colPosterPath TEXT, $colDateAdded TEXT)');
    await _createWatchEventsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createWatchEventsTable(db);
    }
  }

  Future<void> _createWatchEventsTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $watchEventsTable(event_id TEXT PRIMARY KEY, series_id INTEGER, episode_id INTEGER, season_num INTEGER, episode_num INTEGER, watched_at TEXT NOT NULL, synced INTEGER NOT NULL DEFAULT 0)');
  }

  //this function will return all the tv in the database.
  Future<List<Map<String, dynamic>>> getTVMapList() async {
    Database db = await database;
    var result = await db.query(tableName, orderBy: '$colDateAdded DESC');
    return result;
  }

  // this method will be used to insert tv in the database.
  Future<int> insertTV(RecentEpisode rEpisode) async {
    Database db = await database;
    var result = await db.insert(tableName, rEpisode.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await addWatchedTVtoFirebase(rEpisode);
    return result;
  }

  // this method will update a tv
  Future<int> updateTV(
      RecentEpisode rEpisode, int id, int episodeNum, int seasonNum) async {
    var db = await database;
    var result = await db.update(tableName, rEpisode.toMap(),
        where:
            '$colId = $id AND $colEpisodeNum = $episodeNum AND $colSeasonNum = $seasonNum');
    await addWatchedTVtoFirebase(rEpisode);
    return result;
  }

  // this method will delete a tv
  Future<int> deleteTV(int id, int episodeNum, int seasonNum) async {
    var db = await database;
    int result = await db.rawDelete(
        'DELETE FROM $tableName WHERE $colId = $id AND $colEpisodeNum = $episodeNum AND $colSeasonNum = $seasonNum');
    await removeEpisodeFromCloud(id, episodeNum, seasonNum);
    return result;
  }

  Future<void> removeEpisodeFromCloud(
      int epId, int episodeNum, int seasonNum) async {
    if (uid == null) return;
    try {
      final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$base/v1/user/$uid/history');
      await http
          .delete(
            url,
            headers: {
              ...caffeineApiHeaders,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'media_type': 'tv',
              'media_id': epId,
              'season_num': seasonNum,
              'episode_num': episodeNum,
            }),
          )
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('[WatchHistory] ❌ API Delete Error: $e');
    }
  }

  // Get number of TV objects in database
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $tableName');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'TV List' [ List<Movie> ]
  Future<List<RecentEpisode>> getEpisodeList() async {
    var tvMapList = await getTVMapList(); // Get 'Map List' from database
    int count = tvMapList.length; // Count the number of map entries in db table
    List<RecentEpisode> tvList = <RecentEpisode>[];
    // For loop to create a 'TV List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      tvList.add(RecentEpisode.fromMapObject(tvMapList[i]));
    }
    return tvList;
  }

  // this function will check if a movies exists in the database.
  Future<bool> contain(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> x = await db
        .rawQuery('SELECT COUNT (*) from $tableName WHERE $colId = $id');
    int result = Sqflite.firstIntValue(x)!;
    if (result == 0) return false;
    return true;
  }

  /// Upserts episode by id (replaces existing, no duplicates) via Caffeine API.
  Future<void> addWatchedTVtoFirebase(RecentEpisode rEpisode) async {
    if (uid == null) return;
    try {
      final elapsed = rEpisode.elapsed ?? 0;
      final remaining = rEpisode.remaining ?? 0;
      final total = elapsed + remaining;
      final isFinished =
          remaining == 0 && elapsed > 0 || (total > 0 && (elapsed / total) >= 0.9);

      // Debounce: skip non-completion syncs that happened within the last 15 s.
      // This prevents hammering the API every 10 s during active playback.
      final now = DateTime.now();
      if (!isFinished &&
          _lastCloudSync != null &&
          now.difference(_lastCloudSync!).inSeconds < 15) {
        return;
      }
      _lastCloudSync = now;

      final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$base/v1/user/$uid/history');

      final payload = {
        'session_id': rEpisode.sessionId,
        'media_type': 'tv',
        'media_id': rEpisode.seriesId ?? rEpisode.id,
        'season_num': rEpisode.seasonNum,
        'episode_num': rEpisode.episodeNum,
        'title': rEpisode.seriesName,
        'episode_name': rEpisode.episodeName,
        'poster_path': rEpisode.posterPath,
        'backdrop_path': rEpisode.posterPath,
        'elapsed_ms': elapsed,
        'duration_ms': total,
        'completed': isFinished,
        'started_at': rEpisode.startedAt ?? rEpisode.dateTime,
        'platform': Platform.isAndroid ? 'mobile_android' : (Platform.isIOS ? 'mobile_ios' : 'mobile'),
      };

      await http
          .post(
            url,
            headers: {
              ...caffeineApiHeaders,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('[WatchHistory] ❌ API Sync Error: $e');
    }
  }

  Future<bool> checkIfDocExists(String docId) async {
    return true; // Deprecated
  }

  Future<void> setWatchHistoryCollection() async {
    // No-op: uid dynamically retrieves _auth.currentUser?.id
  }

  /// Inserts a new watch event (a "play") for the given series/season/episode and
  /// fires the cloud sync. Unlike [insertTV], this never replaces an existing row —
  /// every call adds a new event, powering rewatch counts.
  Future<void> insertWatchEvent(WatchEvent event, {
    required int? seriesId,
    required int? episodeId,
    required String? seriesName,
    String? episodeName,
    String? posterPath,
  }) async {
    final db = await database;
    final map = event.toMap()
      ..['series_id'] = seriesId
      ..['episode_id'] = episodeId;
    await db.insert(watchEventsTable, map,
        conflictAlgorithm: ConflictAlgorithm.replace);
    await addWatchEventToCloud(event,
        seriesId: seriesId,
        seriesName: seriesName,
        episodeName: episodeName,
        posterPath: posterPath);
  }

  Future<List<WatchEvent>> getWatchEvents(
      int seriesId, int seasonNum, int episodeNum) async {
    final db = await database;
    final rows = await db.query(watchEventsTable,
        where: 'series_id = ? AND season_num = ? AND episode_num = ?',
        whereArgs: [seriesId, seasonNum, episodeNum],
        orderBy: 'watched_at DESC');
    return rows
        .map((m) => WatchEvent.fromMapObject(m, idColumn: 'series_id'))
        .toList();
  }

  Future<int> getWatchCount(int seriesId, int seasonNum, int episodeNum) async {
    final db = await database;
    final x = await db.rawQuery(
        'SELECT COUNT (*) from $watchEventsTable WHERE series_id = ? AND season_num = ? AND episode_num = ?',
        [seriesId, seasonNum, episodeNum]);
    return Sqflite.firstIntValue(x) ?? 0;
  }

  Future<void> deleteWatchEvent(String eventId) async {
    final db = await database;
    await db.delete(watchEventsTable, where: 'event_id = ?', whereArgs: [eventId]);
    await removeWatchEventFromCloud(eventId);
  }

  Future<void> deleteAllWatchEvents(
      int seriesId, int seasonNum, int episodeNum) async {
    final db = await database;
    await db.delete(watchEventsTable,
        where: 'series_id = ? AND season_num = ? AND episode_num = ?',
        whereArgs: [seriesId, seasonNum, episodeNum]);
  }

  /// Creates a new watch event on the Caffeine API. Unlike [addWatchedTVtoFirebase]
  /// (which upserts the progress row), this always creates a new history entry.
  ///
  /// Contract (to be implemented server-side):
  ///   POST /v1/user/{uid}/history/watches
  ///   body: {event_id, media_type: 'tv', media_id, season_num, episode_num, title,
  ///          episode_name?, poster_path?, watched_at, platform}
  ///   -> {success, watch_id, watch_count}
  /// The server should dedupe on event_id so retried requests don't double-count.
  Future<void> addWatchEventToCloud(WatchEvent event, {
    required int? seriesId,
    required String? seriesName,
    String? episodeName,
    String? posterPath,
  }) async {
    if (uid == null) return;
    try {
      final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$base/v1/user/$uid/history/watches');
      final payload = {
        'event_id': event.eventId,
        'media_type': 'tv',
        'media_id': seriesId ?? event.mediaId,
        'season_num': event.seasonNum,
        'episode_num': event.episodeNum,
        'title': seriesName,
        'episode_name': episodeName,
        'poster_path': posterPath,
        // Empty string means the user picked "Unknown date" — send null so the
        // server can distinguish "no date" from an actual timestamp.
        'watched_at': event.watchedAt.isEmpty ? null : event.watchedAt,
        'platform': Platform.isAndroid
            ? 'mobile_android'
            : (Platform.isIOS ? 'mobile_ios' : 'mobile'),
      };
      await http
          .post(
            url,
            headers: {
              ...caffeineApiHeaders,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('[WatchHistory] ❌ Watch event API sync error: $e');
    }
  }

  /// Contract: DELETE /v1/user/{uid}/history/watches/{eventId} -> {success, watch_count}
  Future<void> removeWatchEventFromCloud(String eventId) async {
    if (uid == null) return;
    try {
      final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$base/v1/user/$uid/history/watches/$eventId');
      await http
          .delete(url, headers: caffeineApiHeaders)
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('[WatchHistory] ❌ Watch event API delete error: $e');
    }
  }

  Future<void> clearAllEpisodes() async {
    final db = await database;
    await db.delete(tableName);
    await db.delete(watchEventsTable);
  }

  Future<void> replaceAllEpisodes(List<RecentEpisode> episodes) async {
    final db = await database;
    await db.delete(tableName);
    for (final e in episodes) {
      await db.insert(
        tableName,
        e.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
