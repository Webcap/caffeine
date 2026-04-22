// ignore_for_file: use_build_context_synchronously
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/controller/recently_watched_database_controller.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/models/movie_stream_metadata.dart';
import 'package:reelriot/models/tv_stream_metadata.dart';
import 'package:reelriot/models/provider_load_state.dart';
import 'package:reelriot/models/sub_languages.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/models/provider_video_source.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:reelriot/utils/report_error_widget.dart';
import 'package:reelriot/video_providers/provider_loader.dart';
import 'package:reelriot/video_providers/provider_names.dart';
import 'package:reelriot/video_providers/regularVideoLinks.dart';
import 'package:reelriot/widgets/provider_loading_widget.dart';
import 'package:reelriot/functions/video_utils.dart';
import 'package:reelriot/services/ad_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/screens/player/player.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/services/player/caffeine_player_controller.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:provider/provider.dart';

class UnifiedVideoLoader extends StatefulWidget {
  const UnifiedVideoLoader({
    required this.mediaType,
    this.movieMetadata,
    this.tvMetadata,
    required this.route,
    this.download = false,
    super.key,
  }) : assert(
            (mediaType == MediaType.movie && movieMetadata != null) ||
                (mediaType == MediaType.tvShow && tvMetadata != null),
            'Metadata must match mediaType');

  final MediaType mediaType;
  final MovieStreamMetadata? movieMetadata;
  final TVStreamMetadata? tvMetadata;
  final bool download;
  final StreamRoute route;

  @override
  State<UnifiedVideoLoader> createState() => _UnifiedVideoLoaderState();
}

class _UnifiedVideoLoaderState extends State<UnifiedVideoLoader> {
  final RecentlyWatchedMoviesController movieController =
      RecentlyWatchedMoviesController();
  final RecentlyWatchedEpisodeController tvController =
      RecentlyWatchedEpisodeController();

  List<ProviderLoadState> providerStates = [];
  List<RegularVideoLinks>? videoLinks;
  List<RegularSubtitleLinks>? subtitleLinks;

