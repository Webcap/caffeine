import 'package:flutter_test/flutter_test.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/screens/player/player.dart';

void main() {
  group('Progress Tracking & Completion Logic Tests', () {
    test('progressPercent calculates percentage accurately', () {
      // 50% watched
      expect(progressPercent(5000, 5000), equals(50.0));
      // 90% watched
      expect(progressPercent(9000, 1000), equals(90.0));
      // 100% watched (completed)
      expect(progressPercent(10000, 0), equals(100.0));
      // Unstarted or null edge case
      expect(progressPercent(null, 5000), equals(0.0));
      expect(progressPercent(0, 0), equals(0.0));
    });

    test('shouldShowInContinueWatching filters out items >= 90%', () {
      // 50% watched -> should show in continue watching
      expect(shouldShowInContinueWatching(5000, 5000), isTrue);
      // 89% watched -> should show
      expect(shouldShowInContinueWatching(8900, 1100), isTrue);
      // 90% watched -> completed, should NOT show in continue watching
      expect(shouldShowInContinueWatching(9000, 1000), isFalse);
      // 95% watched -> completed, should NOT show
      expect(shouldShowInContinueWatching(9500, 500), isFalse);
      // 100% watched (remaining 0) -> should NOT show
      expect(shouldShowInContinueWatching(10000, 0), isFalse);
    });

    test('isEmbedUrl correctly identifies embed player URLs', () {
      expect(Player.isEmbedUrl('https://vixsrc.to/embed/movie/12345'), isTrue);
      expect(Player.isEmbedUrl('https://example.com/embed/video'), isTrue);
      expect(Player.isEmbedUrl('https://stream.server.com/video.m3u8'), isFalse);
      expect(Player.isEmbedUrl('https://stream.server.com/video.mp4'), isFalse);
      expect(Player.isEmbedUrl(''), isFalse);
    });

    test('formatEmbedUrl appends startAt timestamp parameter properly', () {
      const url = 'https://vixsrc.to/embed/movie/12345';
      // Elapsed < 3 seconds -> no timestamp added
      expect(Player.formatEmbedUrl(url, 2000), equals(url));
      // Elapsed 60 seconds (60000ms) -> appends startAt=60
      final formatted = Player.formatEmbedUrl(url, 60000);
      expect(formatted, contains('startAt=60'));
      expect(formatted, contains('t=60'));
    });

    test('RecentMovie serialization and progress map roundtrip', () {
      final movie = RecentMovie(
        id: 969681,
        title: 'Spider-Man: Brand New Day',
        releaseYear: 2026,
        elapsed: 6300000, // 1h 45m
        remaining: 900000, // 15m
        dateTime: '2026-08-24 22:50:00',
        posterPath: '/spiderman.jpg',
        backdropPath: '/spiderman_bg.jpg',
      );

      final map = movie.toMap();
      expect(map['id'], equals(969681));
      expect(map['elapsed'], equals(6300000));
      expect(map['remaining'], equals(900000));

      final restored = RecentMovie.fromMapObject(map);
      expect(restored.id, equals(969681));
      expect(restored.title, equals('Spider-Man: Brand New Day'));
      expect(restored.elapsed, equals(6300000));
      expect(restored.remaining, equals(900000));
    });

    test('RecentEpisode serialization and progress map roundtrip', () {
      final episode = RecentEpisode(
        id: 26040101,
        seriesId: 2604,
        seriesName: 'The Boondocks',
        episodeName: 'The Garden Party',
        seasonNum: 1,
        episodeNum: 1,
        elapsed: 1200000, // 20m
        remaining: 120000, // 2m
        dateTime: '2026-08-24 22:50:00',
        posterPath: '/boondocks.jpg',
      );

      final map = episode.toMap();
      expect(map['id'], equals(26040101));
      expect(map['series_id'], equals(2604));
      expect(map['elapsed'], equals(1200000));

      final restored = RecentEpisode.fromMapObject(map);
      expect(restored.id, equals(26040101));
      expect(restored.seriesName, equals('The Boondocks'));
      expect(restored.elapsed, equals(1200000));
      expect(restored.remaining, equals(120000));
    });
  });
}
