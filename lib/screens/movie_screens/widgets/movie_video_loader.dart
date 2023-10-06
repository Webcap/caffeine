import 'dart:io';

import 'package:caffiene/main.dart';
import 'package:caffiene/models/download_manager.dart';
import 'package:caffiene/models/sub_languages.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/movie_stream.dart';
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
      Key? key})
      : super(key: key);

  final bool download;
  final List metadata;
  final StreamRoute route;

  @override
  State<MovieVideoLoader> createState() => _MovieVideoLoaderState();
}

class _MovieVideoLoaderState extends State<MovieVideoLoader> {
  List<MovieResults>? movies;
  List<MovieEpisodes>? epi;
  MovieVideoSources? movieVideoSources;
  List<MovieVideoLinks>? movieVideoLinks;
  List<MovieVideoSubtitles>? movieVideoSubs;
  double loadProgress = 0.00;
  late SettingsProvider settings =
      Provider.of<SettingsProvider>(context, listen: false);
  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);

  /// TMDB Route
  MovieInfoTMDBRoute? episode;

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  String processVttFileTimestamps(String vttFile) {
    final lines = vttFile.split('\n');
    final processedLines = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('-->') && line.trim().length == 23) {
        String endTimeModifiedString =
            '${line.trim().substring(0, line.trim().length - 9)}00:${line.trim().substring(line.trim().length - 9)}';
        String finalStr = '00:$endTimeModifiedString';
        processedLines.add(finalStr);
      } else {
        processedLines.add(line);
      }
    }

    return processedLines.join('\n');
  }

  void loadVideo() async {
    try {
      if (widget.route == StreamRoute.flixHQ) {
        await moviesApi().fetchMoviesForStream(Endpoints.searchMovieTVForStream(
                widget.metadata.elementAt(1), appDep.consumetUrl))
            .then((value) async {
          if (mounted) {
            setState(() {
              movies = value;
            });
          }

          for (int i = 0; i < movies!.length; i++) {
            if (movies![i].releaseDate ==
                    widget.metadata.elementAt(3).toString() &&
                movies![i].type == 'Movie') {
              await moviesApi()
                  .getMovieStreamEpisodes(Endpoints.getMovieTVStreamInfo(
                      movies![i].id!, appDep.consumetUrl))
                  .then((value) async {
                setState(() {
                  epi = value;
                });
                await moviesApi()
                    .getMovieStreamLinksAndSubs(
                        Endpoints.getMovieTVStreamLinks(
                            epi![0].id!,
                            movies![i].id!,
                            appDep.consumetUrl,
                            appDep.streamingServer))
                    .then((value) {
                  setState(() {
                    movieVideoSources = value;
                  });
                  movieVideoLinks = movieVideoSources!.videoLinks;
                  movieVideoSubs = movieVideoSources!.videoSubtitles;
                });
              });

              break;
            }
          }
        });
      } else {
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
              episode!.episodeId != null) {
            await moviesApi()
                .getMovieStreamLinksAndSubs(
                    Endpoints.getMovieTVStreamLinksTMDB(
                        appDep.consumetUrl,
                        episode!.episodeId!,
                        episode!.id!,
                        appDependencyProvider.streamingServer))
                .then((value) {
              if (mounted) {
                setState(() {
                  movieVideoSources = value;
                });
              }
              movieVideoLinks = movieVideoSources!.videoLinks;
              movieVideoSubs = movieVideoSources!.videoSubtitles;
            });
          }
        });
      }

      Map<String, String> videos = {};
      List<BetterPlayerSubtitlesSource> subs = [];

      late int foundIndex;

      for (int i = 0; i < supportedLanguages.length; i++) {
        if (supportedLanguages[i].languageCode ==
            settings.defaultSubtitleLanguage) {
          foundIndex = i;
          break;
        }
      }

      if (movieVideoSubs != null) {
        if (supportedLanguages[foundIndex].englishName == '') {
          for (int i = 0; i < movieVideoSubs!.length - 1; i++) {
            if (mounted) {
              setState(() {
                loadProgress = (i / movieVideoSubs!.length) * 100;
                print(loadProgress);
              });
            }
            await getVttFileAsString(movieVideoSubs![i].url!).then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: movieVideoSubs![i].language!,
                    selectedByDefault: movieVideoSubs![i].language ==
                            'English' ||
                        movieVideoSubs![i].language == 'English - English' ||
                        movieVideoSubs![i].language == 'English - SDH' ||
                        movieVideoSubs![i].language == 'English 1' ||
                        movieVideoSubs![i].language == 'English - English [CC]',
                    content: processVttFileTimestamps(value),
                    type: BetterPlayerSubtitlesSourceType.memory),
              });
            });
          }
        } else {
          if (movieVideoSubs!
              .where((element) => element.language!
                  .startsWith(supportedLanguages[foundIndex].englishName))
              .isNotEmpty) {
            await getVttFileAsString((movieVideoSubs!.where((element) =>
                        element.language!.startsWith(
                            supportedLanguages[foundIndex].englishName)))
                    .first
                    .url!)
                .then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: movieVideoSubs!
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
          } else {
            print("CALLEDDDDDDDDDDD");
            await moviesApi()
                .fetchSocialLinks(
              Endpoints.getExternalLinksForMovie(
                  widget.metadata.elementAt(0), "en"),
            ).then((value) async {
              await getExternalSubtitle(Endpoints.searchExternalMovieSubtitles(
                      value.imdbId!,
                      supportedLanguages[foundIndex].languageCode))
                  .then((value) async {
                if (value.isNotEmpty) {
                  await downloadExternalSubtitle(
                          Endpoints.externalSubtitleDownload(),
                          value[0].attr!.files![0].fileId)
                      .then((value) async {
                    subs.addAll({
                      BetterPlayerSubtitlesSource(
                          name: supportedLanguages[foundIndex].englishName,
                          urls: [value.link],
                          selectedByDefault: true,
                          type: BetterPlayerSubtitlesSourceType.network)
                    });
                  });
                }
              });
            });
          }
        }
      }

      if (movieVideoLinks != null) {
        for (int k = 0; k < movieVideoLinks!.length; k++) {
          videos.addAll({
            movieVideoLinks![k].quality!: movieVideoLinks![k].url!,
          });
        }
      }

      List<MapEntry<String, String>> reversedVideoList =
          videos.entries.toList().reversed.toList();
      Map<String, String> reversedVids = Map.fromEntries(reversedVideoList);

      if (movieVideoLinks != null && mounted) {
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tr("movie_vid_404"),
                maxLines: 3,
                style: kTextSmallBodyStyle,
              ),
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(
                "movie_vid_404_desc",
                namedArgs: {"error": e.toString()},
              ),
              maxLines: 3,
              style: kTextSmallBodyStyle,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
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
              visible: settings.defaultSubtitleLanguage != '' ? false : true,
              child: Text(
                '${loadProgress.toStringAsFixed(0).toString()}%',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.background),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
