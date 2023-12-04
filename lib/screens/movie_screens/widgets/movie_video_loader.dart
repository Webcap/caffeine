// ignore_for_file: use_build_context_synchronously
import 'package:caffiene/models/sub_languages.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/report_error_widget.dart';
import 'package:caffiene/video_providers/dcva.dart';
import 'package:caffiene/video_providers/flixhq.dart';
import 'package:caffiene/video_providers/provider_names.dart';
import 'package:caffiene/video_providers/regularVideoLinks.dart';
import 'package:caffiene/video_providers/superstream.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/screens/player/player.dart';
import 'package:caffiene/utils/config.dart';
import 'package:better_player/better_player.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class MovieVideoLoader extends StatefulWidget {
  const MovieVideoLoader(
      {required this.download,
      required this.metadata,
      required this.route,
      Key? key})
      : super(key: key);

  final bool download;
  final List metadata;
  final StreamRoute route;

  @override
  State<MovieVideoLoader> createState() => _MovieVideoLoaderState();
}

class _MovieVideoLoaderState extends State<MovieVideoLoader> {
  List<FlixHQMovieSearchEntry>? fqMovies;
  List<FlixHQMovieInfoEntries>? fqEpi;
  List<DCVASearchEntry>? dcMovies;
  List<DCVAInfoEntries>? dcEpi;
  List<DCVASearchEntry>? vaMovies;
  List<DCVAInfoEntries>? vaEpi;

  FlixHQStreamSources? fqMovieVideoSources;
  SuperstreamStreamSources? superstreamVideoSources;
  DCVAStreamSources? dramacoolVideoSources;
  DCVAStreamSources? viewasianVideoSources;
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

  /// TMDB Route
  FlixHQMovieInfoTMDBRoute? episode;

  var startAppSdk = StartAppSdk();
  StartAppInterstitialAd? interstitialAd;

  Map<String, String> videos = {};
  List<BetterPlayerSubtitlesSource> subs = [];

  late int foundIndex;
  String route = 'viewasian';

