import 'package:caffiene/video_providers/caffeine_api_source.dart';
import 'package:caffiene/video_providers/flixhq.dart';
import 'package:caffiene/video_providers/flixapi_multi.dart';
import 'package:caffiene/video_providers/dcva.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlixHQMovieSearch', () {
    test('should parse from JSON', () {
      final json = {
        'currentPage': 1,
        'hasNextPage': true,
        'results': [
          {
            'id': 'movie-123',
            'title': 'Test Movie',
            'releaseDate': '2023',
            'type': 'Movie',
          },
        ],
      };

      final search = FlixHQMovieSearch.fromJson(json);

      expect(search.currentPage, equals(1));
      expect(search.hasNextPage, isTrue);
      expect(search.results, hasLength(1));
      expect(search.results!.first.id, equals('movie-123'));
      expect(search.results!.first.title, equals('Test Movie'));
      expect(search.results!.first.releaseDate, equals('2023'));
      expect(search.results!.first.type, equals('Movie'));
    });

    test('should handle empty results', () {
      final json = {
        'currentPage': 1,
        'hasNextPage': false,
        'results': [],
      };

      final search = FlixHQMovieSearch.fromJson(json);

      expect(search.results, isEmpty);
      expect(search.hasNextPage, isFalse);
    });

    test('should handle null results', () {
      final json = {
        'currentPage': 1,
        'hasNextPage': false,
      };

      final search = FlixHQMovieSearch.fromJson(json);

      expect(search.results, isNull);
    });
  });

  group('FlixHQTVSearch', () {
    test('should parse from JSON', () {
      final json = {
        'currentPage': 1,
        'hasNextPage': true,
        'results': [
          {
            'id': 'tv-123',
            'title': 'Test Series',
            'image': 'https://example.com/poster.jpg',
            'seasons': 3,
            'type': 'TV Series',
            'url': 'https://example.com/tv/123',
          },
        ],
      };

      final search = FlixHQTVSearch.fromJson(json);

      expect(search.currentPage, equals(1));
      expect(search.hasNextPage, isTrue);
      expect(search.results, hasLength(1));
      expect(search.results!.first.id, equals('tv-123'));
      expect(search.results!.first.title, equals('Test Series'));
      expect(search.results!.first.seasons, equals(3));
    });
  });

  group('FlixHQStreamSources', () {
    test('should parse from JSON with sources', () {
      final json = {
        'sources': [
          {
            'url': 'https://example.com/video.m3u8',
            'quality': '1080p',
            'isM3U8': true,
          },
        ],
        'subtitles': [
          {
            'file': 'https://example.com/sub.vtt',
            'label': 'English',
          },
        ],
      };

      final sources = FlixHQStreamSources.fromJson(json);

      expect(sources.messageExists, isNull);
      expect(sources.videoLinks, hasLength(1));
      expect(sources.videoLinks!.first.url,
          equals('https://example.com/video.m3u8'));
      expect(sources.videoSubtitles, hasLength(1));
      expect(sources.videoSubtitles!.first.url,
          equals('https://example.com/sub.vtt'));
    });

    test('should detect message when present', () {
      final json = {
        'message': 'Service unavailable',
        'sources': [],
      };

      final sources = FlixHQStreamSources.fromJson(json);

      expect(sources.messageExists, isTrue);
    });

    test('should initialize empty lists for sources and subtitles', () {
      final json = <String, dynamic>{};

      final sources = FlixHQStreamSources.fromJson(json);

      expect(sources.videoLinks, isNull);
      expect(sources.videoSubtitles, isNull);
      expect(sources.messageExists, isNull);
    });
  });

  group('FlixHQMovieInfo', () {
    test('should parse from JSON', () {
      final json = {
        'id': 'movie-123',
        'title': 'Test Movie',
        'url': 'https://example.com/movie',
        'type': 'Movie',
        'releaseDate': '2023',
        'episodes': [
          {
            'id': 'ep-1',
            'title': 'Episode 1',
            'url': 'https://example.com/ep1',
          },
        ],
      };

      final info = FlixHQMovieInfo.fromJson(json);

      expect(info.id, equals('movie-123'));
      expect(info.title, equals('Test Movie'));
      expect(info.type, equals('Movie'));
      expect(info.episodes, hasLength(1));
      expect(info.episodes!.first.id, equals('ep-1'));
    });

    test('should handle message in response', () {
      final json = {
        'id': 'movie-123',
        'message': 'Content not available',
      };

      final info = FlixHQMovieInfo.fromJson(json);

      expect(info.message, equals('Content not available'));
      expect(info.episodes, isNull);
    });
  });

  group('FlixHQTVInfo', () {
    test('should parse from JSON', () {
      final json = {
        'id': 'tv-123',
        'title': 'Test Series',
        'url': 'https://example.com/tv',
        'type': 'TV Series',
        'releaseDate': '2023',
        'episodes': [
          {
            'id': 'ep-1',
            'title': 'Episode 1',
            'url': 'https://example.com/ep1',
            'season': 1,
            'number': 1,
          },
        ],
      };

      final info = FlixHQTVInfo.fromJson(json);

      expect(info.id, equals('tv-123'));
      expect(info.title, equals('Test Series'));
      expect(info.episodes, hasLength(1));
      expect(info.episodes!.first.season, equals(1));
      expect(info.episodes!.first.episode, equals(1));
    });
  });

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

  group('DCVASearch', () {
    test('should parse from JSON', () {
      final json = {
        'currentPage': 1,
        'hasNextPage': true,
        'results': [
          {
            'id': 'movie-456',
            'title': 'Asian Movie',
          },
        ],
      };

      final search = DCVASearch.fromJson(json);

      expect(search.currentPage, equals(1));
      expect(search.hasNextPage, isTrue);
      expect(search.results, hasLength(1));
      expect(search.results!.first.id, equals('movie-456'));
      expect(search.results!.first.title, equals('Asian Movie'));
    });
  });

  group('DCVAInfo', () {
    test('should parse from JSON', () {
      final json = {
        'id': 'movie-456',
        'title': 'Asian Movie',
        'releaseDate': '2023',
        'episodes': [
          {
            'id': 'ep-1',
            'title': 'Episode 1',
            'url': 'https://example.com/ep1',
            'episode': '1',
            'subType': 'sub',
          },
        ],
      };

      final info = DCVAInfo.fromJson(json);

      expect(info.id, equals('movie-456'));
      expect(info.title, equals('Asian Movie'));
      expect(info.episodes, hasLength(1));
      expect(info.episodes!.first.episode, equals('1'));
      expect(info.episodes!.first.subType, equals('sub'));
    });
  });

  group('CaffeineAPIStreamSources', () {
    test('should parse from JSON', () {
      final json = {
        'sources': [
          {
            'url': 'https://example.com/video.m3u8',
            'quality': '720p',
          },
        ],
        'subtitles': [
          {
            'file': 'https://example.com/sub.vtt',
            'label': 'English',
          },
        ],
      };

      final sources = CaffeineAPIStreamSources.fromJson(json);

      expect(sources.messageExists, isNull);
      expect(sources.videoLinks, hasLength(1));
      expect(sources.videoSubtitles, hasLength(1));
    });

    test('should detect message', () {
      final json = {
        'message': 'API Error',
      };

      final sources = CaffeineAPIStreamSources.fromJson(json);

      expect(sources.messageExists, isTrue);
    });
  });
}
