// ignore_for_file: use_build_context_synchronously
import 'package:caffiene/controller/recently_watched_database_controller.dart';
import 'package:caffiene/functions/network.dart';
import 'package:caffiene/models/movie_stream_metadata.dart';
import 'package:caffiene/models/provider_load_state.dart';
import 'package:caffiene/models/sub_languages.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/globlal_methods.dart';
import 'package:caffiene/utils/report_error_widget.dart';
import 'package:caffiene/video_providers/provider_loader.dart';
import 'package:caffiene/video_providers/provider_names.dart';
import 'package:caffiene/video_providers/regularVideoLinks.dart';
import 'package:caffiene/widgets/provider_loading_widget.dart';
import 'package:caffiene/functions/video_utils.dart';
import 'package:caffiene/services/ad_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/screens/player/player.dart';
import 'package:caffiene/utils/config.dart';
import 'package:better_player/better_player.dart';
import 'package:provider/provider.dart';

class MovieVideoLoader extends StatefulWidget {
  const MovieVideoLoader(
      {required this.download,
      required this.metadata,
      required this.route,
      super.key});

  final bool download;
  final MovieStreamMetadata metadata;
  final StreamRoute route;

  @override
  State<MovieVideoLoader> createState() => _MovieVideoLoaderState();
}

class _MovieVideoLoaderState extends State<MovieVideoLoader> {
  RecentlyWatchedMoviesController recentlyWatchedMoviesController =
      RecentlyWatchedMoviesController();

  List<ProviderLoadState> providerStates = [];
  List<RegularVideoLinks>? movieVideoLinks;
  List<RegularSubtitleLinks>? movieVideoSubs;

