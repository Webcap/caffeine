// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:better_player/better_player.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/sub_languages.dart';
import 'package:caffiene/models/tv_stream_metadata.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/report_error_widget.dart';
import 'package:caffiene/video_providers/dcva.dart';
import 'package:caffiene/video_providers/flixhq.dart';
import 'package:caffiene/video_providers/provider_names.dart';
import 'package:caffiene/video_providers/regularVideoLinks.dart';
import 'package:caffiene/video_providers/superstream.dart';
import 'package:caffiene/video_providers/zoro.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/api/tv_api.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/screens/player/player.dart';
import 'package:caffiene/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class TVVideoLoader extends StatefulWidget {
  const TVVideoLoader(
      {required this.metadata,
      required this.download,
      required this.route,
      Key? key})
      : super(key: key);

  final TVStreamMetadata metadata;
  final bool download;
  final StreamRoute route;

  @override
  State<TVVideoLoader> createState() => _TVVideoLoaderState();
}

class _TVVideoLoaderState extends State<TVVideoLoader> {
  String route = 'viewasian';
  List<String> providers = ['dramacool', 'superstream', 'viewasian', 'flixhq'];
  List<FlixHQTVSearchEntry>? fqShows;
  List<FlixHQTVInfoEntries>? fqEpi;
  List<DCVASearchEntry>? dcShows;
  List<DCVAInfoEntries>? dcEpi;
  List<DCVASearchEntry>? vaShows;
  List<DCVAInfoEntries>? vaEpi;
  List<ZoroSearchEntry>? zoroShows;
  List<ZoroInfoEntries>? zoroEpi;

  FlixHQStreamSources? fqTVVideoSources;
  SuperstreamStreamSources? superstreamVideoSources;
  DCVAStreamSources? dramacoolVideoSources;
  DCVAStreamSources? viewasianVideoSources;
  ZoroStreamSources? zoroVideoSources;

  List<RegularVideoLinks>? tvVideoLinks;
  List<RegularSubtitleLinks>? tvVideoSubs;

