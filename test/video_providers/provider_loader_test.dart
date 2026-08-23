import 'package:reelriot/models/provider_video_source.dart';
import 'package:reelriot/video_providers/provider_loader.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProviderLoader - loadMovieFromProvider', () {
    test('should return error for unknown provider', () async {
      final result = await ProviderLoader.loadMovieFromProvider(
        providerCode: 'unknown_provider',
        route: StreamRoute.tmDB,
        movieId: 123,
        movieName: 'Test Movie',
        releaseYear: '2023',
        flixApiUrl: 'https://flixapi.api',
        language: 'en',
        country: 'US',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Unknown provider: unknown_provider'));
    });

    test('should return error for empty FlixAPI URL', () async {
      final result = await ProviderLoader.loadMovieFromProvider(
        providerCode: 'vixsrc',
        route: StreamRoute.tmDB,
        movieId: 123,
        movieName: 'Test Movie',
        releaseYear: '2023',
        flixApiUrl: '',
        language: 'en',
        country: 'US',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('FlixAPI URL not configured'));
    });
  });

  group('ProviderLoader - loadTVFromProvider', () {
    test('should return error for unknown provider', () async {
      final result = await ProviderLoader.loadTVFromProvider(
        providerCode: 'unknown_provider',
        route: StreamRoute.tmDB,
        tvId: 123,
        seriesName: 'Test Series',
        seasonNumber: 1,
        episodeNumber: 1,
        flixApiUrl: 'https://flixapi.api',
        language: 'en',
        country: 'US',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Unknown provider: unknown_provider'));
    });

    test('should route vidfun for TV shows without unknown provider error', () async {
      final result = await ProviderLoader.loadTVFromProvider(
        providerCode: 'vidfun',
        route: StreamRoute.tmDB,
        tvId: 1399,
        seriesName: 'Game of Thrones',
        seasonNumber: 1,
        episodeNumber: 1,
        flixApiUrl: '',
        language: 'en',
        country: 'US',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('FlixAPI URL not configured'));
    });
  });

  group('ProviderLoader - Supported Providers', () {
    test('should handle all Caffeine multi providers for movies', () async {
      final providers = [
        'vixsrc',
        'vidlink',
        'vidsrcsu',
        'vidfun',
        'wfs',
        'vidzee',
        'coorenlabs'
      ];

      for (final provider in providers) {
        final result = await ProviderLoader.loadMovieFromProvider(
          providerCode: provider,
          route: StreamRoute.tmDB,
          movieId: 123,
          movieName: 'Test Movie',
          releaseYear: '2023',
          flixApiUrl: '',
          language: 'en',
          country: 'US',
        );

        expect(
          result.errorMessage,
          equals('FlixAPI URL not configured'),
          reason: 'Provider $provider should fail with empty FlixAPI URL',
        );
      }
    });

    test('should handle all Caffeine multi providers for TV', () async {
      final providers = [
        'vixsrc',
        'vidlink',
        'vidsrcsu',
        'vidfun',
        'wfs',
        'vidzee',
        'coorenlabs'
      ];

      for (final provider in providers) {
        final result = await ProviderLoader.loadTVFromProvider(
          providerCode: provider,
          route: StreamRoute.tmDB,
          tvId: 123,
          seriesName: 'Test Series',
          seasonNumber: 1,
          episodeNumber: 1,
          flixApiUrl: '',
          language: 'en',
          country: 'US',
        );

        expect(
          result.errorMessage,
          equals('FlixAPI URL not configured'),
          reason: 'Provider $provider should fail with empty FlixAPI URL',
        );
      }
    });
  });
}
