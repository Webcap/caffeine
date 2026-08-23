import 'package:reelriot/video_providers/flixapi_multi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlixAPIMultiResponse', () {
    test('should parse successful response', () {
      final json = {
        'success': true,
        'provider': 'vidsrc',
        'media': {
          'type': 'movie',
          'title': 'Test Movie',
          'releaseYear': 2023,
          'tmdbId': '123',
        },
        'links': [
          {
            'server': 'vidcloud',
            'url': 'https://example.com/video.m3u8',
            'isM3U8': true,
            'quality': '1080p',
            'subtitles': [
              {
                'file': 'https://example.com/sub.vtt',
                'label': 'English',
              },
            ],
          },
        ],
      };

      final response = FlixAPIMultiResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.provider, equals('vidsrc'));
      expect(response.media!.title, equals('Test Movie'));
      expect(response.links, hasLength(1));
      expect(
          response.links!.first.url, equals('https://example.com/video.m3u8'));
      expect(response.links!.first.subtitles, hasLength(1));
    });

    test('should handle failed response', () {
      final json = {
        'success': false,
        'provider': 'vidsrc',
      };

      final response = FlixAPIMultiResponse.fromJson(json);

      expect(response.success, isFalse);
      expect(response.media, isNull);
      expect(response.links, isNull);
    });

    test('should handle missing media and links', () {
      final json = {
        'success': true,
      };

      final response = FlixAPIMultiResponse.fromJson(json);

      expect(response.media, isNull);
      expect(response.links, isNull);
    });
  });
}