  FlixHQTVInfo? tvInfo;
  double loadProgress = 0.00;
  late SettingsProvider settings =
      Provider.of<SettingsProvider>(context, listen: false);
  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);
  List<VideoProvider> videoProviders = [];
  late SettingsProvider prefString =
      Provider.of<SettingsProvider>(context, listen: false);

  /// TMDB Route
  FlixHQTVInfoTMDBRoute? tvInfoTMDB;

  var startAppSdk = StartAppSdk();
  StartAppInterstitialAd? interstitialAd;

  late int foundIndex;

  Map<String, String> videos = {};
  List<BetterPlayerSubtitlesSource> subs = [];

  late String currentProvider;

  @override
  void initState() {
    super.initState();
    videoProviders.addAll(
        parseProviderPrecedenceString(prefString.proPreference)
            .where((provider) => provider != null)
            .cast<VideoProvider>());
    if (appDep.enableADS) {
      loadInterstitialAd();
    }
    loadVideo();
  }

  Future<void> loadInterstitialAd() async {
    startAppSdk.loadInterstitialAd().then((interstitialAd) {
      setState(() {
        this.interstitialAd = interstitialAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Interstitial ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Interstitial ad: $error");
    });
  }

  void loadVideo() async {
    try {
      for (int i = 0; i < videoProviders.length; i++) {
        setState(() {
          currentProvider = videoProviders[i].fullName;
        });
        if (videoProviders[i].codeName == 'flixhq') {
          if (widget.route == StreamRoute.flixHQ) {
            await loadFlixHQNormalRoute();
            if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
              await subtitleParserFetcher(tvVideoSubs!);
              break;
            }

            if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
              break;
            }
          } else {
            await loadFlixHQTMDBRoute();
            if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
              await subtitleParserFetcher(tvVideoSubs!);
              break;
            }
            if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
              break;
            }
          }
        } else if (videoProviders[i].codeName == 'superstream') {
          await loadSuperstream();
          if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(tvVideoSubs!);
            break;
          }
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'dramacool') {
          await loadDramacool();
          if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(tvVideoSubs!);
            break;
          }
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'viewasian') {
          await loadViewasian();
          if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(tvVideoSubs!);
            break;
          }
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'zoro') {
          await loadZoro();
          if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(tvVideoSubs!);
            break;
          }
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            break;
          }
        }
      }

      if ((tvVideoLinks == null || tvVideoLinks!.isEmpty) && mounted) {
        Navigator.pop(context);
        showModalBottomSheet(
            builder: (context) {
              return ReportErrorWidget(
                error: tr("tv_vid_404"),
                hideButton: true,
              );
            },
            context: context);
      }

      List<MapEntry<String, String>> reversedVideoList =
          videos.entries.toList().reversed.toList();
      Map<String, String> reversedVids = Map.fromEntries(reversedVideoList);

      if (tvVideoLinks != null && mounted) {
        if (interstitialAd != null) {
          interstitialAd!.show();
          loadInterstitialAd().whenComplete(
              () => Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return Player(
                          mediaType: MediaType.tvShow,
                          sources: reversedVids,
                          subs: subs,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).colorScheme.background
                          ],
                          settings: settings,
                          tvMetadata: widget.metadata);
                    },
                  )));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return Player(
                  mediaType: MediaType.tvShow,
                  sources: reversedVids,
                  subs: subs,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.background
                  ],
                  settings: settings,
                  tvMetadata: widget.metadata);
            },
          ));
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          showModalBottomSheet(
              builder: (context) {
                return ReportErrorWidget(
                  error: tr("tv_vid_404"),
                  hideButton: true,
                );
              },
              context: context);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       tr("tv_vid_404"),
          //       maxLines: 3,
          //       style: kTextSmallBodyStyle,
          //     ),
          //     duration: const Duration(seconds: 3),
          //   ),
          // );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            height: 150,
            width: 190,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  appConfig.app_icon,
                  height: 65,
                  width: 65,
                ),
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(width: 160, child: LinearProgressIndicator()),
                const SizedBox(
                  height: 4,
                ),
                RichText(
                    text: TextSpan(style: TextStyle(fontSize: 15), children: [
                  TextSpan(
                      text: 'Fetching: ',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.background,
                          fontFamily: 'Poppins')),
                  TextSpan(
                      text: currentProvider,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.background,
                        fontFamily: 'PoppinsBold',
                      ))
                ])),
                Visibility(
                  visible:
                      settings.defaultSubtitleLanguage != '' ? false : true,
                  child: Text(
                    'Subtitle load progress: ${loadProgress.toStringAsFixed(0).toString()}%',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.background),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> loadDramacool() async {
    if (mounted) {
      await moviesApi().fetchMovieTVForStreamDCVA(Endpoints.searchMovieTVForStreamDramacool(
                  removeCharacters(widget.metadata.seriesName!),
                  appDep.consumetUrl)
              .toLowerCase())
          .then((value) async {
        if (mounted) {
          setState(() {
            dcShows = value;
          });
        }

        if (dcShows == null || dcShows!.isEmpty) {
          return;
        }

        for (int i = 0; i < dcShows!.length; i++) {
          if (removeCharacters(dcShows![i].title!).toLowerCase().contains(
                  removeCharacters(widget.metadata.seriesName!.toString())
                      .toLowerCase()) ||
              dcShows![i]
                  .title!
                  .contains(widget.metadata.seriesName!.toString())) {
            await moviesApi().getMovieTVStreamEpisodesDCVA(
                    Endpoints.getMovieTVStreamInfoDramacool(
                        dcShows![i].id!, appDep.consumetUrl))
                .then((value) async {
              setState(() {
                dcEpi = value;
              });
              if (dcShows != null && dcShows!.isNotEmpty) {
                bool doesntExist = dcEpi!
                    .where((element) =>
                        element.episode ==
                        widget.metadata.episodeNumber!.toString())
                    .isEmpty;
                if (doesntExist) {
                  return;
                }
                await moviesApi()
                    .getMovieTVStreamLinksAndSubsDCVA(
                        Endpoints.getMovieTVStreamLinksDramacool(
                            dcEpi!
                                .where((element) =>
                                    element.episode ==
                                    widget.metadata.episodeNumber!.toString())
                                .first
                                .id!,
                            dcShows![i].id!,
                            appDep.consumetUrl,
                            appDep.streamingServerDCVA))
                    .then((value) {
                  if (mounted) {
                    if (value.messageExists == null &&
                        value.videoLinks != null &&
                        value.videoLinks!.isNotEmpty) {
                      setState(() {
                        dramacoolVideoSources = value;
                      });
                    } else if (value.messageExists != null ||
                        value.videoLinks == null ||
                        value.videoLinks!.isEmpty) {
                      return;
                    }
                  }
                  if (mounted) {
                    tvVideoLinks = dramacoolVideoSources!.videoLinks;
                    tvVideoSubs = dramacoolVideoSources!.videoSubtitles;
                    if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
                      convertVideoLinks(tvVideoLinks!);
                    }
                  }
                });
              }
            });

            break;
          }
        }
      });
    }
  }

  Future<void> loadSuperstream() async {
    if (mounted) {
      await moviesApi()
          .getSuperstreamStreamingLinks(Endpoints.getSuperstreamStreamTV(
              appDep.caffeineAPIURL,
              widget.metadata.tvId!,
              widget.metadata.seasonNumber!,
              widget.metadata.episodeNumber!))
          .then((value) {
        if (mounted) {
          if (value.messageExists == null &&
              value.videoLinks != null &&
              value.videoLinks!.isNotEmpty) {
            setState(() {
              superstreamVideoSources = value;
            });
          } else if (value.messageExists != null ||
              value.videoLinks == null ||
              value.videoLinks!.isEmpty) {
            return;
          }
        }
        if (mounted) {
          tvVideoLinks = superstreamVideoSources!.videoLinks;
          tvVideoSubs = superstreamVideoSources!.videoSubtitles;
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            convertVideoLinks(tvVideoLinks!);
          }
        }
      });
    }
  }

  Future<void> loadFlixHQNormalRoute() async {
    late int totalSeasons;
    if (mounted) {
      await tvApi().fetchTVDetails(Endpoints.tvDetailsUrl(widget.metadata.tvId!, "en"))
          .then(
        (value) async {
          totalSeasons = value.numberOfSeasons!;
          await tvApi().fetchTVForStreamFlixHQ(Endpoints.searchMovieTVForStreamFlixHQ(
                  removeCharacters(widget.metadata.seriesName!).toLowerCase(),
                  appDep.consumetUrl))
              .then((value) async {
            if (mounted) {
              setState(() {
                fqShows = value;
              });
            }
            if (fqShows == null || fqShows!.isEmpty) {
              return;
            }
            for (int i = 0; i < fqShows!.length; i++) {
              if (fqShows![i].seasons == totalSeasons &&
                  fqShows![i].type == 'TV Series' &&
                  (removeCharacters(fqShows![i].title!).toLowerCase().contains(
                          removeCharacters(widget.metadata.seriesName!)
                              .toString()
                              .toLowerCase()) ||
                      fqShows![i]
                          .title!
                          .contains(widget.metadata.seriesName!.toString()))) {
                await tvApi().getTVStreamEpisodesFlixHQ(
                        Endpoints.getMovieTVStreamInfoFlixHQ(
                            fqShows![i].id!, appDep.consumetUrl))
                    .then((value) async {
                  setState(() {
                    tvInfo = value;
                    fqEpi = tvInfo!.episodes;
                  });

                  for (int k = 0; k < fqEpi!.length; k++) {
                    if (fqEpi![k].episode == widget.metadata.episodeNumber! &&
                        fqEpi![k].season == widget.metadata.seasonNumber!) {
                      await tvApi().getTVStreamLinksAndSubsFlixHQ(
                              Endpoints.getMovieTVStreamLinksFlixHQ(
                                  fqEpi![k].id!,
                                  fqShows![i].id!,
                                  appDep.consumetUrl,
                                  appDep.streamingServerFlixHQ))
                          .then((value) {
                        if (value.messageExists == null &&
                            value.videoLinks != null &&
                            value.videoLinks!.isNotEmpty) {
                          if (mounted) {
                            setState(() {
                              fqTVVideoSources = value;
                            });
                          }
                        } else if (value.messageExists != null ||
                            value.videoLinks == null ||
                            value.videoLinks!.isEmpty) {
                          return;
                        }
                        if (mounted) {
                          tvVideoLinks = fqTVVideoSources!.videoLinks;
                          tvVideoSubs = fqTVVideoSources!.videoSubtitles;
                          if (tvVideoLinks != null &&
                              tvVideoLinks!.isNotEmpty) {
                            convertVideoLinks(tvVideoLinks!);
                          }
                        }
                      });
                      break;
                    }
                  }
                });

                break;
              }

              if (fqShows![i].seasons == (totalSeasons - 1) &&
                  fqShows![i].type == 'TV Series') {
                await tvApi().getTVStreamEpisodesFlixHQ(
                        Endpoints.getMovieTVStreamInfoFlixHQ(
                            fqShows![i].id!, appDep.consumetUrl))
                    .then((value) async {
                  setState(() {
                    tvInfo = value;
                    fqEpi = tvInfo!.episodes;
                  });

                  for (int k = 0; k < fqEpi!.length; k++) {
                    if (fqEpi![k].episode == widget.metadata.episodeNumber! &&
                        fqEpi![k].season == widget.metadata.seasonNumber!) {
                      await tvApi().getTVStreamLinksAndSubsFlixHQ(
                              Endpoints.getMovieTVStreamLinksFlixHQ(
                                  fqEpi![k].id!,
                                  fqShows![i].id!,
                                  appDep.consumetUrl,
                                  appDep.streamingServerFlixHQ))
                          .then((value) {
                        setState(() {
                          fqTVVideoSources = value;
                        });
                        if (mounted) {
                          tvVideoLinks = fqTVVideoSources!.videoLinks;
                          tvVideoSubs = fqTVVideoSources!.videoSubtitles;
                          if (tvVideoLinks != null &&
                              tvVideoLinks!.isNotEmpty) {
                            convertVideoLinks(tvVideoLinks!);
                          }
                        }
                      });
                      break;
                    }
                  }
                });

                break;
              }
            }
          });
        },
      );
    }
  }

  Future<void> loadFlixHQTMDBRoute() async {
    if (mounted) {
      await getTVStreamEpisodesTMDB(Endpoints.getMovieTVStreamInfoTMDB(
              widget.metadata.tvId!.toString(), "tv", appDep.consumetUrl))
          .then((value) async {
        setState(() {
          tvInfoTMDB = value;
        });
        if (widget.metadata.seasonNumber! != 0) {
          if (tvInfoTMDB!.id != null &&
              tvInfoTMDB!.seasons != null &&
              tvInfoTMDB!.seasons![widget.metadata.seasonNumber! - 1]
                      .episodes![widget.metadata.episodeNumber! - 1].id !=
                  null) {
            await tvApi().getTVStreamLinksAndSubsFlixHQ(
                    Endpoints.getMovieTVStreamLinksTMDB(
                        appDep.consumetUrl,
                        tvInfoTMDB!.seasons![widget.metadata.seasonNumber! - 1]
                            .episodes![widget.metadata.episodeNumber! - 1].id!,
                        tvInfoTMDB!.id!,
                        appDep.streamingServerFlixHQ))
                .then((value) {
              if (value.messageExists == null &&
                  value.videoLinks != null &&
                  value.videoLinks!.isNotEmpty) {
                if (mounted) {
                  setState(() {
                    fqTVVideoSources = value;
                  });
                }
              } else if (value.messageExists != null ||
                  value.videoLinks == null ||
                  value.videoLinks!.isEmpty) {
                return;
              }
              if (mounted) {
                tvVideoLinks = fqTVVideoSources!.videoLinks;
                tvVideoSubs = fqTVVideoSources!.videoSubtitles;
                if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
                  convertVideoLinks(tvVideoLinks!);
                }
              }
            });
          }
        }
      });
    }
  }

  void getAppLanguage() {
    for (int i = 0; i < supportedLanguages.length; i++) {
      if (supportedLanguages[i].languageCode ==
          settings.defaultSubtitleLanguage) {
        foundIndex = i;
        break;
      }
    }
  }

  Future<void> subtitleParserFetcher(
      List<RegularSubtitleLinks> subtitles) async {
    getAppLanguage();
    if (subtitles.isNotEmpty) {
      if (supportedLanguages[foundIndex].englishName == '') {
        for (int i = 0; i < subtitles.length - 1; i++) {
          setState(() {
            loadProgress = (i / subtitles.length) * 100;
          });
          await getVttFileAsString(subtitles[i].url!).then((value) {
            subs.addAll({
              BetterPlayerSubtitlesSource(
                  name: subtitles[i].language!,
                  content: processVttFileTimestamps(value),
                  selectedByDefault: subtitles[i].language == 'English' ||
                          subtitles[i].language == 'English - English' ||
                          subtitles[i].language == 'English - SDH' ||
                          subtitles[i].language == 'English 1' ||
                          subtitles[i].language == 'English - English [CC]' ||
                          subtitles[i].language == 'en'
                      ? true
                      : false,
                  type: BetterPlayerSubtitlesSourceType.memory)
            });
          });
        }
      } else {
        if (subtitles
                .where((element) => element.language!
                    .startsWith(supportedLanguages[foundIndex].englishName))
                .isNotEmpty ||
            subtitles
                .where((element) =>
                    element.language ==
                    supportedLanguages[foundIndex].languageCode)
                .isNotEmpty) {
          if (settings.fetchSpecificLangSubs) {
            for (int i = 0; i < subtitles.length; i++) {
              if (subtitles[i]
                      .language!
                      .startsWith(supportedLanguages[foundIndex].englishName) ||
                  subtitles[i].language! ==
                      supportedLanguages[foundIndex].languageCode) {
                await getVttFileAsString(subtitles[i].url!).then((value) {
                  subs.add(
                    BetterPlayerSubtitlesSource(
                        name: subtitles[i].language,
                        selectedByDefault: true,
                        content: processVttFileTimestamps(value),
                        type: BetterPlayerSubtitlesSourceType.memory),
                  );
                });
              }
            }
          } else {
            await getVttFileAsString(subtitles
                    .where((element) =>
                        element.language!.startsWith(
                            supportedLanguages[foundIndex].englishName) ||
                        element.language! ==
                            supportedLanguages[foundIndex].languageCode)
                    .first
                    .url!)
                .then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: subtitles
                        .where((element) => element.language!.startsWith(
                            supportedLanguages[foundIndex].englishName))
                        .first
                        .language,
                    content: processVttFileTimestamps(value),
                    selectedByDefault: true,
                    type: BetterPlayerSubtitlesSourceType.memory)
              });
            });
          }
        } else {
          if (appDep.useExternalSubtitles) {
            await moviesApi().fetchSocialLinks(
              Endpoints.getExternalLinksForTV(widget.metadata.tvId!, "en"),
            ).then((value) async {
              if (value.imdbId != null) {
                await getExternalSubtitle(
                        Endpoints.searchExternalEpisodeSubtitles(
                            value.imdbId!,
                            widget.metadata.episodeNumber!,
                            widget.metadata.seasonNumber!,
                            supportedLanguages[foundIndex].languageCode),
                        appDep.opensubtitlesKey)
                    .then((value) async {
                  if (value.isNotEmpty &&
                      value[0].attr!.files![0].fileId != null) {
                    await downloadExternalSubtitle(
                            Endpoints.externalSubtitleDownload(),
                            value[0].attr!.files![0].fileId!,
                            appDep.opensubtitlesKey)
                        .then((value) async {
                      if (value.link != null) {
                        subs.addAll({
                          BetterPlayerSubtitlesSource(
                              name: supportedLanguages[foundIndex].englishName,
                              urls: [value.link],
                              selectedByDefault: true,
                              type: BetterPlayerSubtitlesSourceType.network)
                        });
                      }
                    });
                  }
                });
              }
            });
          }
        }
      }
    }
  }

  void convertVideoLinks(List<RegularVideoLinks> vids) {
    for (int k = 0; k < vids.length; k++) {
      if (vids[k].quality! == 'unknown quality') {
        videos.addAll({
          "${vids[k].quality!} $k": vids[k].url!,
        });
      } else {
        videos.addAll({
          vids[k].quality!: vids[k].url!,
        });
      }
    }
  }

  Future<void> loadViewasian() async {
    if (mounted) {
      await moviesApi().fetchMovieTVForStreamDCVA(Endpoints.searchMovieTVForStreamViewasian(
              removeCharacters(widget.metadata.seriesName!).toLowerCase(),
              appDep.consumetUrl))
          .then((value) async {
        if (mounted) {
          setState(() {
            vaShows = value;
          });
        }

        if (vaShows == null || vaShows!.isEmpty) {
          return;
        }

        for (int i = 0; i < vaShows!.length; i++) {
          if (removeCharacters(vaShows![i].title!).toLowerCase().contains(
                  removeCharacters(widget.metadata.seriesName!.toString())
                      .toLowerCase()) ||
              vaShows![i]
                  .title!
                  .contains(widget.metadata.seriesName!.toString())) {
            await moviesApi().getMovieTVStreamEpisodesDCVA(
                    Endpoints.getMovieTVStreamInfoViewasian(
                        vaShows![i].id!, appDep.consumetUrl))
                .then((value) async {
              setState(() {
                vaEpi = value;
              });
              if (vaShows != null && vaShows!.isNotEmpty) {
                bool doesntExist = vaEpi!
                    .where((element) =>
                        element.episode ==
                        widget.metadata.episodeNumber!.toString())
                    .isEmpty;
                if (doesntExist) {
                  return;
                }
                await moviesApi().getMovieTVStreamLinksAndSubsDCVA(
                        Endpoints.getMovieTVStreamLinksViewasian(
                            vaEpi!
                                .where((element) =>
                                    element.episode ==
                                    widget.metadata.episodeNumber!.toString())
                                .first
                                .id!,
                            vaShows![i].id!,
                            appDep.consumetUrl,
                            appDep.streamingServerDCVA))
                    .then((value) {
                  if (mounted) {
                    if (value.messageExists == null &&
                        value.videoLinks != null &&
                        value.videoLinks!.isNotEmpty) {
                      setState(() {
                        viewasianVideoSources = value;
                      });
                    } else if (value.messageExists != null ||
                        value.videoLinks == null ||
                        value.videoLinks!.isEmpty) {
                      return;
                    }
                  }
                  if (mounted) {
                    tvVideoLinks = viewasianVideoSources!.videoLinks;
                    tvVideoSubs = viewasianVideoSources!.videoSubtitles;
                    if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
                      convertVideoLinks(tvVideoLinks!);
                    }
                  }
                });
              }
            });

            break;
          }
        }
      });
    }
  }

  Future<void> loadZoro() async {
    if (mounted) {
      await moviesApi().fetchMovieTVForStreamZoro(Endpoints.searchZoroMoviesTV(
        appDep.consumetUrl,
        removeCharacters(widget.metadata.seriesName!).toLowerCase(),
      )).then((value) async {
        if (mounted) {
          setState(() {
            zoroShows = value;
          });
        }

        if (zoroShows == null || zoroShows!.isEmpty) {
          return;
        }

        for (int i = 0; i < zoroShows!.length; i++) {
          if ((removeCharacters(zoroShows![i].title!).toLowerCase().contains(
                      widget.metadata.seriesName!.toString().toLowerCase()) ||
                  zoroShows![i]
                      .title!
                      .contains(widget.metadata.seriesName!.toString())) &&
              zoroShows![i].type == 'TV') {
            await moviesApi().getMovieTVStreamEpisodesZoro(Endpoints.getMovieTVInfoZoro(
                    appDep.consumetUrl, zoroShows![i].id!))
                .then((value) async {
              setState(() {
                zoroEpi = value;
              });
              if (zoroShows != null && zoroShows!.isNotEmpty) {
                bool doesntExist = zoroEpi!
                    .where((element) =>
                        element.episode ==
                        widget.metadata.episodeNumber!.toString())
                    .isEmpty;
                if (doesntExist) {
                  return;
                }
                await moviesApi().getMovieTVStreamLinksAndSubsZoro(
                        Endpoints.getMovieTVStreamLinksZoro(
                            appDep.consumetUrl,
                            zoroEpi!
                                .where((element) =>
                                    element.episode ==
                                    widget.metadata.episodeNumber!.toString())
                                .first
                                .id!,
                            appDep.streamingServerFlixHQ))
                    .then((value) {
                  if (mounted) {
                    if (value.messageExists == null &&
                        value.videoLinks != null &&
                        value.videoLinks!.isNotEmpty) {
                      setState(() {
                        zoroVideoSources = value;
                      });
                    } else if (value.messageExists != null ||
                        value.videoLinks == null ||
                        value.videoLinks!.isEmpty) {
                      return;
                    }
                  }
                  if (mounted) {
                    tvVideoLinks = zoroVideoSources!.videoLinks;
                    tvVideoSubs = zoroVideoSources!.videoSubtitles;
                    if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
                      convertVideoLinks(tvVideoLinks!);
                    }
                  }
                });
              }
            });

            break;
          }
        }
      });
    }
  }
}
