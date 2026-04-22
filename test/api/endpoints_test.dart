import 'package:reelriot/api/endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Endpoints - Consumet URLs', () {
    test('should return properly formatted Consumet URL', () {
      final url = Endpoints.searchMovieTVForStreamGoku(
        'test movie',
        'https://consumet.api/',
      );

      expect(url, equals('https://consumet.api/movies/goku/test movie'));
    });

    test('should handle Consumet URL without trailing slash', () {
      final url = Endpoints.searchMovieTVForStreamGoku(
        'test movie',
        'https://consumet.api',
      );

      expect(url, equals('https://consumet.api/movies/goku/test movie'));
    });
  });

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
          equals('https://api.example.com/vidsrc/stream-movie?tmdbId=123'));
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
            'https://api.example.com/vidsrc/stream-tv?tmdbId=123&episode=1&season=2'),
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
          equals('https://api.example.com/pstream/stream-movie?tmdbId=456'));
    });
  });

  group('Endpoints - Zoro URLs', () {
    test('should generate Zoro search URL', () {
      final url = Endpoints.searchZoroMoviesTV(
        'https://consumet.api/',
        'one piece',
      );

      expect(url, equals('https://consumet.api/anime/zoro/one piece'));
    });

    test('should generate Zoro info URL', () {
      final url = Endpoints.getMovieTVInfoZoro(
        'https://consumet.api/',
        'anime-123',
      );

      expect(url, equals('https://consumet.api/anime/zoro/info?id=anime-123'));
    });

    test('should generate Zoro stream links URL', () {
      final url = Endpoints.getMovieTVStreamLinksZoro(
        'https://consumet.api/',
        'episode-456',
        'vidcloud',
      );

      expect(
        url,
        equals(
            'https://consumet.api/anime/zoro/watch?episodeId=episode-456&server=vidcloud'),
      );
    });
  });

  group('Endpoints - Dramacool URLs', () {
    test('should generate Dramacool search URL', () {
      final url = Endpoints.searchMovieTVForStreamDramacool(
        'korean drama',
        'https://consumet.api/',
      );

      expect(url, equals('https://consumet.api/movies/dramacool/korean drama'));
    });

    test('should generate Dramacool info URL', () {
      final url = Endpoints.getMovieTVStreamInfoDramacool(
        'drama-123',
        'https://consumet.api/',
      );

      expect(url,
          equals('https://consumet.api/movies/dramacool/info?id=drama-123'));
    });

    test('should generate Dramacool stream links URL', () {
      final url = Endpoints.getMovieTVStreamLinksDramacool(
        'episode-456',
        'media-789',
        'https://consumet.api/',
        'asianload',
      );

      expect(
        url,
        equals(
          'https://consumet.api/movies/dramacool/watch?episodeId=episode-456&mediaId=media-789&server=asianload',
        ),
      );
    });
  });

  group('Endpoints - ViewAsian URLs', () {
    test('should generate ViewAsian search URL', () {
      final url = Endpoints.searchMovieTVForStreamViewasian(
        'asian movie',
        'https://consumet.api/',
      );

      expect(url, equals('https://consumet.api/movies/viewasian/asian movie'));
    });

    test('should generate ViewAsian info URL', () {
      final url = Endpoints.getMovieTVStreamInfoViewasian(
        'movie-123',
        'https://consumet.api/',
      );

      expect(url,
          equals('https://consumet.api/movies/viewasian/info?id=movie-123'));
    });

    test('should generate ViewAsian stream links URL', () {
      final url = Endpoints.getMovieTVStreamLinksViewasian(
        'episode-456',
        'media-789',
        'https://consumet.api/',
        'asianload',
      );

      expect(
        url,
        equals(
          'https://consumet.api/movies/viewasian/watch?episodeId=episode-456&mediaId=media-789',
        ),
      );
    });
  });

  group('Endpoints - Sflix URLs', () {
    test('should generate Sflix search URL', () {
      final url = Endpoints.searchMovieTVForStreamSflix(
        'sflix movie',
        'https://consumet.api/',
      );

      expect(url, equals('https://consumet.api/movies/sflix/sflix movie'));
    });

    test('should generate Sflix info URL', () {
      final url = Endpoints.getMovieTVStreamInfoSflix(
        'movie-123',
        'https://consumet.api/',
      );

      expect(
          url, equals('https://consumet.api/movies/sflix/info?id=movie-123'));
    });

    test('should generate Sflix stream links URL', () {
      final url = Endpoints.getMovieTVStreamLinksSflix(
        'episode-456',
        'media-789',
        'https://consumet.api/',
        'vidcloud',
      );

      expect(
        url,
        equals(
          'https://consumet.api/movies/sflix/watch?episodeId=episode-456&mediaId=media-789&server=vidcloud',
        ),
      );
    });
  });

  group('Endpoints - HiMovies URLs', () {
    test('should generate HiMovies search URL', () {
      final url = Endpoints.searchMovieTVForStreamHimovies(
        'himovies title',
        'https://consumet.api/',
      );

      expect(
          url, equals('https://consumet.api/movies/himovies/himovies title'));
    });

    test('should generate HiMovies info URL', () {
      final url = Endpoints.getMovieTVStreamInfoHimovies(
        'movie-123',
        'https://consumet.api/',
      );

      expect(url,
          equals('https://consumet.api/movies/himovies/info?id=movie-123'));
    });

    test('should generate HiMovies stream links URL', () {
      final url = Endpoints.getMovieTVStreamLinksHimovies(
        'episode-456',
        'media-789',
        'https://consumet.api/',
        'vidcloud',
      );

      expect(
        url,
        equals(
          'https://consumet.api/movies/himovies/watch?episodeId=episode-456&mediaId=media-789&server=vidcloud',
        ),
      );
    });
  });

  group('Endpoints - Goku URLs', () {
    test('should generate Goku info URL', () {
      final url = Endpoints.getMovieTVStreamInfoGoku(
        'goku-123',
        'https://consumet.api/',
      );

      expect(url, equals('https://consumet.api/movies/goku/info?id=goku-123'));
    });

    test('should generate Goku stream links URL', () {
      final url = Endpoints.getMovieTVStreamLinksGoku(
        'episode-456',
        'media-789',
        'https://consumet.api/',
        'vidcloud',
      );

      expect(
        url,
        equals(
          'https://consumet.api/movies/goku/watch?episodeId=episode-456&mediaId=media-789&server=vidcloud',
        ),
      );
    });
  });
}
