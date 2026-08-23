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
}
