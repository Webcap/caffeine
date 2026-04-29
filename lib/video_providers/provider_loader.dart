import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:flutter/foundation.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/models/provider_video_source.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/video_providers/regularVideoLinks.dart';

class ProviderLoader {
  /// Load movie from a specific provider
  static Future<ProviderLoaderResult> loadMovieFromProvider({
    required String providerCode,
    required StreamRoute route,
    required int movieId,
    required String movieName,
    required String? releaseYear,
    required String consumetUrl,
    required String newFlixHQUrl,
    required String flixApiUrl,
    required String newFlixhqServer,
    required String streamingServerFlixHQ,
    required String streamingServerDCVA,
    required String streamingServerZoro,
    String gokuServer = 'vidcloud',
    String sflixServer = 'vidcloud',
    String himoviesServer = 'vidcloud',
    String animekaiServer = 'vidcloud',
    String hianimeServer = 'vidcloud',
    required String language,
    required String country,
  }) async {
    try {
      switch (providerCode) {
        case 'vidlink':
        case 'vidsrcsu':
          return await _loadMovieFlixAPIMulti(
            movieId: movieId,
            flixApiUrl: flixApiUrl,
            provider: providerCode,
            language: language,
            country: country,
          );

        case 'goku':
          return await _loadMovieGoku(
            movieId: movieId,
            movieName: movieName,
            releaseYear: releaseYear,
            consumetUrl: consumetUrl,
            gokuServer: gokuServer,
          );

        case 'sflix':
          return await _loadMovieSflix(
            movieId: movieId,
            movieName: movieName,
            releaseYear: releaseYear,
            consumetUrl: consumetUrl,
            sflixServer: sflixServer,
          );

        case 'himovies':
          return await _loadMovieHimovies(
            movieId: movieId,
            movieName: movieName,
            releaseYear: releaseYear,
            consumetUrl: consumetUrl,
            himoviesServer: himoviesServer,
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

  /// Load TV show from a specific provider
  static Future<ProviderLoaderResult> loadTVFromProvider({
    required String providerCode,
    required StreamRoute route,
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String newFlixHQUrl,
    required String flixApiUrl,
    required String newFlixhqServer,
    required String streamingServerFlixHQ,
    required String streamingServerDCVA,
    required String streamingServerZoro,
    String gokuServer = 'vidcloud',
    String sflixServer = 'vidcloud',
    String himoviesServer = 'vidcloud',
    String animekaiServer = 'vidcloud',
    String hianimeServer = 'vidcloud',
    required String language,
    required String country,
  }) async {
    try {
      switch (providerCode) {
        case 'vidlink':
        case 'vidsrcsu':
          return await _loadTVFlixAPIMulti(
            tvId: tvId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            flixApiUrl: flixApiUrl,
            provider: providerCode,
            language: language,
            country: country,
          );

        case 'goku':
          return await _loadTVGoku(
            tvId: tvId,
            seriesName: seriesName,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
            gokuServer: gokuServer,
            language: language,
            country: country,
          );

        case 'sflix':
          return await _loadTVSflix(
            tvId: tvId,
            seriesName: seriesName,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
            sflixServer: sflixServer,
            language: language,
            country: country,
          );

        case 'himovies':
          return await _loadTVHimovies(
            tvId: tvId,
            seriesName: seriesName,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
            himoviesServer: himoviesServer,
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


  static Future<ProviderLoaderResult> _loadMovieGoku({
    required int movieId,
    required String movieName,
    required String? releaseYear,
    required String consumetUrl,
    required String gokuServer,
  }) async {
    final movies = await fetchMoviesForStreamGoku(
      Endpoints.searchMovieTVForStreamGoku(
        normalizeTitle(movieName).toLowerCase(),
        consumetUrl,
      ),
    );

    if (movies.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (final movie in movies) {
      if (movie.releaseDate == releaseYear.toString() &&
          movie.type == 'Movie' &&
          (normalizeTitle(movie.title!).toLowerCase().contains(
                    normalizeTitle(movieName).toLowerCase(),
                  ) ||
              movie.title!.contains(movieName))) {
        final movieInfo = await getMovieStreamEpisodesGoku(
          Endpoints.getMovieTVStreamInfoGoku(movie.id!, consumetUrl),
        );

        if (movieInfo.episodes != null && movieInfo.episodes!.isNotEmpty) {
          final sources = await getMovieStreamLinksAndSubsGoku(
            Endpoints.getMovieTVStreamLinksGoku(
              movieInfo.episodes![0].id!,
              movie.id!,
              consumetUrl,
              gokuServer,
            ),
          );

          if (sources.messageExists == null &&
              sources.videoLinks != null &&
              sources.videoLinks!.isNotEmpty) {
            return ProviderLoaderResult(
              success: true,
              videoLinks: sources.videoLinks,
              subtitleLinks: sources.videoSubtitles,
            );
          }
        }
        break;
      }
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadMovieSflix({
    required int movieId,
    required String movieName,
    required String? releaseYear,
    required String consumetUrl,
    required String sflixServer,
  }) async {
    final movies = await fetchMoviesForStreamSflix(
      Endpoints.searchMovieTVForStreamSflix(
        normalizeTitle(movieName).toLowerCase(),
        consumetUrl,
      ),
    );

    if (movies.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (final movie in movies) {
      if (movie.releaseDate == releaseYear.toString() &&
          movie.type == 'Movie' &&
          (normalizeTitle(movie.title!).toLowerCase().contains(
                    normalizeTitle(movieName).toLowerCase(),
                  ) ||
              movie.title!.contains(movieName))) {
        final movieInfo = await getMovieStreamEpisodesSflix(
          Endpoints.getMovieTVStreamInfoSflix(movie.id!, consumetUrl),
        );

        if (movieInfo.episodes != null && movieInfo.episodes!.isNotEmpty) {
          final sources = await getMovieStreamLinksAndSubsSflix(
            Endpoints.getMovieTVStreamLinksSflix(
              movieInfo.episodes![0].id!,
              movie.id!,
              consumetUrl,
              sflixServer,
            ),
          );

          if (sources.messageExists == null &&
              sources.videoLinks != null &&
              sources.videoLinks!.isNotEmpty) {
            return ProviderLoaderResult(
              success: true,
              videoLinks: sources.videoLinks,
              subtitleLinks: sources.videoSubtitles,
            );
          }
        }
        break;
      }
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadMovieHimovies({
    required int movieId,
    required String movieName,
    required String? releaseYear,
    required String consumetUrl,
    required String himoviesServer,
  }) async {
    final movies = await fetchMoviesForStreamHimovies(
      Endpoints.searchMovieTVForStreamHimovies(
        normalizeTitle(movieName).toLowerCase(),
        consumetUrl,
      ),
    );

    if (movies.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (final movie in movies) {
      if (movie.releaseDate == releaseYear.toString() &&
          movie.type == 'Movie' &&
          (normalizeTitle(movie.title!).toLowerCase().contains(
                    normalizeTitle(movieName).toLowerCase(),
                  ) ||
              movie.title!.contains(movieName))) {
        final movieInfo = await getMovieStreamEpisodesHimovies(
          Endpoints.getMovieTVStreamInfoHimovies(movie.id!, consumetUrl),
        );

        if (movieInfo.episodes != null && movieInfo.episodes!.isNotEmpty) {
          final sources = await getMovieStreamLinksAndSubsHimovies(
            Endpoints.getMovieTVStreamLinksHimovies(
              movieInfo.episodes![0].id!,
              movie.id!,
              consumetUrl,
              himoviesServer,
            ),
          );

          if (sources.messageExists == null &&
              sources.videoLinks != null &&
              sources.videoLinks!.isNotEmpty) {
            return ProviderLoaderResult(
              success: true,
              videoLinks: sources.videoLinks,
              subtitleLinks: sources.videoSubtitles,
            );
          }
        }
        break;
      }
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  // ==================== TV PROVIDER METHODS ====================


  static Future<ProviderLoaderResult> _loadTVGoku({
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String gokuServer,
    required String language,
    required String country,
  }) async {
    final shows = await fetchTVForStreamGoku(
      Endpoints.searchMovieTVForStreamGoku(
        normalizeTitle(seriesName).toLowerCase(),
        consumetUrl,
      ),
    );

    if (shows.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (final show in shows) {
      if (show.type == 'TV Series' &&
          (normalizeTitle(show.title!).toLowerCase().contains(
                    normalizeTitle(seriesName).toLowerCase(),
                  ) ||
              show.title!.contains(seriesName))) {
        final tvInfo = await getTVStreamEpisodesGoku(
          Endpoints.getMovieTVStreamInfoGoku(show.id!, consumetUrl),
        );

        if (tvInfo.episodes != null && tvInfo.episodes!.isNotEmpty) {
          for (final episode in tvInfo.episodes!) {
            if (episode.episode == episodeNumber &&
                episode.season == seasonNumber) {
              final sources = await getTVStreamLinksAndSubsGoku(
                Endpoints.getMovieTVStreamLinksGoku(
                  episode.id!,
                  show.id!,
                  consumetUrl,
                  gokuServer,
                ),
              );

              if (sources.messageExists == null &&
                  sources.videoLinks != null &&
                  sources.videoLinks!.isNotEmpty) {
                return ProviderLoaderResult(
                  success: true,
                  videoLinks: sources.videoLinks,
                  subtitleLinks: sources.videoSubtitles,
                );
              }
              break;
            }
          }
        }
        break;
      }
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadTVSflix({
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String sflixServer,
    required String language,
    required String country,
  }) async {
    final shows = await fetchTVForStreamSflix(
      Endpoints.searchMovieTVForStreamSflix(
        normalizeTitle(seriesName).toLowerCase(),
        consumetUrl,
      ),
    );

    if (shows.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (final show in shows) {
      if (show.type == 'TV Series' &&
          (normalizeTitle(show.title!).toLowerCase().contains(
                    normalizeTitle(seriesName).toLowerCase(),
                  ) ||
              show.title!.contains(seriesName))) {
        final tvInfo = await getTVStreamEpisodesSflix(
          Endpoints.getMovieTVStreamInfoSflix(show.id!, consumetUrl),
        );

        if (tvInfo.episodes != null && tvInfo.episodes!.isNotEmpty) {
          for (final episode in tvInfo.episodes!) {
            if (episode.episode == episodeNumber &&
                episode.season == seasonNumber) {
              final sources = await getTVStreamLinksAndSubsSflix(
                Endpoints.getMovieTVStreamLinksSflix(
                  episode.id!,
                  show.id!,
                  consumetUrl,
                  sflixServer,
                ),
              );

              if (sources.messageExists == null &&
                  sources.videoLinks != null &&
                  sources.videoLinks!.isNotEmpty) {
                return ProviderLoaderResult(
                  success: true,
                  videoLinks: sources.videoLinks,
                  subtitleLinks: sources.videoSubtitles,
                );
              }
              break;
            }
          }
        }
        break;
      }
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadTVHimovies({
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String himoviesServer,
    required String language,
    required String country,
  }) async {
    final shows = await fetchTVForStreamHimovies(
      Endpoints.searchMovieTVForStreamHimovies(
        normalizeTitle(seriesName).toLowerCase(),
        consumetUrl,
      ),
    );

    if (shows.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (final show in shows) {
      if (show.type == 'TV Series' &&
          (normalizeTitle(show.title!).toLowerCase().contains(
                    normalizeTitle(seriesName).toLowerCase(),
                  ) ||
              show.title!.contains(seriesName))) {
        final tvInfo = await getTVStreamEpisodesHimovies(
          Endpoints.getMovieTVStreamInfoHimovies(show.id!, consumetUrl),
        );

        if (tvInfo.episodes != null && tvInfo.episodes!.isNotEmpty) {
          for (final episode in tvInfo.episodes!) {
            if (episode.episode == episodeNumber &&
                episode.season == seasonNumber) {
              final sources = await getTVStreamLinksAndSubsHimovies(
                Endpoints.getMovieTVStreamLinksHimovies(
                  episode.id!,
                  show.id!,
                  consumetUrl,
                  himoviesServer,
                ),
              );

              if (sources.messageExists == null &&
                  sources.videoLinks != null &&
                  sources.videoLinks!.isNotEmpty) {
                return ProviderLoaderResult(
                  success: true,
                  videoLinks: sources.videoLinks,
                  subtitleLinks: sources.videoSubtitles,
                );
              }
              break;
            }
          }
        }
        break;
      }
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }
}
