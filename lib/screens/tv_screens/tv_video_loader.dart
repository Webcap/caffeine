// ignore_for_file: use_build_context_synchronously

import 'package:better_player/better_player.dart';
import 'package:caffiene/controller/recently_watched_database_controller.dart';
import 'package:caffiene/functions/network.dart';
import 'package:caffiene/models/provider_load_state.dart';
import 'package:caffiene/models/sub_languages.dart';
import 'package:caffiene/models/tv_stream_metadata.dart';
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
import 'package:provider/provider.dart';

class TVVideoLoader extends StatefulWidget {
  const TVVideoLoader(
      {required this.metadata,
      required this.download,
      required this.route,
      super.key});

  final TVStreamMetadata metadata;
  final bool download;
  final StreamRoute route;

  @override
  State<TVVideoLoader> createState() => _TVVideoLoaderState();
}

class _TVVideoLoaderState extends State<TVVideoLoader> {
  RecentlyWatchedEpisodeController recentlyWatchedEpisodeController =
      RecentlyWatchedEpisodeController();

  List<ProviderLoadState> providerStates = [];
  List<RegularVideoLinks>? tvVideoLinks;
  List<RegularSubtitleLinks>? tvVideoSubs;

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
  String? imdbId;

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

      var isBookmarked = await recentlyWatchedEpisodeController
          .contain(widget.metadata.episodeId!);
      int elapsed = 0;
      if (isBookmarked) {
        if (mounted) {
          var rEpisodes =
              Provider.of<RecentProvider>(context, listen: false).episodes;

          int index = rEpisodes
              .indexWhere((element) => element.id == widget.metadata.episodeId);
          setState(() {
            elapsed = rEpisodes[index].elapsed!;
          });
          widget.metadata.elapsed = elapsed;
        }
      } else {
        widget.metadata.elapsed = 0;
      }
      if (widget.metadata.airDate != null &&
          !isReleased(widget.metadata.airDate!)) {
        GlobalMethods.showScaffoldMessage(
            tr("episode_may_not_be_available"), context);
      }

      for (int i = 0; i < videoProviders.length; i++) {
        if (!mounted) break;
        setState(() {
          currentProviderIndex = i;
          providerStates[i] =
              providerStates[i].copyWith(status: ProviderStatus.loading);
        });

        final result = await ProviderLoader.loadTVFromProvider(
          providerCode: videoProviders[i].codeName,
          route: widget.route,
          tvId: widget.metadata.tvId!,
          seriesName: widget.metadata.seriesName ?? '',
          seasonNumber: widget.metadata.seasonNumber ?? 1,
          episodeNumber: widget.metadata.episodeNumber ?? 1,
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
          setState(() {
            providerStates[i] =
                providerStates[i].copyWith(status: ProviderStatus.success);
            tvVideoLinks = result.videoLinks;
            tvVideoSubs = result.subtitleLinks;
            successProviderCode = videoProviders[i].codeName;
          });
          if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
            await _processSubtitles(tvVideoSubs!);
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

      if ((tvVideoLinks == null || tvVideoLinks!.isEmpty) && mounted) {
        Navigator.pop(context);
        showModalBottomSheet(
            builder: (context) {
              return ReportErrorWidget(
                error: tr("tv_vid_404"),
                hideButton: false,
              );
            },
            context: context);
      }

      if (tvVideoLinks != null && mounted) {
        final reversedVids = VideoUtils.reverseVideoQualityMap(
          VideoUtils.convertVideoLinksToMap(tvVideoLinks!),
        );

        if (appDep.enableADS) {
          await AdService.instance.showInterstitialAd();
        }

        if (!mounted) return;

        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return Player(
              mediaType: MediaType.tvShow,
              sources: reversedVids,
              subs: subs,
              headers: VideoUtils.extractHeaders(tvVideoLinks!),
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.surface
              ],
              settings: settings,
              tvMetadata: widget.metadata,
              subtitleStyle:
                  Provider.of<SettingsProvider>(context).subtitleTextStyle,
              availableProviders: videoProviders,
              currentProviderCode: successProviderCode,
              imdbId: imdbId,
            );
          },
        ));
      } else {
        if (mounted) {
          Navigator.pop(context);
          showModalBottomSheet(
              builder: (context) {
                return ReportErrorWidget(
                  error: tr("tv_vid_404"),
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
                error: "${tr("tv_vid_404")}\n$e",
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
        widget.metadata.tvId != null &&
        widget.metadata.episodeNumber != null &&
        widget.metadata.seasonNumber != null) {
      final isProxyEnabled =
          Provider.of<SettingsProvider>(context, listen: false).enableProxy;
      final proxyUrl =
          Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
      try {
        final imdbValue = await fetchSocialLinks(
          Endpoints.getExternalLinksForTV(widget.metadata.tvId!, "en"),
          isProxyEnabled,
          proxyUrl,
        );
        imdbId = imdbValue.imdbId;
        if (imdbId != null) {
          final extSubs = await getExternalSubtitle(
            Endpoints.searchExternalEpisodeSubtitles(
              imdbId!,
              widget.metadata.episodeNumber!,
              widget.metadata.seasonNumber!,
              supportedLanguages[foundIndex].languageCode,
            ),
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
