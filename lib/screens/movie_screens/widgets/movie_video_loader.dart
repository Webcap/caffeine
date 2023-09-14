import 'dart:io';

import 'package:caffiene/models/download_manager.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/movie_stream.dart';
import 'package:caffiene/models/functions.dart';
import 'package:caffiene/screens/player/player.dart';
import 'package:caffiene/utils/config.dart';
import 'package:better_player/better_player.dart';
import 'package:provider/provider.dart';

class MovieVideoLoader extends StatefulWidget {
  const MovieVideoLoader(
      {required this.interstitialAd,
      required this.metadata,
      required this.download,
      Key? key})
      : super(key: key);

  final List metadata;
  final InterstitialAd interstitialAd;
  final bool download;

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
  @override
  void initState() {
    super.initState();
    widget.interstitialAd.show();
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

    if (processedLines.isEmpty) {
      throw Exception('No Timestamps found in VTT File');
    }

    return processedLines.join('\n');
  }

  void loadVideo() async {
    try {
      await moviesApi()
          .fetchMoviesForStream(Endpoints.searchMovieTVForStream1(
              widget.metadata.elementAt(1), appDep.consumetUrl))
          .then((value) {
        if (mounted) {
          setState(() {
            movies = value;
          });
        }
      });

      for (int i = 0; i < movies!.length; i++) {
        if (movies![i].releaseDate == widget.metadata.elementAt(3).toString() &&
            movies![i].type == 'Movie') {
          await moviesApi()
              .getMovieStreamEpisodes(Endpoints.getMovieTVStreamInfo1(
                  movies![i].id!, appDep.consumetUrl))
              .then((value) {
            setState(() {
              epi = value;
            });
          });
          await moviesApi()
              .getMovieStreamLinksAndSubs(Endpoints.getMovieTVStreamLinks1(
                  epi![0].id!, movies![i].id!, appDep.consumetUrl))
              .then((value) {
            setState(() {
              movieVideoSources = value;
            });
            movieVideoLinks = movieVideoSources!.videoLinks;
            movieVideoSubs = movieVideoSources!.videoSubtitles;
          });

          break;
        }
      }

      Map<String, String> videos = {};
      List<BetterPlayerSubtitlesSource> subs = [];

      if (movieVideoSubs != null) {
        if (settings.defaultSubtitleLanguage == '') {
          for (int i = 0; i < movieVideoSubs!.length - 1; i++) {
            setState(() {
              loadProgress = (i / movieVideoSubs!.length) * 100;
            });
            await getVttFileAsString(movieVideoSubs![i].url!).then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: movieVideoSubs![i].language!,
                    //  urls: [movieVideoSubs![i].url],
                    content: processVttFileTimestamps(value),
                    type: BetterPlayerSubtitlesSourceType.memory),
              });
            });
          }
        } else {
          if (movieVideoSubs!
              .where((element) => element.language!
                  .startsWith(settings.defaultSubtitleLanguage))
              .isNotEmpty) {
            await getVttFileAsString((movieVideoSubs!.where((element) => element
                    .language!
                    .startsWith(settings.defaultSubtitleLanguage))).first.url!)
                .then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: movieVideoSubs!
                        .where((element) => element.language!
                            .startsWith(settings.defaultSubtitleLanguage))
                        .first
                        .language,
                    //  urls: [movieVideoSubs![i].url],
                    selectedByDefault: true,
                    content: processVttFileTimestamps(value),
                    type: BetterPlayerSubtitlesSourceType.memory),
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

      void streamSelectBottomSheet({
        required Map vids,
      }) {
        final downloadProvider =
            Provider.of<DownloadProvider>(context, listen: false);
        vids.removeWhere((key, value) => key == 'auto');
        showModalBottomSheet(
          context: context,
          builder: (builder) {
            //final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
            return Container(
                padding: const EdgeInsets.all(8),
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Download: "${widget.metadata.elementAt(1)}"',
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Choose resolution:',
                      style: kTextSmallHeaderStyle,
                    ),
                    Column(
                      children: [
                        for (var entry in vids.entries)
                          InkWell(
                            child: ListTile(
                              onTap: () {
                                Directory? appDir = Directory(
                                    "storage/emulated/0/Cinemax/Backdrops");

                                // String outputPath =
                                //     "${appDir!.path}/output1.mp4";
                                Download dwn = Download(
                                    input: entry.value,
                                    output:
                                        '${appDir.path}/${widget.metadata.elementAt(1)}_${entry.key}p_Downloaded_from_Cinemax.mp4',
                                    progress: 0.0);
                                downloadProvider.addDownload(dwn);
                                downloadProvider.startDownload(dwn);
                              },
                              title: Text(entry.key),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios_rounded),
                            ),
                          ),
                      ],
                    )
                  ],
                ));
          },
        );
      }

      if (movieVideoLinks != null && movieVideoSubs != null) {
        if (widget.download) {
          Navigator.pop(context);
          streamSelectBottomSheet(vids: reversedVids);
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
                movieMetadata: widget.metadata,
              );
            },
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The movie couldn\'t be found on our servers :(',
              maxLines: 3,
              style: kTextSmallBodyStyle,
            ),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'The movie couldn\'t be found on our servers :( Error: ${e.toString()}',
            maxLines: 3,
            style: kTextSmallBodyStyle,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
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

