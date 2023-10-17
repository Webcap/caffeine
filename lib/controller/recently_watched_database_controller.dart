import 'dart:io';
import 'package:caffiene/models/recently_watched.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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
  String? uid;
  late DocumentSnapshot subscription;

  RecentlyWatchedMoviesController._createInstance();

  factory RecentlyWatchedMoviesController() {
    _recentlyWatchedMoviesController ??=
        RecentlyWatchedMoviesController._createInstance();
    return _recentlyWatchedMoviesController!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}recent_movies.db';
    var recentMoviesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
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
    var result = await db.insert(tableName, rMovie.toMap());
    await addWatchedMovietoFirebase(rMovie);
    return result;
  }

  Future<int> updateMovie(RecentMovie rMovie, int id) async {
    var db = await database;
    var result =
        await db.update(tableName, rMovie.toMap(), where: '$colId = $id');
    return result;
  }

  Future<int> deleteMovie(int id) async {
    var db = await database;
    int result =
        await db.rawDelete('DELETE FROM $tableName WHERE $colId = $id');
    return result;
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;

  // add watched movie to firestore
  addWatchedMovietoFirebase(RecentMovie rMovie) async {
    setWatchHistoryCollection();
    try {
      await firebaseInstance.collection('watch_history').doc(uid!).update(
        {
          'movies': FieldValue.arrayUnion([rMovie.toMap()])
        },
      );
    } finally {
      print("added");
    }
  }

  void setWatchHistoryCollection() async {
    User? user = _auth.currentUser;
    uid = user!.uid;

    // Checks if a bookmark document exists for a signed in user
    if (await checkIfDocExists(uid!) == false) {
      await firebaseInstance.collection('watch_history').doc(uid!).set({});
    }

    // Checks if a movie and tvShow collection exists for a signed in user and creates a collection if it doesn't exist
    subscription =
        await firebaseInstance.collection('watch_history').doc(uid!).get();
    final docData = subscription.data() as Map<String, dynamic>;

    if (docData.containsKey('movies') == false) {
      await firebaseInstance.collection('watch_history').doc(uid!).update(
        {'movies': []},
      );
    }

    if (docData.containsKey('tvShows') == false) {
      await firebaseInstance.collection('watch_history').doc(uid!).update(
        {'tvShows': []},
      );
    }
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      var collectionRef = firebaseInstance.collection('watch_history');
      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
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
  String? uid;
  late DocumentSnapshot subscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;

  factory RecentlyWatchedEpisodeController() {
    _recentlyWatchedEpisodeController ??=
        RecentlyWatchedEpisodeController._createInstance();
    return _recentlyWatchedEpisodeController!;
  }
  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}recent_episodes_v2.db';
    var episodesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
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
    var result = await db.insert(tableName, rEpisode.toMap());
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
    return result;
  }

  // this method will delete a tv
  Future<int> deleteTV(int id, int episodeNum, int seasonNum) async {
    var db = await database;
    int result = await db.rawDelete(
        'DELETE FROM $tableName WHERE $colId = $id AND $colEpisodeNum = $episodeNum AND $colSeasonNum = $seasonNum');
    return result;
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

  // this adds the tv to firebase
  addWatchedTVtoFirebase(RecentEpisode rEpisode) async {
    setWatchHistoryCollection();
    try {
      await firebaseInstance.collection('watch_history').doc(uid!).update(
        {
          'tvShows': FieldValue.arrayUnion([rEpisode.toMap()])
        },
      );
    } finally {
      print("added");
    }
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      var collectionRef = firebaseInstance.collection('watch_history');
      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  void setWatchHistoryCollection() async {
    User? user = _auth.currentUser;
    uid = user!.uid;

    // Checks if a bookmark document exists for a signed in user
    if (await checkIfDocExists(uid!) == false) {
      await firebaseInstance.collection('watch_history').doc(uid!).set({});
    }

    // Checks if a movie and tvShow collection exists for a signed in user and creates a collection if it doesn't exist
    subscription =
        await firebaseInstance.collection('watch_history').doc(uid!).get();
    final docData = subscription.data() as Map<String, dynamic>;

    if (docData.containsKey('movies') == false) {
      await firebaseInstance.collection('watch_history').doc(uid!).update(
        {'movies': []},
      );
    }

    if (docData.containsKey('tvShows') == false) {
      await firebaseInstance.collection('watch_history').doc(uid!).update(
        {'tvShows': []},
      );
    }
  }
}