  double loadProgress = 0.00;
  late SettingsProvider settings =
      Provider.of<SettingsProvider>(context, listen: false);
  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);
  List<VideoProvider> videoProviders = [];
  late SettingsProvider prefString =
      Provider.of<SettingsProvider>(context, listen: false);

  List<CaffeinePlayerSubtitlesSource> subs = [];
  int currentProviderIndex = 0;
  String? successProviderCode;

  @override
  void initState() {
    super.initState();
    final availableCodes =
        ProviderNames.providers.map((p) => p.codeName).toSet();
    videoProviders.addAll(
        parseProviderPrecedenceString(prefString.proPreference)
            .where((provider) =>
                provider != null && availableCodes.contains(provider.codeName))
            .cast<VideoProvider>());
    providerStates = videoProviders
        .map((p) => ProviderLoadState(
              codeName: p.codeName,
              fullName: p.fullName,
              status: ProviderStatus.pending,
            ))
        .toList();
    loadVideo();
  }

  void loadVideo() async {
    try {
      if (videoProviders.isEmpty) {
        _handleError(tr("movie_vid_404"));
        return;
      }

      // --- Resumption Logic ---
      if (widget.mediaType == MediaType.movie) {
        final meta = widget.movieMetadata!;
        var isBookmarked = await movieController.contain(meta.movieId!);
        if (isBookmarked && meta.elapsed == null) {
          var rMovies =
              Provider.of<RecentProvider>(context, listen: false).movies;
          int index = rMovies.indexWhere((e) => e.id == meta.movieId);
          if (index != -1) {
            final movie = rMovies[index];
            if (shouldShowInContinueWatching(movie.elapsed, movie.remaining)) {
              setState(() {
                meta.elapsed = movie.elapsed!;
              });
            } else {
              setState(() {
                meta.elapsed = 0;
              });
            }
          }
        }
        if (meta.releaseDate != null && !isReleased(meta.releaseDate!)) {
          GlobalMethods.showScaffoldMessage(
              tr("movie_may_not_be_available"), context);
        }
      } else {
        final meta = widget.tvMetadata!;
        var isBookmarked = await tvController.contain(meta.episodeId!);
        if (isBookmarked && meta.elapsed == null) {
          var rEpisodes =
              Provider.of<RecentProvider>(context, listen: false).episodes;
          int index = rEpisodes.indexWhere((e) => e.id == meta.episodeId);
          if (index != -1) {
            final episode = rEpisodes[index];
            if (shouldShowInContinueWatching(episode.elapsed, episode.remaining)) {
              setState(() {
                meta.elapsed = episode.elapsed!;
              });
            } else {
              setState(() {
                meta.elapsed = 0;
              });
            }
          }
        }
        if (meta.airDate != null && !isReleased(meta.airDate!)) {
          GlobalMethods.showScaffoldMessage(
              tr("episode_may_not_be_available"), context);
        }
      }

      // --- Provider Iteration ---
      for (int i = 0; i < videoProviders.length; i++) {
        if (!mounted) break;
        setState(() {
          currentProviderIndex = i;
          providerStates[i] =
              providerStates[i].copyWith(status: ProviderStatus.loading);
        });

        ProviderLoaderResult result;
        if (widget.mediaType == MediaType.movie) {
          result = await ProviderLoader.loadMovieFromProvider(
            providerCode: videoProviders[i].codeName,
            route: widget.route,
            movieId: widget.movieMetadata!.movieId!,
            movieName: widget.movieMetadata!.movieName ?? '',
            releaseYear: widget.movieMetadata!.releaseYear?.toString(),
            consumetUrl: appDep.consumetUrl,
            newFlixHQUrl: appDep.newFlixHQUrl,
            flixApiUrl: appDep.flixApiUrl,
            newFlixhqServer: appDep.newFlixhqServer,
            streamingServerFlixHQ: appDep.streamingServerFlixHQ,
            streamingServerDCVA: appDep.streamingServerDCVA,
            streamingServerZoro: appDep.streamingServerZoro,
            gokuServer: appDep.gokuServer,
            sflixServer: appDep.sflixServer,
            himoviesServer: appDep.himoviesServer,
            animekaiServer: appDep.animekaiServer,
            hianimeServer: appDep.hianimeServer,
            language: settings.defaultAudioLanguage,
            country: settings.defaultCountry,
          );
        } else {
          result = await ProviderLoader.loadTVFromProvider(
            providerCode: videoProviders[i].codeName,
            route: widget.route,
            tvId: widget.tvMetadata!.tvId!,
            seriesName: widget.tvMetadata!.seriesName ?? '',
            seasonNumber: widget.tvMetadata!.seasonNumber!,
            episodeNumber: widget.tvMetadata!.episodeNumber!,
            consumetUrl: appDep.consumetUrl,
            newFlixHQUrl: appDep.newFlixHQUrl,
            flixApiUrl: appDep.flixApiUrl,
            newFlixhqServer: appDep.newFlixhqServer,
            streamingServerFlixHQ: appDep.streamingServerFlixHQ,
            streamingServerDCVA: appDep.streamingServerDCVA,
            streamingServerZoro: appDep.streamingServerZoro,
            gokuServer: appDep.gokuServer,
            sflixServer: appDep.sflixServer,
            himoviesServer: appDep.himoviesServer,
            animekaiServer: appDep.animekaiServer,
            hianimeServer: appDep.hianimeServer,
            language: settings.defaultAudioLanguage,
            country: settings.defaultCountry,
          );
        }

        if (!mounted) break;

        if (result.success &&
            result.videoLinks != null &&
            result.videoLinks!.isNotEmpty) {
          setState(() {
            providerStates[i] =
                providerStates[i].copyWith(status: ProviderStatus.success);
            videoLinks = result.videoLinks;
            subtitleLinks = result.subtitleLinks;
            successProviderCode = videoProviders[i].codeName;
          });
          if (subtitleLinks != null && subtitleLinks!.isNotEmpty) {
            await _processSubtitles(subtitleLinks!);
          }
          break;
        } else {
          setState(() {
            providerStates[i] = providerStates[i].copyWith(
              status: ProviderStatus.failed,
              errorMessage: result.errorMessage,
            );
          });
        }
      }

      if ((videoLinks == null || videoLinks!.isEmpty) && mounted) {
        _handleError(tr("movie_vid_404"));
        return;
      }

      if (videoLinks != null && mounted) {
        final reversedVids = VideoUtils.reverseVideoQualityMap(
          VideoUtils.convertVideoLinksToMap(videoLinks!),
        );

        if (appDep.enableADS) {
          await AdService.instance.showInterstitialAd();
        }

        if (!mounted) return;

        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return Player(
              mediaType: widget.mediaType,
              sources: reversedVids,
              subs: subs,
              headers: VideoUtils.extractHeaders(videoLinks!),
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.surface
              ],
              settings: settings,
              movieMetadata: widget.movieMetadata,
              tvMetadata: widget.tvMetadata,
              subtitleStyle: settings.subtitleTextStyle,
              currentProviderCode: successProviderCode,
            );
          },
        ));
      }
    } on Exception catch (e) {
      _handleError("${tr("movie_vid_404")}\n$e");
    }
  }

  void _handleError(String message) {
    if (mounted) {
      Navigator.pop(context);
      showModalBottomSheet(
        builder: (context) => ReportErrorWidget(
          error: message,
          hideButton: false,
        ),
        context: context,
      );
    }
  }

  Future<void> _processSubtitles(List<RegularSubtitleLinks> subtitles) async {
    int foundIndex = 0;
    for (int i = 0; i < supportedLanguages.length; i++) {
      if (supportedLanguages[i].languageCode ==
          settings.defaultAudioLanguage) {
        foundIndex = i;
        break;
      }
    }
    final defaultLanguage = supportedLanguages[foundIndex].englishName;
    final List<RegularSubtitleLinks> allSubtitles = List.from(subtitles);

    final String? contentId = widget.mediaType == MediaType.movie
        ? widget.movieMetadata?.movieId?.toString()
        : widget.tvMetadata?.tvId?.toString();

    if (appDep.useExternalSubtitles && contentId != null) {
      try {
        final searchLangs = {
          'en',
          'es',
          supportedLanguages[foundIndex].languageCode
        }.join(',');

        final endpoint = widget.mediaType == MediaType.movie
            ? Endpoints.searchExternalMovieSubtitles(
                int.parse(contentId), searchLangs)
            : Endpoints.searchExternalEpisodeSubtitles(
                int.parse(contentId),
                widget.tvMetadata!.episodeNumber!,
                widget.tvMetadata!.seasonNumber!,
                searchLangs);

        final extSubs = await getExternalSubtitle(
          endpoint,
          appDep.opensubtitlesKey,
        );

        if (extSubs.isNotEmpty) {
          final addedLangs = <String>{};
          int addedCount = 0;

          for (var sub in extSubs) {
            if (addedCount >= 4) break;
            final lang = sub.attr?.language ?? '';
            final fileId = sub.attr?.files?.first.fileId;
            if (fileId != null && !addedLangs.contains(lang)) {
              final download = await downloadExternalSubtitle(
                Endpoints.externalSubtitleDownload(),
                fileId,
                appDep.opensubtitlesKey,
              );
              if (download.link != null) {
                addedLangs.add(lang);
                addedCount++;
                allSubtitles.insert(
                    0,
                    RegularSubtitleLinks(
                      language:
                          '${sub.attr?.languageName ?? lang} (OpenSubtitles)',
                      url: download.link,
                    ));
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[UnifiedLoader] External subtitle search failed: $e');
      }
    }

    subs = await VideoUtils.parseSubtitles(
      subtitles: allSubtitles,
      defaultLanguage: defaultLanguage,
      fetchAllLanguages: true,
      getVttContent: getVttFileAsString,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (videoProviders.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  tr("movie_vid_404"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final posterPath = widget.mediaType == MediaType.movie
        ? widget.movieMetadata?.posterPath
        : widget.tvMetadata?.posterPath;

    final posterUrl = posterPath != null && posterPath.isNotEmpty
        ? '${buildImageUrl(TMDB_BASE_IMAGE_URL, appDep.tmdbProxy, settings.enableProxy, context)}w780$posterPath'
        : null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : Colors.white,
      body: Stack(
        children: [
          if (posterUrl != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: posterUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                color: isDark
                    ? const Color(0xCC030712)
                    : Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          Center(
            child: ProviderLoadingWidget(
              providers: providerStates,
              currentIndex: currentProviderIndex,
              additionalMessage: settings.defaultAudioLanguage != ''
                  ? null
                  : 'Subtitle load progress: ${loadProgress.toStringAsFixed(0)}%',
            ),
          ),
        ],
      ),
    );
  }
}
