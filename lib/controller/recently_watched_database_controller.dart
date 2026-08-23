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
  String? get uid => _auth.currentUser?.id;

  RecentlyWatchedMoviesController._createInstance();

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
    var recentMoviesDatabase =
        await openDatabase(properPath, version: 1, onCreate: _createDb);
    return recentMoviesDatabase;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableName($colId INTEGER PRIMARY KEY, $colTitle TEXT, $posterPathCol TEXT, $backdropPathCol TEXT, $colReleaseYear INTEGER, $elapsedCol NUMERIC, $remainingCol NUMERIC, $dateTimeCol TEXT)');
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

      final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$base/v1/user/$uid/history');

      final payload = {
        'media_type': 'movie',
        'media_id': rMovie.id,
        'title': rMovie.title,
        'poster_path': rMovie.posterPath,
        'backdrop_path': rMovie.backdropPath,
        'elapsed_ms': elapsed,
        'duration_ms': total,
        'completed': isFinished,
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

  Future<void> clearAllMovies() async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<void> replaceAllMovies(List<RecentMovie> movies) async {
    final db = await database;
    await db.delete(tableName);
    for (final m in movies) {
      await db.insert(tableName, m.toMap());
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
  RecentlyWatchedEpisodeController._createInstance();
  String? get uid => _auth.currentUser?.id;

  GoTrueClient get _auth => Supabase.instance.client.auth;

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
    var episodesDatabase =
        await openDatabase(properPath, version: 1, onCreate: _createDb);
    return episodesDatabase;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableName($colId INTEGER PRIMARY KEY, $colSeriesId INTEGER, $colTitle TEXT, $colEpisodeTitle TEXT, $colEpisodeNum INTEGER, $colSeasonNum INTEGER, $colElapsed NUMERIC, $colRemaining NUMERIC, $colPosterPath TEXT, $colDateAdded TEXT)');
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

      final base = caffeineApiUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$base/v1/user/$uid/history');

      final payload = {
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

  Future<void> clearAllEpisodes() async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<void> replaceAllEpisodes(List<RecentEpisode> episodes) async {
    final db = await database;
    await db.delete(tableName);
    for (final e in episodes) {
      await db.insert(tableName, e.toMap());
    }
  }
}
