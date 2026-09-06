import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reelriot/provider/bookmarks_provider.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/models/tv.dart';

/// Mutation action record stored in local queue during offline periods.
class OfflineAction {
  final String id;
  final String type; // 'add_movie' | 'remove_movie' | 'add_tv' | 'remove_tv'
  final Map<String, dynamic> payload;
  final int timestamp;

  OfflineAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'payload': payload,
        'timestamp': timestamp,
      };

  factory OfflineAction.fromJson(Map<String, dynamic> json) => OfflineAction(
        id: json['id'] as String,
        type: json['type'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        timestamp: json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      );
}

/// Manages persistent offline action queue to ensure mutations are never lost
/// when connectivity drops, syncing them when internet is restored.
class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  static OfflineSyncManager get instance => _instance;
  OfflineSyncManager._internal();

  static const String _storageKey = 'rr_offline_mutation_queue_v1';
  final List<OfflineAction> _queue = [];
  bool _isFlushing = false;

  List<OfflineAction> get queue => List.unmodifiable(_queue);
  int get pendingCount => _queue.length;

  /// Initialize and restore queued actions from storage.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        _queue.clear();
        for (final item in list) {
          _queue.add(OfflineAction.fromJson(item as Map<String, dynamic>));
        }
        debugPrint('[OfflineSyncManager] Restored ${_queue.length} pending mutations');
      }
    } catch (e) {
      debugPrint('[OfflineSyncManager] Error loading queue: $e');
    }
  }

  /// Persist the in-memory queue to disk.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = jsonEncode(_queue.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, serialized);
    } catch (e) {
      debugPrint('[OfflineSyncManager] Error saving queue: $e');
    }
  }

  /// Enqueue an action to be executed when online.
  Future<void> enqueueAction({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    final action = OfflineAction(
      id: '${DateTime.now().millisecondsSinceEpoch}_${payload['id'] ?? 'item'}',
      type: type,
      payload: payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // Remove obsolete opposite actions for the same entity if present
    _queue.removeWhere((existing) =>
        existing.payload['id'] == payload['id'] &&
        ((existing.type.startsWith('add') && type.startsWith('remove')) ||
         (existing.type.startsWith('remove') && type.startsWith('add'))));

    _queue.add(action);
    await _persist();
    debugPrint('[OfflineSyncManager] Enqueued $type. Total pending: ${_queue.length}');
  }

  /// Process all pending actions once connectivity is restored.
  Future<void> flushPendingActions() async {
    if (_isFlushing || _queue.isEmpty) return;
    _isFlushing = true;

    debugPrint('[OfflineSyncManager] Flushing ${_queue.length} pending offline actions...');
    final actionsToProcess = List<OfflineAction>.from(_queue);

    try {
      final bookmarks = BookmarksProvider.instance;

      for (final action in actionsToProcess) {
        try {
          switch (action.type) {
            case 'add_movie':
              final movie = Movie.fromJson(action.payload);
              await bookmarks.addMovie(movie);
              break;
            case 'remove_movie':
              final id = action.payload['id'] as int;
              await bookmarks.removeMovie(id);
              break;
            case 'add_tv':
              final tv = TV.fromJson(action.payload);
              await bookmarks.addTV(tv);
              break;
            case 'remove_tv':
              final id = action.payload['id'] as int;
              await bookmarks.removeTV(id);
              break;
            default:
              debugPrint('[OfflineSyncManager] Unknown action type: ${action.type}');
          }
          _queue.removeWhere((a) => a.id == action.id);
        } catch (err) {
          debugPrint('[OfflineSyncManager] Failed to process action ${action.id}: $err');
          // If a transient error, stop flushing and retry on next network tick
          break;
        }
      }

      await _persist();
      debugPrint('[OfflineSyncManager] Flush complete. Remaining pending: ${_queue.length}');
    } finally {
      _isFlushing = false;
    }
  }
}
