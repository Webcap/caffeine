import 'dart:math';

/// Progress threshold: items at or above this % are hidden from continue watching.
const int continueWatchingProgressThreshold = 90;

/// Returns progress as 0-100. Excludes item from continue watching when >= threshold.
double progressPercent(int? elapsed, int? remaining) {
  if (elapsed == null) return 0;
  final rem = remaining ?? 0;
  final total = elapsed + rem;
  if (total <= 0) return 0;
  return (elapsed / total) * 100;
}

bool shouldShowInContinueWatching(int? elapsed, int? remaining) {
  // If we don't have progress info yet, or it's within the threshold, show it.
  return progressPercent(elapsed, remaining) <
      continueWatchingProgressThreshold;
}

/// True once progress reaches [continueWatchingProgressThreshold].
bool isWatchedProgress(int? elapsed, int? remaining) =>
    !shouldShowInContinueWatching(elapsed, remaining);

/// Generates a client-side id for a [WatchEvent], used as both the local
/// primary key and the idempotency key sent to the Caffeine API.
String generateWatchEventId() {
  final rand = Random().nextInt(1 << 32).toRadixString(16);
  return '${DateTime.now().microsecondsSinceEpoch}-$rand';
}

class RecentMovie {
  RecentMovie({
    required this.backdropPath,
    required this.dateTime,
    required this.elapsed,
    required this.id,
    required this.posterPath,
    required this.releaseYear,
    required this.remaining,
    required this.title,
    this.sessionId,
    this.startedAt,
    this.completedAt,
  });

  int? id;
  String? title;
  int? releaseYear;
  /// Progress in milliseconds
  int? elapsed;
  /// Remaining time in milliseconds
  int? remaining;
  String? dateTime;
  String? posterPath;
  String? backdropPath;
  String? sessionId;
  String? startedAt;
  String? completedAt;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['release_year'] = releaseYear;
    map['elapsed'] = elapsed;
    map['remaining'] = remaining;
    map['date_watched'] = dateTime;
    map['poster_path'] = posterPath;
    map['backdrop_path'] = backdropPath;
    if (sessionId != null) map['session_id'] = sessionId;
    if (startedAt != null) map['started_at'] = startedAt;
    if (completedAt != null) map['completed_at'] = completedAt;
    return map;
  }

  RecentMovie.fromMapObject(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    releaseYear = map['release_year'];
    elapsed = map['elapsed'];
    remaining = map['remaining'];
    dateTime = map['date_watched'];
    posterPath = map['poster_path'];
    backdropPath = map['backdrop_path'];
    sessionId = map['session_id'];
    startedAt = map['started_at'];
    completedAt = map['completed_at'];
  }
}

class RecentEpisode {
  int? id;
  String? seriesName;
  String? episodeName;
  int? episodeNum;
  int? seasonNum;
  String? posterPath;
  String? dateTime;
  /// Progress in milliseconds
  int? elapsed;
  /// Remaining time in milliseconds
  int? remaining;
  int? seriesId;
  String? sessionId;
  String? startedAt;
  String? completedAt;

  RecentEpisode({
    required this.dateTime,
    required this.elapsed,
    required this.episodeName,
    required this.episodeNum,
    required this.id,
    required this.posterPath,
    required this.remaining,
    required this.seasonNum,
    required this.seriesName,
    required this.seriesId,
    this.sessionId,
    this.startedAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['series_name'] = seriesName;
    map['episode_name'] = episodeName;
    map['episode_num'] = episodeNum;
    map['season_num'] = seasonNum;
    map['poster_path'] = posterPath;
    map['elapsed'] = elapsed;
    map['remaining'] = remaining;
    map['date_added'] = dateTime;
    map['series_id'] = seriesId;
    if (sessionId != null) map['session_id'] = sessionId;
    if (startedAt != null) map['started_at'] = startedAt;
    if (completedAt != null) map['completed_at'] = completedAt;
    return map;
  }

  RecentEpisode.fromMapObject(Map<String, dynamic> map) {
    id = map['id'];
    seriesName = map['series_name'];
    episodeName = map['episode_name'];
    episodeNum = map['episode_num'];
    seasonNum = map['season_num'];
    posterPath = map['poster_path'];
    elapsed = map['elapsed'];
    remaining = map['remaining'];
    dateTime = map['date_added'];
    seriesId = map['series_id'];
    sessionId = map['session_id'];
    startedAt = map['started_at'];
    completedAt = map['completed_at'];
  }
}

/// A single logged watch event (a "play"), distinct from the mutable
/// progress row used for continue-watching. Multiple [WatchEvent]s can
/// exist for the same media item to represent rewatches, Trakt-style.
class WatchEvent {
  WatchEvent({
    required this.eventId,
    required this.mediaId,
    required this.watchedAt,
    this.seasonNum,
    this.episodeNum,
    this.synced = false,
  });

  String eventId;
  int mediaId;
  int? seasonNum;
  int? episodeNum;
  String watchedAt;
  bool synced;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'event_id': eventId,
      'watched_at': watchedAt,
      'synced': synced ? 1 : 0,
    };
    if (seasonNum != null) map['season_num'] = seasonNum;
    if (episodeNum != null) map['episode_num'] = episodeNum;
    return map;
  }

  factory WatchEvent.fromMapObject(Map<String, dynamic> map, {required String idColumn}) {
    return WatchEvent(
      eventId: map['event_id'],
      mediaId: map[idColumn],
      seasonNum: map['season_num'],
      episodeNum: map['episode_num'],
      watchedAt: map['watched_at'],
      synced: (map['synced'] as int?) == 1,
    );
  }
}