  List<String> providers = ['dramacool', 'superstream', 'viewasian', 'flixhq'];

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
        if (videoProviders[i].codeName == 'flixhq') {
          if (widget.route == StreamRoute.flixHQ) {
            await loadFlixHQNormalRoute();
            if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
              await subtitleParserFetcher(movieVideoSubs!);
              break;
            }

            if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
              break;
            }
          } else {
            await loadFlixHQTMDBRoute();
            if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
              await subtitleParserFetcher(movieVideoSubs!);
              break;
            }
            if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
              break;
            }
          }
        } else if (videoProviders[i].codeName == 'superstream') {
          await loadSuperstream();
          if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(movieVideoSubs!);
            break;
          }
          if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'dramacool') {
          await loadDramacool();
          if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'viewasian') {
          await loadViewasian();
          if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
            break;
          }
        }
      }

      if (movieVideoLinks == null || movieVideoLinks!.isEmpty) {
        Navigator.pop(context);
        showModalBottomSheet(
            builder: (context) {
              return ReportErrorWidget(
                error: tr("movie_vid_404"),
                hideButton: true,
              );
            },
            context: context);
      }

      List<MapEntry<String, String>> reversedVideoList =
          videos.entries.toList().reversed.toList();
      Map<String, String> reversedVids = Map.fromEntries(reversedVideoList);

      if (movieVideoLinks != null && mounted) {
        if (interstitialAd != null) {
          interstitialAd!.show();
          loadInterstitialAd().whenComplete(
              () => Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return Player(
                          mediaType: MediaType.movie,
                          sources: reversedVids,
                          subs: subs,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).colorScheme.background
                          ],
                          settings: settings,
                          movieMetadata: widget.metadata);
                    },
                  )));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return Player(
                  mediaType: MediaType.movie,
                  sources: reversedVids,
                  subs: subs,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.background
                  ],
                  settings: settings,
                  movieMetadata: widget.metadata);
            },
          ));
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          showModalBottomSheet(
              builder: (context) {
                return ReportErrorWidget(
                  error: tr("movie_vid_404"),
                  hideButton: true,
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

  void getAppLanguage() {
    for (int i = 0; i < supportedLanguages.length; i++) {
      if (supportedLanguages[i].languageCode ==
          settings.defaultSubtitleLanguage) {
        foundIndex = i;
        break;
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
            height: 120,
            width: 180,
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
                Visibility(
                  visible:
                      settings.defaultSubtitleLanguage != '' ? false : true,
                  child: Text(
                    '${loadProgress.toStringAsFixed(0).toString()}%',
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

  Future<void> subtitleParserFetcher(
      List<RegularSubtitleLinks> subtitles) async {
    getAppLanguage();
    if (subtitles.isNotEmpty) {
      if (supportedLanguages[foundIndex].englishName == '') {
        for (int i = 0; i < subtitles.length - 1; i++) {
          if (mounted) {
            setState(() {
              loadProgress = (i / subtitles.length) * 100;
            });
          }
          await getVttFileAsString(subtitles[i].url!).then((value) {
            subs.addAll({
              BetterPlayerSubtitlesSource(
                  name: subtitles[i].language!,
                  selectedByDefault: subtitles[i].language == 'English' ||
                      subtitles[i].language == 'English - English' ||
                      subtitles[i].language == 'English - SDH' ||
                      subtitles[i].language == 'English 1' ||
                      subtitles[i].language == 'English - English [CC]' ||
                      subtitles[i].language == 'en',
                  content: subtitles[i].url!.endsWith('srt')
                      ? value
                      : processVttFileTimestamps(value),
                  type: BetterPlayerSubtitlesSourceType.memory),
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
            await getVttFileAsString((subtitles.where((element) =>
                        element.language!.startsWith(
                            supportedLanguages[foundIndex].englishName) ||
                        element.language! ==
                            supportedLanguages[foundIndex].languageCode))
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
                    //  urls: [movieVideoSubs![i].url],
                    selectedByDefault: true,
                    content: processVttFileTimestamps(value),
                    type: BetterPlayerSubtitlesSourceType.memory),
              });
            });
          }
        } else {
          if (appDep.useExternalSubtitles) {
            await moviesApi().fetchSocialLinks(
              Endpoints.getExternalLinksForMovie(
                  widget.metadata.elementAt(0), "en"),
            ).then((value) async {
              if (value.imdbId != null) {
                await getExternalSubtitle(
                        Endpoints.searchExternalMovieSubtitles(value.imdbId!,
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

  Future<void> loadFlixHQTMDBRoute() async {
    await getMovieStreamEpisodesTMDB(Endpoints.getMovieTVStreamInfoTMDB(
            widget.metadata.elementAt(0).toString(),
            "movie",
            appDep.consumetUrl))
        .then((value) async {
      if (mounted) {
        setState(() {
          episode = value;
        });
      }

      if (episode != null &&
          episode!.id != null &&
          episode!.id!.isNotEmpty &&
          episode!.episodeId != null &&
          episode!.episodeId!.isNotEmpty) {
        await moviesApi()
            .getMovieStreamLinksAndSubsFlixHQ(
                Endpoints.getMovieTVStreamLinksTMDB(
                    appDep.consumetUrl,
                    episode!.episodeId!,
                    episode!.id!,
                    appDep.streamingServerFlixHQ))
            .then((value) {
          if (mounted) {
            if (value.messageExists == null &&
                value.videoLinks != null &&
                value.videoLinks!.isNotEmpty) {
              setState(() {
                fqMovieVideoSources = value;
              });
            } else if (value.messageExists != null ||
                value.videoLinks == null ||
                value.videoLinks!.isEmpty) {
              return;
            }
          }
          if (mounted) {
            movieVideoLinks = fqMovieVideoSources!.videoLinks;
            movieVideoSubs = fqMovieVideoSources!.videoSubtitles;
            if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
              convertVideoLinks(movieVideoLinks!);
            }
          }
        });
      }
    });
  }

  Future<void> loadDramacool() async {
    await moviesApi()
        .fetchMovieTVForStreamDCVA(Endpoints.searchMovieTVForStreamDramacool(
            removeCharacters(widget.metadata.elementAt(1)).toLowerCase(),
            appDep.consumetUrl))
        .then((value) async {
      if (mounted) {
        setState(() {
          dcMovies = value;
        });
      }

      if (dcMovies == null || dcMovies!.isEmpty) {
        return;
      }

      for (int i = 0; i < dcMovies!.length; i++) {
        if (dcMovies![i]
            .title!
            .toLowerCase()
            .contains(widget.metadata.elementAt(1).toString().toLowerCase())) {
          await moviesApi()
              .getMovieTVStreamEpisodesDCVA(
                  Endpoints.getMovieTVStreamInfoDramacool(
                      dcMovies![i].id!, appDep.consumetUrl))
              .then((value) async {
            setState(() {
              dcEpi = value;
            });
            if (dcMovies != null && dcMovies!.isNotEmpty) {
              await moviesApi()
                  .getMovieTVStreamLinksAndSubsDCVA(
                      Endpoints.getMovieTVStreamLinksDramacool(
                          dcEpi![0].id!,
                          dcMovies![i].id!,
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
                  movieVideoLinks = dramacoolVideoSources!.videoLinks;
                  movieVideoSubs = dramacoolVideoSources!.videoSubtitles;
                  if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
                    convertVideoLinks(movieVideoLinks!);
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

  Future<void> loadViewasian() async {
    await moviesApi()
        .fetchMovieTVForStreamDCVA(Endpoints.searchMovieTVForStreamViewasian(
            removeCharacters(widget.metadata.elementAt(1)).toLowerCase(),
            appDep.consumetUrl))
        .then((value) async {
      if (mounted) {
        setState(() {
          vaMovies = value;
        });
      }

      if (vaMovies == null || vaMovies!.isEmpty) {
        return;
      }

      for (int i = 0; i < vaMovies!.length; i++) {
        if (vaMovies![i]
            .title!
            .toLowerCase()
            .contains(widget.metadata.elementAt(1).toString().toLowerCase())) {
          await moviesApi()
              .getMovieTVStreamEpisodesDCVA(
                  Endpoints.getMovieTVStreamInfoViewasian(
                      vaMovies![i].id!, appDep.consumetUrl))
              .then((value) async {
            setState(() {
              vaEpi = value;
            });
            if (vaMovies != null && vaMovies!.isNotEmpty) {
              await moviesApi()
                  .getMovieTVStreamLinksAndSubsDCVA(
                      Endpoints.getMovieTVStreamLinksViewasian(
                          vaEpi![0].id!,
                          vaMovies![i].id!,
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
                  movieVideoLinks = viewasianVideoSources!.videoLinks;
                  movieVideoSubs = viewasianVideoSources!.videoSubtitles;
                  if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
                    convertVideoLinks(movieVideoLinks!);
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

  Future<void> loadFlixHQNormalRoute() async {
    await moviesApi()
        .fetchMoviesForStreamFlixHQ(Endpoints.searchMovieTVForStreamFlixHQ(
            removeCharacters(widget.metadata.elementAt(1)).toLowerCase(),
            appDep.consumetUrl))
        .then((value) async {
      if (mounted) {
        setState(() {
          fqMovies = value;
        });
      }

      if (fqMovies == null || fqMovies!.isEmpty) {
        return;
      }

      for (int i = 0; i < fqMovies!.length; i++) {
        if (fqMovies![i].releaseDate ==
                widget.metadata.elementAt(3).toString() &&
            fqMovies![i].type == 'Movie' &&
            fqMovies![i].title!.toLowerCase().contains(
                widget.metadata.elementAt(1).toString().toLowerCase())) {
          await moviesApi()
              .getMovieStreamEpisodesFlixHQ(
                  Endpoints.getMovieTVStreamInfoFlixHQ(
                      fqMovies![i].id!, appDep.consumetUrl))
              .then((value) async {
            setState(() {
              fqEpi = value;
            });
            if (fqEpi != null && fqEpi!.isNotEmpty) {
              await moviesApi()
                  .getMovieStreamLinksAndSubsFlixHQ(
                      Endpoints.getMovieTVStreamLinksFlixHQ(
                          fqEpi![0].id!,
                          fqMovies![i].id!,
                          appDep.consumetUrl,
                          appDep.streamingServerFlixHQ))
                  .then((value) {
                if (mounted) {
                  if (value.messageExists == null &&
                      value.videoLinks != null &&
                      value.videoLinks!.isNotEmpty) {
                    setState(() {
                      fqMovieVideoSources = value;
                    });
                  } else if (value.messageExists != null ||
                      value.videoLinks == null ||
                      value.videoLinks!.isEmpty) {
                    return;
                  }
                }
                if (mounted) {
                  movieVideoLinks = fqMovieVideoSources!.videoLinks;
                  movieVideoSubs = fqMovieVideoSources!.videoSubtitles;
                  if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
                    convertVideoLinks(movieVideoLinks!);
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

  Future<void> loadSuperstream() async {
    await moviesApi()
        .getSuperstreamStreamingLinks(Endpoints.getSuperstreamStreamMovie(
            'https://caffeine-api.vercel.app', widget.metadata.elementAt(0)))
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
        movieVideoLinks = superstreamVideoSources!.videoLinks;
        movieVideoSubs = superstreamVideoSources!.videoSubtitles;
        if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
          convertVideoLinks(movieVideoLinks!);
        }
      }
    });
  }
}
