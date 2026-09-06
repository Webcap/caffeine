import 'package:reelriot/api/endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Endpoints - FlixAPI Multi URLs', () {
    test('should generate movie stream URL', () {
      final url = Endpoints.getMovieStreamLinkFlixAPIMulti(
        'https://api.example.com/',
        'vidsrc',
        123,
        'en',
        'US',
      );

      expect(url,
          equals('https://api.example.com/vidsrc/stream-movie?tmdbId=123&language=en&country=US'));
    });

    test('should generate TV stream URL', () {
      final url = Endpoints.getTVStreamLinkFlixAPIMulti(
        'https://api.example.com/',
        'vidsrc',
        123,
        1,
        2,
        'en',
        'US',
      );

      expect(
        url,
        equals(
            'https://api.example.com/vidsrc/stream-tv?tmdbId=123&episode=1&season=2&language=en&country=US'),
      );
    });

    test('should handle base URL without trailing slash', () {
      final url = Endpoints.getMovieStreamLinkFlixAPIMulti(
        'https://api.example.com',
        'pstream',
        456,
        'en',
        'US',
      );

      expect(url,
          equals('https://api.example.com/pstream/stream-movie?tmdbId=456&language=en&country=US'));
    });
  });

  group('Endpoints - User Ratings URLs', () {
    const baseUrl = 'https://caffeine.example.com/';
    const userId = '12345678-1234-1234-1234-123456789abc';

    test('should generate GET user ratings URL without filter', () {
      final url = Endpoints.userRatingsUrl(baseUrl, userId);
      expect(url, equals('https://caffeine.example.com/v1/user/$userId/ratings'));
    });

    test('should generate GET user ratings URL with media_type filter', () {
      final url = Endpoints.userRatingsUrl(baseUrl, userId, mediaType: 'movie');
      expect(url, equals('https://caffeine.example.com/v1/user/$userId/ratings?media_type=movie'));
    });

    test('should generate PUT user ratings URL', () {
      final url = Endpoints.userRatingsPutUrl(baseUrl, userId);
      expect(url, equals('https://caffeine.example.com/v1/user/$userId/ratings'));
    });

    test('should generate DELETE user ratings URL for movie', () {
      final url = Endpoints.userRatingsDeleteUrl(
        baseUrl,
        userId,
        mediaType: 'movie',
        mediaId: 999,
      );
      expect(url, equals('https://caffeine.example.com/v1/user/$userId/ratings?media_type=movie&media_id=999'));
    });

    test('should generate DELETE user ratings URL for episode', () {
      final url = Endpoints.userRatingsDeleteUrl(
        baseUrl,
        userId,
        mediaType: 'tv',
        mediaId: 888,
        seasonNum: 2,
        episodeNum: 5,
      );
      expect(
        url,
        equals('https://caffeine.example.com/v1/user/$userId/ratings?media_type=tv&media_id=888&season_num=2&episode_num=5'),
      );
    });
  });
}
