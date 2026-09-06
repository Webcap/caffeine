import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/models/user_rating.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages user ratings (1-10) for movies, TV series, and episodes via Caffeine API.
class RatingsProvider extends ChangeNotifier {
  static RatingsProvider? _instance;
  static RatingsProvider get instance => _instance ??= RatingsProvider();

  RatingsProvider() {
    _instance = this;
  }

  GoTrueClient get _auth => Supabase.instance.client.auth;
  String? get uid => _auth.currentUser?.id;

  final Map<String, UserRating> _ratings = {};
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, UserRating> get ratings => Map.unmodifiable(_ratings);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Retrieves user rating (1-10) for a given movie, TV show, or episode.
  int? getRating(String mediaType, int mediaId,
      {int? seasonNum, int? episodeNum}) {
    final key = UserRating.makeKey(mediaType, mediaId,
        seasonNum: seasonNum, episodeNum: episodeNum);
    return _ratings[key]?.rating;
  }

  /// Has the user rated this title/episode?
  bool hasRating(String mediaType, int mediaId,
      {int? seasonNum, int? episodeNum}) {
    return getRating(mediaType, mediaId,
            seasonNum: seasonNum, episodeNum: episodeNum) !=
        null;
  }

  /// Fetches all ratings for the current logged-in user from the Caffeine API.
  Future<void> fetchRatings({String? mediaType, String? caffeineBaseUrl}) async {
    final currentUid = uid;
    if (currentUid == null || currentUid.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;

    try {
      final base = (caffeineBaseUrl != null && caffeineBaseUrl.trim().isNotEmpty)
          ? caffeineBaseUrl
          : caffeineApiUrl;
      final url = Endpoints.userRatingsUrl(base, currentUid, mediaType: mediaType);

      final res = await http
          .get(Uri.parse(url), headers: {
            ...caffeineApiHeaders,
            'Content-Type': 'application/json',
          })
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic> && decoded['ratings'] is List) {
          final list = decoded['ratings'] as List;
          if (mediaType == null) {
            _ratings.clear();
          } else {
            _ratings.removeWhere((_, r) => r.mediaType == mediaType);
          }
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              final rating = UserRating.fromJson(item);
              _ratings[rating.compositeKey] = rating;
            }
          }
          notifyListeners();
        }
      } else {
        _errorMessage = 'Failed to load ratings (HTTP ${res.statusCode})';
      }
    } catch (e) {
      debugPrint('[RatingsProvider] Error fetching ratings: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upserts a 1-10 rating for a movie, TV show, or specific episode.
  Future<bool> setRating({
    required String mediaType,
    required int mediaId,
    required int rating,
    int? seasonNum,
    int? episodeNum,
    String? caffeineBaseUrl,
  }) async {
    final currentUid = uid;
    if (currentUid == null || currentUid.isEmpty) return false;

    final key = UserRating.makeKey(mediaType, mediaId,
        seasonNum: seasonNum, episodeNum: episodeNum);
    final previous = _ratings[key];

    // Optimistic UI update
    final optimisticRating = UserRating(
      mediaType: mediaType,
      mediaId: mediaId,
      seasonNum: seasonNum,
      episodeNum: episodeNum,
      rating: rating,
      updatedAt: DateTime.now(),
    );
    _ratings[key] = optimisticRating;
    notifyListeners();

    try {
      final base = (caffeineBaseUrl != null && caffeineBaseUrl.trim().isNotEmpty)
          ? caffeineBaseUrl
          : caffeineApiUrl;
      final url = Endpoints.userRatingsPutUrl(base, currentUid);

      final body = <String, dynamic>{
        'media_type': mediaType,
        'media_id': mediaId,
        'rating': rating,
      };
      if (seasonNum != null) body['season_num'] = seasonNum;
      if (episodeNum != null) body['episode_num'] = episodeNum;

      final res = await http
          .put(
            Uri.parse(url),
            headers: {
              ...caffeineApiHeaders,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        return true;
      } else {
        // Rollback
        if (previous != null) {
          _ratings[key] = previous;
        } else {
          _ratings.remove(key);
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('[RatingsProvider] Error setting rating: $e');
      // Rollback
      if (previous != null) {
        _ratings[key] = previous;
      } else {
        _ratings.remove(key);
      }
      notifyListeners();
      return false;
    }
  }

  /// Deletes a rating for a movie, TV show, or episode.
  Future<bool> deleteRating({
    required String mediaType,
    required int mediaId,
    int? seasonNum,
    int? episodeNum,
    String? caffeineBaseUrl,
  }) async {
    final currentUid = uid;
    if (currentUid == null || currentUid.isEmpty) return false;

    final key = UserRating.makeKey(mediaType, mediaId,
        seasonNum: seasonNum, episodeNum: episodeNum);
    final previous = _ratings[key];
    if (previous == null) return true;

    // Optimistic UI removal
    _ratings.remove(key);
    notifyListeners();

    try {
      final base = (caffeineBaseUrl != null && caffeineBaseUrl.trim().isNotEmpty)
          ? caffeineBaseUrl
          : caffeineApiUrl;
      final url = Endpoints.userRatingsDeleteUrl(
        base,
        currentUid,
        mediaType: mediaType,
        mediaId: mediaId,
        seasonNum: seasonNum,
        episodeNum: episodeNum,
      );

      final res = await http.delete(
        Uri.parse(url),
        headers: {
          ...caffeineApiHeaders,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        return true;
      } else {
        // Rollback
        _ratings[key] = previous;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('[RatingsProvider] Error deleting rating: $e');
      // Rollback
      _ratings[key] = previous;
      notifyListeners();
      return false;
    }
  }

  /// Clears in-memory ratings on sign out.
  void clearLocalRatings() {
    _ratings.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
