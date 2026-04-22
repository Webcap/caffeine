import 'package:reelriot/models/provider_video_source.dart';
import 'package:reelriot/utils/config.dart';
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
        consumetUrl: 'https://consumet.api',
        newFlixHQUrl: 'https://flixhq.api',
        flixApiUrl: 'https://flixapi.api',
        language: 'en',
        country: 'US',
        newFlixhqServer: 'megacloud',
        streamingServerFlixHQ: 'vidcloud',
        streamingServerDCVA: 'asianload',
        streamingServerZoro: 'vidcloud',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Unknown provider: unknown_provider'));
    });

    test('should return error for not-yet-configured anime providers',
        () async {
      final result = await ProviderLoader.loadMovieFromProvider(
        providerCode: 'animekai',
        route: StreamRoute.tmDB,
        movieId: 123,
        movieName: 'Test Movie',
        releaseYear: '2023',
        consumetUrl: 'https://consumet.api',
        newFlixHQUrl: 'https://flixhq.api',
        flixApiUrl: 'https://flixapi.api',
        language: 'en',
        country: 'US',
        newFlixhqServer: 'megacloud',
        streamingServerFlixHQ: 'vidcloud',
        streamingServerDCVA: 'asianload',
        streamingServerZoro: 'vidcloud',
      );

      expect(result.success, isFalse);
      expect(
          result.errorMessage, equals('Provider animekai not yet configured'));
    });

    test('should return error for animepahe provider', () async {
      final result = await ProviderLoader.loadMovieFromProvider(
        providerCode: 'animepahe',
        route: StreamRoute.tmDB,
        movieId: 123,
        movieName: 'Test Movie',
        releaseYear: '2023',
        consumetUrl: 'https://consumet.api',
        newFlixHQUrl: 'https://flixhq.api',
        flixApiUrl: 'https://flixapi.api',
        language: 'en',
        country: 'US',
        newFlixhqServer: 'megacloud',
        streamingServerFlixHQ: 'vidcloud',
        streamingServerDCVA: 'asianload',
        streamingServerZoro: 'vidcloud',
      );

      expect(result.success, isFalse);
      expect(
          result.errorMessage, equals('Provider animepahe not yet configured'));
    });

    test('should return error for hianime provider', () async {
      final result = await ProviderLoader.loadMovieFromProvider(
        providerCode: 'hianime',
        route: StreamRoute.tmDB,
        movieId: 123,
        movieName: 'Test Movie',
        releaseYear: '2023',
        consumetUrl: 'https://consumet.api',
        newFlixHQUrl: 'https://flixhq.api',
        flixApiUrl: 'https://flixapi.api',
        language: 'en',
        country: 'US',
        newFlixhqServer: 'megacloud',
        streamingServerFlixHQ: 'vidcloud',
        streamingServerDCVA: 'asianload',
        streamingServerZoro: 'vidcloud',
      );

      expect(result.success, isFalse);
      expect(
          result.errorMessage, equals('Provider hianime not yet configured'));
    });

    test('should return error for empty FlixAPI URL', () async {
      final result = await ProviderLoader.loadMovieFromProvider(
        providerCode: 'vidsrc',
        route: StreamRoute.tmDB,
        movieId: 123,
        movieName: 'Test Movie',
        releaseYear: '2023',
        consumetUrl: 'https://consumet.api',
        newFlixHQUrl: '',
        flixApiUrl: '',
        language: 'en',
        country: 'US',
        newFlixhqServer: 'megacloud',
        streamingServerFlixHQ: 'vidcloud',
        streamingServerDCVA: 'asianload',
        streamingServerZoro: 'vidcloud',
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
        consumetUrl: 'https://consumet.api',
        newFlixHQUrl: 'https://flixhq.api',
        flixApiUrl: 'https://flixapi.api',
        newFlixhqServer: 'megacloud',
        streamingServerFlixHQ: 'vidcloud',
        streamingServerDCVA: 'asianload',
        streamingServerZoro: 'vidcloud',
        language: 'en',
        country: 'US',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Unknown provider: unknown_provider'));
    });

    test('should return error for not-yet-configured anime providers',
        () async {
      final result = await ProviderLoader.loadTVFromProvider(
        providerCode: 'animekai',
        route: StreamRoute.tmDB,
        tvId: 123,
        seriesName: 'Test Series',
        seasonNumber: 1,
        episodeNumber: 1,
        consumetUrl: 'https://consumet.api',
        newFlixHQUrl: 'https://flixhq.api',
        flixApiUrl: 'https://flixapi.api',
        newFlixhqServer: 'megacloud',
        streamingServerFlixHQ: 'vidcloud',
        streamingServerDCVA: 'asianload',
        streamingServerZoro: 'vidcloud',
        language: 'en',
        country: 'US',
      );

      expect(result.success, isFalse);
      expect(
          result.errorMessage, equals('Provider animekai not yet configured'));
    });

    test('should return error for empty FlixAPI URL for vidsrc', () async {
      final result = await ProviderLoader.loadTVFromProvider(
        providerCode: 'vidsrc',
        route: StreamRoute.tmDB,
        tvId: 123,
        seriesName: 'Test Series',
        seasonNumber: 1,
        episodeNumber: 1,
        consumetUrl: 'https://consumet.api',
        newFlixHQUrl: '',
        flixApiUrl: '',
        newFlixhqServer: 'megacloud',
        streamingServerFlixHQ: 'vidcloud',
        streamingServerDCVA: 'asianload',
        streamingServerZoro: 'vidcloud',
        language: 'en',
        country: 'US',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('FlixAPI URL not configured'));
    });
  });

  group('ProviderLoader - Supported Providers', () {
    test('should handle all FlixAPI multi providers for movies', () async {
      final providers = [
        'pstream',
        'vixsrc',
        'vidsrc',
        'vidzee',
        'showbox'
      ];

      for (final provider in providers) {
        final result = await ProviderLoader.loadMovieFromProvider(
          providerCode: provider,
          route: StreamRoute.tmDB,
          movieId: 123,
          movieName: 'Test Movie',
          releaseYear: '2023',
          consumetUrl: 'https://consumet.api',
          newFlixHQUrl: 'https://flixhq.api',
          flixApiUrl: '',
          language: 'en',
          country: 'US',
          newFlixhqServer: 'megacloud',
          streamingServerFlixHQ: 'vidcloud',
          streamingServerDCVA: 'asianload',
          streamingServerZoro: 'vidcloud',
        );

        expect(
          result.errorMessage,
          equals('FlixAPI URL not configured'),
          reason: 'Provider $provider should fail with empty FlixAPI URL',
        );
      }
    });

    test('should handle all FlixAPI multi providers for TV', () async {
      final providers = [
        'pstream',
        'vixsrc',
        'vidsrc',
        'vidzee',
        'showbox'
      ];

      for (final provider in providers) {
        final result = await ProviderLoader.loadTVFromProvider(
          providerCode: provider,
          route: StreamRoute.tmDB,
          tvId: 123,seriesName: 'Test Series',
          seasonNumber: 1,
          episodeNumber: 1,
          consumetUrl: 'https://consumet.api',
          newFlixHQUrl: 'https://flixhq.api',
          flixApiUrl: '',
          newFlixhqServer: 'megacloud',
          streamingServerFlixHQ: 'vidcloud',
          streamingServerDCVA: 'asianload',
          streamingServerZoro: 'vidcloud',
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
