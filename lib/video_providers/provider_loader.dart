import 'package:flutter/foundation.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/models/provider_video_source.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/video_providers/regularVideoLinks.dart';

class ProviderLoader {
  /// Load movie from a specific provider via Caffeine API Multi-Scraper
  static Future<ProviderLoaderResult> loadMovieFromProvider({
    required String providerCode,
    required StreamRoute route,
    required int movieId,
    required String movieName,
    required String? releaseYear,
    required String flixApiUrl,
    required String language,
    required String country,
  }) async {
    try {
      switch (providerCode) {
        case 'vidlink':
        case 'vidsrcsu':
        case 'vidfun':
        case 'vixsrc':
        case 'wfs':
        case 'vidzee':
        case 'flixhq':
        case 'coorenlabs':
        case 'vidsrcme':
        case 'nxsha':
          return await _loadMovieFlixAPIMulti(
            movieId: movieId,
            flixApiUrl: flixApiUrl,
            provider: providerCode,
            language: language,
            country: country,
          );

        default:
          return ProviderLoaderResult(
            success: false,
            errorMessage: 'Unknown provider: $providerCode',
          );
      }
    } catch (e) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load TV show from a specific provider via Caffeine API Multi-Scraper
  static Future<ProviderLoaderResult> loadTVFromProvider({
    required String providerCode,
    required StreamRoute route,
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String flixApiUrl,
    required String language,
    required String country,
  }) async {
    try {
      switch (providerCode) {
        case 'vidlink':
        case 'vidsrcsu':
        case 'vidfun':
        case 'vixsrc':
        case 'wfs':
        case 'vidzee':
        case 'flixhq':
        case 'coorenlabs':
        case 'vidsrcme':
        case 'nxsha':
          return await _loadTVFlixAPIMulti(
            tvId: tvId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            flixApiUrl: flixApiUrl,
            provider: providerCode,
            language: language,
            country: country,
          );

        default:
          return ProviderLoaderResult(
            success: false,
            errorMessage: 'Unknown provider: $providerCode',
          );
      }
    } catch (e) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ==================== MOVIE PROVIDER METHODS ====================

  static Future<ProviderLoaderResult> _loadMovieFlixAPIMulti({
    required int movieId,
    required String flixApiUrl,
    required String provider,
    required String language,
    required String country,
  }) async {
    if (flixApiUrl.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'FlixAPI URL not configured',
      );
    }

    final url = Endpoints.getMovieStreamLinkFlixAPIMulti(
        flixApiUrl, provider, movieId, language, country);
    debugPrint('[ProviderLoader] $provider: fetching $url');

    final sources = await getStreamLinksFlixAPIMulti(url);
    debugPrint('[ProviderLoader] $provider: found ${sources.links?.length ?? 0} links');

    if (sources.success && sources.links != null && sources.links!.isNotEmpty) {
      final firstLink = sources.links!.first;

      final videoLinks = [
        RegularVideoLinks(
          url: firstLink.url,
          quality: firstLink.quality ?? 'unknown quality',
          isM3U8: firstLink.isM3U8 ?? firstLink.url?.endsWith('.m3u8') ?? false,
          headers: firstLink.headers,
        ),
      ];

      final subtitleLinks = firstLink.subtitles
          ?.map((subtitle) => RegularSubtitleLinks(
                url: subtitle.file,
                language: subtitle.label,
              ))
          .toList();

      return ProviderLoaderResult(
        success: true,
        videoLinks: videoLinks,
        subtitleLinks: subtitleLinks,
      );
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  // ==================== TV PROVIDER METHODS ====================

  static Future<ProviderLoaderResult> _loadTVFlixAPIMulti({
    required int tvId,
    required int seasonNumber,
    required int episodeNumber,
    required String flixApiUrl,
    required String provider,
    required String language,
    required String country,
  }) async {
    if (flixApiUrl.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'FlixAPI URL not configured',
      );
    }

    final sources = await getStreamLinksFlixAPIMulti(
      Endpoints.getTVStreamLinkFlixAPIMulti(
        flixApiUrl,
        provider,
        tvId,
        episodeNumber,
        seasonNumber,
        language,
        country,
      ),
    );

    if (sources.success && sources.links != null && sources.links!.isNotEmpty) {
      final firstLink = sources.links!.first;

      final videoLinks = [
        RegularVideoLinks(
          url: firstLink.url,
          quality: firstLink.quality ?? 'unknown quality',
          isM3U8: firstLink.isM3U8 ?? firstLink.url?.endsWith('.m3u8') ?? false,
          headers: firstLink.headers,
        ),
      ];

      final subtitleLinks = firstLink.subtitles
          ?.map((subtitle) => RegularSubtitleLinks(
                url: subtitle.file,
                language: subtitle.label,
              ))
          .toList();

      return ProviderLoaderResult(
        success: true,
        videoLinks: videoLinks,
        subtitleLinks: subtitleLinks,
      );
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }
}