class MovieVideoLoaderNoAds extends StatefulWidget {
  const MovieVideoLoaderNoAds(
      {required this.metadata, required this.download, Key? key})
      : super(key: key);

  final List metadata;
  final bool download;

  @override
  State<MovieVideoLoaderNoAds> createState() => _MovieVideoLoaderNoAdsState();
}

class _MovieVideoLoaderNoAdsState extends State<MovieVideoLoaderNoAds> {
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

    if (processedLines.isEmpty) {
      throw Exception('No Timestamps found in VTT File');
    }

    return processedLines.join('\n');
  }

  void loadVideo() async {
    try {
      await moviesApi()
          .fetchMoviesForStream(
              Endpoints.searchMovieTVForStream1(widget.metadata.elementAt(1), appDep.consumetUrl))
          .then((value) {
        if (mounted) {
          setState(() {
            movies = value;
          });
        }
      });

      for (int i = 0; i < movies!.length; i++) {
        if (movies![i].releaseDate == widget.metadata.elementAt(3).toString() &&
            movies![i].type == 'Movie') {
          await moviesApi()
              .getMovieStreamEpisodes(
                  Endpoints.getMovieTVStreamInfo1(movies![i].id!, appDep.consumetUrl))
              .then((value) {
            setState(() {
              epi = value;
            });
          });
          await moviesApi()
              .getMovieStreamLinksAndSubs(
                  Endpoints.getMovieTVStreamLinks1(epi![0].id!, movies![i].id!, appDep.consumetUrl))
              .then((value) {
            setState(() {
              movieVideoSources = value;
            });
            movieVideoLinks = movieVideoSources!.videoLinks;
            movieVideoSubs = movieVideoSources!.videoSubtitles;
          });

          break;
        }
      }

      Map<String, String> videos = {};
      List<BetterPlayerSubtitlesSource> subs = [];

      if (movieVideoSubs != null) {
        if (settings.defaultSubtitleLanguage == '') {
          for (int i = 0; i < movieVideoSubs!.length - 1; i++) {
            setState(() {
              loadProgress = (i / movieVideoSubs!.length) * 100;
            });
            await getVttFileAsString(movieVideoSubs![i].url!).then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: movieVideoSubs![i].language!,
                    //  urls: [movieVideoSubs![i].url],
                    content: processVttFileTimestamps(value),
                    type: BetterPlayerSubtitlesSourceType.memory),
              });
            });
          }
        } else {
          if (movieVideoSubs!
              .where((element) => element.language!
                  .startsWith(settings.defaultSubtitleLanguage))
              .isNotEmpty) {
            await getVttFileAsString((movieVideoSubs!.where((element) => element
                    .language!
                    .startsWith(settings.defaultSubtitleLanguage))).first.url!)
                .then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: movieVideoSubs!
                        .where((element) => element.language!
                            .startsWith(settings.defaultSubtitleLanguage))
                        .first
                        .language,
                    //  urls: [movieVideoSubs![i].url],
                    selectedByDefault: true,
                    content: processVttFileTimestamps(value),
                    type: BetterPlayerSubtitlesSourceType.memory),
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

      void streamSelectBottomSheet({
        required Map vids,
      }) {
        final downloadProvider =
            Provider.of<DownloadProvider>(context, listen: false);
        vids.removeWhere((key, value) => key == 'auto');
        showModalBottomSheet(
          context: context,
          builder: (builder) {
            //final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
            return Container(
                padding: const EdgeInsets.all(8),
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Download: "${widget.metadata.elementAt(1)}"',
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Choose resolution:',
                      style: kTextSmallHeaderStyle,
                    ),
                    Column(
                      children: [
                        for (var entry in vids.entries)
                          InkWell(
                            child: ListTile(
                              onTap: () {
                                Directory? appDir = Directory(
                                    "storage/emulated/0/Cinemax/Backdrops");

                                // String outputPath =
                                //     "${appDir!.path}/output1.mp4";
                                Download dwn = Download(
                                    input: entry.value,
                                    output:
                                        '${appDir.path}/${widget.metadata.elementAt(1)}_${entry.key}p_Downloaded_from_Cinemax.mp4',
                                    progress: 0.0);
                                downloadProvider.addDownload(dwn);
                                downloadProvider.startDownload(dwn);
                              },
                              title: Text(entry.key),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios_rounded),
                            ),
                          ),
                      ],
                    )
                  ],
                ));
          },
        );
      }

      if (movieVideoLinks != null && movieVideoSubs != null) {
        if (widget.download) {
          Navigator.pop(context);
          streamSelectBottomSheet(vids: reversedVids);
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
                movieMetadata: widget.metadata,
              );
            },
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The movie couldn\'t be found on our servers :(',
              maxLines: 3,
              style: kTextSmallBodyStyle,
            ),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'The movie couldn\'t be found on our servers :( Error: ${e.toString()}',
            maxLines: 3,
            style: kTextSmallBodyStyle,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
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