  double loadProgress = 0.00;
  late SettingsProvider settings =
      Provider.of<SettingsProvider>(context, listen: false);
  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);
  List<VideoProvider> videoProviders = [];
  late SettingsProvider prefString =
      Provider.of<SettingsProvider>(context, listen: false);

  Map<String, String> videos = {};
  List<BetterPlayerSubtitlesSource> subs = [];

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
      // debugPrint(
      //     '[MovieLoader] Starting load for movie ${widget.metadata.movieId} (${widget.metadata.movieName})');
      // debugPrint(
      //     '[MovieLoader] Providers to try: ${videoProviders.map((p) => p.codeName).join(", ")}');

      if (videoProviders.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pop(context);
          showModalBottomSheet(
            builder: (context) => ReportErrorWidget(
              error: tr("movie_vid_404"),
              hideButton: false,
            ),
            context: context,
          );
        });
        return;
      }

      var isBookmarked = await recentlyWatchedMoviesController
          .contain(widget.metadata.movieId!);
      int elapsed = 0;
      if (isBookmarked) {
        var rMovies =
            Provider.of<RecentProvider>(context, listen: false).movies;
        int index = rMovies
            .indexWhere((element) => element.id == widget.metadata.movieId);
        setState(() {
          elapsed = rMovies[index].elapsed!;
        });
        widget.metadata.elapsed = elapsed;
      } else {
        widget.metadata.elapsed = 0;
      }
      if (widget.metadata.releaseDate != null &&
          !isReleased(widget.metadata.releaseDate!)) {
        GlobalMethods.showScaffoldMessage(
            tr("movie_may_not_be_available"), context);
      }

      for (int i = 0; i < videoProviders.length; i++) {
        if (!mounted) break;
        setState(() {
          currentProviderIndex = i;
          providerStates[i] =
              providerStates[i].copyWith(status: ProviderStatus.loading);
        });

        // debugPrint(
        //     '[MovieLoader] Trying provider ${videoProviders[i].codeName} (${i + 1}/${videoProviders.length})');

        final result = await ProviderLoader.loadMovieFromProvider(
          providerCode: videoProviders[i].codeName,
          route: widget.route,
          movieId: widget.metadata.movieId!,
          movieName: widget.metadata.movieName ?? '',
          releaseYear: widget.metadata.releaseYear?.toString(),
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

        if (!mounted) break;

        if (result.success &&
            result.videoLinks != null &&
            result.videoLinks!.isNotEmpty) {
          // debugPrint(
          //     '[MovieLoader] ✓ ${videoProviders[i].codeName} succeeded: ${result.videoLinks!.length} link(s)');
          // for (int j = 0; j < result.videoLinks!.length; j++) {
          //   final link = result.videoLinks![j];
          //   // final urlPreview = link.url != null
          //   //     ? (link.url!.length > 80
          //   //         ? '${link.url!.substring(0, 80)}...'
          //   //         : link.url)
          //   //     : 'null';
          //   // debugPrint(
          //   //     '[MovieLoader]   Link ${j + 1}: ${link.quality} | m3u8=${link.isM3U8} | $urlPreview');
          // }
          // if (result.subtitleLinks != null && result.subtitleLinks!.isNotEmpty) {
          //   debugPrint(
          //       '[MovieLoader]   Subtitles: ${result.subtitleLinks!.length} track(s)');
          // }
          setState(() {
            providerStates[i] =
                providerStates[i].copyWith(status: ProviderStatus.success);
            movieVideoLinks = result.videoLinks;
            movieVideoSubs = result.subtitleLinks;
            successProviderCode = videoProviders[i].codeName;
          });
          if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
            await _processSubtitles(movieVideoSubs!);
          }
          break;
        } else {
          // debugPrint(
          //     '[MovieLoader] ✗ ${videoProviders[i].codeName} failed: ${result.errorMessage ?? "no links"}');
          setState(() {
            providerStates[i] = providerStates[i].copyWith(
              status: ProviderStatus.failed,
              errorMessage: result.errorMessage,
            );
          });
        }
      }

      if ((movieVideoLinks == null || movieVideoLinks!.isEmpty) && mounted) {
        // debugPrint(
        //     '[MovieLoader] All providers failed - no links found for movie ${widget.metadata.movieId}');
        Navigator.pop(context);
        showModalBottomSheet(
            builder: (context) {
              return ReportErrorWidget(
                error: tr("movie_vid_404"),
                hideButton: false,
              );
            },
            context: context);
      }

      if (movieVideoLinks != null && mounted) {
        // // debugPrint(
        // //     '[MovieLoader] Opening player with ${movieVideoLinks!.length} source(s) from $successProviderCode');
        final reversedVids = VideoUtils.reverseVideoQualityMap(
          VideoUtils.convertVideoLinksToMap(movieVideoLinks!),
        );

        if (appDep.enableADS) {
          await AdService.instance.showInterstitialAd();
        }

        if (!mounted) return;

        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return Player(
              mediaType: MediaType.movie,
              sources: reversedVids,
              subs: subs,
              headers: VideoUtils.extractHeaders(movieVideoLinks!),
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.surface
              ],
              settings: settings,
              movieMetadata: widget.metadata,
              subtitleStyle:
                  Provider.of<SettingsProvider>(context).subtitleTextStyle,
              availableProviders: videoProviders,
              currentProviderCode: successProviderCode,
            );
          },
        ));
      } else {
        if (mounted) {
          Navigator.pop(context);
          showModalBottomSheet(
              builder: (context) {
                return ReportErrorWidget(
                  error: tr("movie_vid_404"),
                  hideButton: false,
                );
              },
              context: context);
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showModalBottomSheet(
            builder: (context) {
              return ReportErrorWidget(
                error: "${tr("movie_vid_404")}\n$e",
                hideButton: false,
              );
            },
            context: context);
      }
    }
  }

  Future<void> _processSubtitles(List<RegularSubtitleLinks> subtitles) async {
    int foundIndex = 0;
    for (int i = 0; i < supportedLanguages.length; i++) {
      if (supportedLanguages[i].languageCode ==
          settings.defaultSubtitleLanguage) {
        foundIndex = i;
        break;
      }
    }
    final defaultLanguage = supportedLanguages[foundIndex].englishName;

    subs = await VideoUtils.parseSubtitles(
      subtitles: subtitles,
      defaultLanguage: defaultLanguage,
      fetchAllLanguages: settings.fetchSpecificLangSubs,
      getVttContent: getVttFileAsString,
    );

    if (subs.isEmpty &&
        appDep.useExternalSubtitles &&
        widget.metadata.movieId != null) {
      final isProxyEnabled =
          Provider.of<SettingsProvider>(context, listen: false).enableProxy;
      final proxyUrl =
          Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
      try {
        final value = await fetchSocialLinks(
          Endpoints.getExternalLinksForMovie(widget.metadata.movieId!, "en"),
          isProxyEnabled,
          proxyUrl,
        );
        if (value.imdbId != null) {
          final extSubs = await getExternalSubtitle(
            Endpoints.searchExternalMovieSubtitles(
                value.imdbId!, supportedLanguages[foundIndex].languageCode),
            appDep.opensubtitlesKey,
          );
          if (extSubs.isNotEmpty &&
              extSubs[0].attr?.files != null &&
              extSubs[0].attr!.files!.isNotEmpty &&
              extSubs[0].attr!.files![0].fileId != null) {
            final download = await downloadExternalSubtitle(
              Endpoints.externalSubtitleDownload(),
              extSubs[0].attr!.files![0].fileId!,
              appDep.opensubtitlesKey,
            );
            if (download.link != null) {
              subs.add(
                BetterPlayerSubtitlesSource(
                  name: supportedLanguages[foundIndex].englishName,
                  urls: [download.link!],
                  selectedByDefault: true,
                  type: BetterPlayerSubtitlesSourceType.network,
                ),
              );
            }
          }
        }
      } catch (e) {
        GlobalMethods.showErrorScaffoldMessengerGeneral(
            e is Exception ? e : Exception(e.toString()), context);
      }
    }
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
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
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

    return Scaffold(
      body: Center(
        child: ProviderLoadingWidget(
          providers: providerStates,
          currentIndex: currentProviderIndex,
          additionalMessage: settings.defaultSubtitleLanguage != ''
              ? null
              : 'Subtitle load progress: ${loadProgress.toStringAsFixed(0)}%',
        ),
      ),
    );
  }
}
