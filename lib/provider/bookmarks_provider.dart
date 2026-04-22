import 'package:reelriot/controller/bookmark_database_controller.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/models/tv.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages bookmarks state (movies + TV), local SQLite, and Supabase sync.
class BookmarksProvider extends ChangeNotifier {
  final MovieDatabaseController _movieDb = MovieDatabaseController();
  final TVDatabaseController _tvDb = TVDatabaseController();
  final _auth = Supabase.instance.client.auth;
  final _supabase = Supabase.instance.client;

  List<Movie>? _movies;
  List<TV>? _tvList;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSyncing = false;

  List<Movie>? get movies => _movies;
  List<TV>? get tvList => _tvList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSyncing => _isSyncing;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool isMovieBookmarked(int id) {
    return _movies?.any((m) => m.id == id) ?? false;
  }

  bool isTVBookmarked(int id) {
    return _tvList?.any((t) => t.id == id) ?? false;
  }

  Future<bool> containsMovie(int id) async {
    if (_movies == null) await fetchMovies();
    return _movies?.any((m) => m.id == id) ?? false;
  }

  Future<bool> containsTV(int id) async {
    if (_tvList == null) await fetchTV();
    return _tvList?.any((t) => t.id == id) ?? false;
  }

  Future<void> fetchMovies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final list = await _movieDb.getMovieList();
      _movies = list;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTV() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final list = await _tvDb.getTVList();
      _tvList = list;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMovie(Movie movie) async {
    _errorMessage = null;
    try {
      await _movieDb.insertMovie(movie);
      _movies ??= [];
      if (!_movies!.any((m) => m.id == movie.id)) {
        _movies!.insert(0, movie);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMovie(Movie movie) async {
    _errorMessage = null;
    try {
      await _movieDb.updateMovie(movie, movie.id!);
      final idx = _movies?.indexWhere((m) => m.id == movie.id) ?? -1;
      if (idx >= 0 && _movies != null) _movies![idx] = movie;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeMovie(int id) async {
    _errorMessage = null;
    try {
      await _movieDb.deleteMovie(id);
      _movies?.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addTV(TV tv) async {
    _errorMessage = null;
    try {
      await _tvDb.insertTV(tv);
      _tvList ??= [];
      if (!_tvList!.any((t) => t.id == tv.id)) {
        _tvList!.insert(0, tv);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTV(TV tv) async {
    _errorMessage = null;
    try {
      await _tvDb.updateTV(tv, tv.id!);
      final idx = _tvList?.indexWhere((t) => t.id == tv.id) ?? -1;
      if (idx >= 0 && _tvList != null) _tvList![idx] = tv;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeTV(int id) async {
    _errorMessage = null;
    try {
      await _tvDb.deleteTV(id);
      _tvList?.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> _checkIfBookmarksExists(String uid) async {
    try {
      final res = await _supabase
          .from('bookmarks')
          .select('user_id')
          .eq('user_id', uid)
          .limit(1);
      return res.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> syncFromCloud() async {
    final user = _auth.currentUser;
    final uid = user?.id;
    if (uid == null || user?.isAnonymous == true) return;

    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasConnection = await checkConnection();
      if (!hasConnection) {
        _errorMessage = 'No internet connection';
        notifyListeners();
        return;
      }

      if (!await _checkIfBookmarksExists(uid)) {
        await _supabase.from('bookmarks').insert({
          'user_id': uid,
          'movies': [],
          'tv_shows': [],
        });
      }

      final res = await _supabase
          .from('bookmarks')
          .select('movies, tv_shows')
          .eq('user_id', uid)
          .limit(1);

      if (res.isEmpty) return;
      final data = res[0];

      final moviesList = data['movies'] as List<dynamic>? ?? [];
      final tvShowsList = data['tv_shows'] as List<dynamic>? ?? [];

      for (var element in moviesList) {
        if (element != null) {
          final movie =
              Movie.fromJson(Map<String, dynamic>.from(element as Map));
          final exists = await _movieDb.contain(movie.id!);
          if (!exists) {
            await _movieDb.insertMovie(movie);
          }
        }
      }

      for (var element in tvShowsList) {
        if (element != null) {
          final tv = TV.fromJson(Map<String, dynamic>.from(element as Map));
          final exists = await _tvDb.contain(tv.id!);
          if (!exists) {
            await _tvDb.insertTV(tv);
          }
        }
      }

      await fetchMovies();
      await fetchTV();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncToCloud() async {
    final user = _auth.currentUser;
    final uid = user?.id;
    if (uid == null || user?.isAnonymous == true) return;

    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasConnection = await checkConnection();
      if (!hasConnection) {
        _errorMessage = 'No internet connection';
        notifyListeners();
        return;
      }

      if (!await _checkIfBookmarksExists(uid)) {
        await _supabase.from('bookmarks').insert({
          'user_id': uid,
          'movies': [],
          'tv_shows': [],
        });
      }

      final res = await _supabase
          .from('bookmarks')
          .select('movies, tv_shows')
          .eq('user_id', uid)
          .limit(1);

      List<Movie> cloudMovies = [];
      List<TV> cloudTV = [];

      if (res.isNotEmpty) {
        final data = res[0];
        final moviesList = data['movies'] as List<dynamic>? ?? [];
        final tvShowsList = data['tv_shows'] as List<dynamic>? ?? [];
        for (var element in moviesList) {
          if (element != null) {
            cloudMovies
                .add(Movie.fromJson(Map<String, dynamic>.from(element as Map)));
          }
        }
        for (var element in tvShowsList) {
          if (element != null) {
            cloudTV.add(TV.fromJson(Map<String, dynamic>.from(element as Map)));
          }
        }
      }

      final localMovies = await _movieDb.getMovieList();
      final localTV = await _tvDb.getTVList();

      bool movieContainsId(List<Movie> list, int id) =>
          list.any((m) => m.id == id);
      bool tvContainsId(List<TV> list, int id) => list.any((t) => t.id == id);

      final mergedMovies = <Movie>[...cloudMovies];
      for (final m in localMovies) {
        if (!movieContainsId(mergedMovies, m.id!)) mergedMovies.add(m);
      }

      final mergedTV = <TV>[...cloudTV];
      for (final t in localTV) {
        if (!tvContainsId(mergedTV, t.id!)) mergedTV.add(t);
      }

      await _supabase.from('bookmarks').upsert({
        'user_id': uid,
        'movies': mergedMovies.map((m) => m.toMap()).toList(),
        'tv_shows': mergedTV.map((t) => t.toMap()).toList(),
      });

      _movies = mergedMovies;
      _tvList = mergedTV;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Syncs from cloud and then to cloud. Call on app open and when entering BookmarkScreen.
  Future<void> syncIfNeeded() async {
    final user = _auth.currentUser;
    if (user?.id == null || user?.isAnonymous == true) return;

    try {
      await syncFromCloud();
      await syncToCloud();
    } catch (_) {
      // Error already set in syncFromCloud/syncToCloud
    }
  }
}
