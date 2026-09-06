import 'package:flutter_test/flutter_test.dart';
import 'package:reelriot/models/recently_watched.dart';

void main() {
  group('Trakt-Style Playback Session & Rewatch Model Tests', () {
    test('RecentMovie initializes and serializes session metadata correctly', () {
      final startedTime = DateTime.now().subtract(const Duration(hours: 2)).toIso8601String();
      final completedTime = DateTime.now().toIso8601String();

      final movie = RecentMovie(
        id: 550,
        title: 'Fight Club',
        releaseYear: 1999,
        elapsed: 7200000,
        remaining: 0,
        dateTime: completedTime,
        posterPath: '/path.jpg',
        backdropPath: '/bg.jpg',
        sessionId: 'test-session-uuid-1',
        startedAt: startedTime,
        completedAt: completedTime,
      );

      final map = movie.toMap();
      expect(map['id'], equals(550));
      expect(map['session_id'], equals('test-session-uuid-1'));
      expect(map['started_at'], equals(startedTime));
      expect(map['completed_at'], equals(completedTime));

      final restored = RecentMovie.fromMapObject(map);
      expect(restored.id, equals(550));
      expect(restored.sessionId, equals('test-session-uuid-1'));
      expect(restored.startedAt, equals(startedTime));
      expect(restored.completedAt, equals(completedTime));
    });

    test('RecentEpisode initializes and serializes session metadata correctly', () {
      final startedTime = DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String();
      final completedTime = DateTime.now().toIso8601String();

      final episode = RecentEpisode(
        id: 101,
        seriesId: 1399,
        seriesName: 'Game of Thrones',
        episodeName: 'Winter Is Coming',
        seasonNum: 1,
        episodeNum: 1,
        elapsed: 3600000,
        remaining: 0,
        dateTime: completedTime,
        posterPath: '/got.jpg',
        sessionId: 'test-session-uuid-2',
        startedAt: startedTime,
        completedAt: completedTime,
      );

      final map = episode.toMap();
      expect(map['series_id'], equals(1399));
      expect(map['session_id'], equals('test-session-uuid-2'));
      expect(map['started_at'], equals(startedTime));
      expect(map['completed_at'], equals(completedTime));

      final restored = RecentEpisode.fromMapObject(map);
      expect(restored.seriesId, equals(1399));
      expect(restored.sessionId, equals('test-session-uuid-2'));
      expect(restored.startedAt, equals(startedTime));
    });

    test('Rewatch Completion Threshold logic calculates >= 90% correctly', () {
      // 80% watched -> in progress
      expect(progressPercent(8000, 2000), equals(80.0));
      expect(shouldShowInContinueWatching(8000, 2000), isTrue);

      // 90% watched -> completed (hidden from continue watching)
      expect(progressPercent(9000, 1000), equals(90.0));
      expect(shouldShowInContinueWatching(9000, 1000), isFalse);

      // 95% watched -> completed
      expect(progressPercent(9500, 500), equals(95.0));
      expect(shouldShowInContinueWatching(9500, 500), isFalse);
    });

    test('isWatchedProgress mirrors the inverse of shouldShowInContinueWatching', () {
      expect(isWatchedProgress(8000, 2000), isFalse);
      expect(isWatchedProgress(9000, 1000), isTrue);
      expect(isWatchedProgress(null, null), isFalse);
    });

    test('generateWatchEventId produces unique, non-empty ids', () {
      final a = generateWatchEventId();
      final b = generateWatchEventId();
      expect(a, isNotEmpty);
      expect(b, isNotEmpty);
      expect(a, isNot(equals(b)));
    });

    test('WatchEvent round-trips through toMap/fromMapObject for a movie', () {
      final event = WatchEvent(
        eventId: 'evt-1',
        mediaId: 550,
        watchedAt: '2026-08-28T12:00:00.000Z',
      );

      final map = event.toMap()..['movie_id'] = event.mediaId;
      expect(map['event_id'], equals('evt-1'));
      expect(map['watched_at'], equals('2026-08-28T12:00:00.000Z'));
      expect(map['synced'], equals(0));

      final restored = WatchEvent.fromMapObject(map, idColumn: 'movie_id');
      expect(restored.eventId, equals('evt-1'));
      expect(restored.mediaId, equals(550));
      expect(restored.watchedAt, equals('2026-08-28T12:00:00.000Z'));
      expect(restored.synced, isFalse);
    });

    test('WatchEvent round-trips through toMap/fromMapObject for an episode', () {
      final event = WatchEvent(
        eventId: 'evt-2',
        mediaId: 1399,
        seasonNum: 1,
        episodeNum: 1,
        watchedAt: '2026-08-28T12:00:00.000Z',
      );

      final map = event.toMap()
        ..['series_id'] = event.mediaId
        ..['episode_id'] = 101;
      expect(map['season_num'], equals(1));
      expect(map['episode_num'], equals(1));

      final restored = WatchEvent.fromMapObject(map, idColumn: 'series_id');
      expect(restored.mediaId, equals(1399));
      expect(restored.seasonNum, equals(1));
      expect(restored.episodeNum, equals(1));
    });

    test('Unknown-date watch events serialize as an empty string, not null', () {
      final event = WatchEvent(
        eventId: 'evt-3',
        mediaId: 550,
        watchedAt: '',
      );
      expect(event.toMap()['watched_at'], equals(''));
    });
  });
}
