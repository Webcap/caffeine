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
      {required this.videoTitle,
      required this.thumbnail,
      required this.releaseYear,
      required this.interstitialAd,
      required this.movieId,
      Key? key})
      : super(key: key);

  final String videoTitle;
  final int releaseYear;
  final String? thumbnail;
  final int? movieId;
  final InterstitialAd interstitialAd;

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
  late int maxBuffer;
  late int seekDuration;
  late int videoQuality;
  late String subLanguage;
  late bool autoFS;

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
    setState(() {
      maxBuffer = Provider.of<SettingsProvider>(context, listen: false)
          .defaultMaxBufferDuration;
      seekDuration = Provider.of<SettingsProvider>(context, listen: false)
          .defaultSeekDuration;
      videoQuality = Provider.of<SettingsProvider>(context, listen: false)
          .defaultVideoResolution;
      subLanguage = Provider.of<SettingsProvider>(context, listen: false)
          .defaultSubtitleLanguage;
      autoFS =
          Provider.of<SettingsProvider>(context, listen: false).defaultViewMode;
    });
    try {
      await moviesApi()
          .fetchMoviesForStream(
              Endpoints.searchMovieTVForStream(widget.videoTitle))
          .then((value) {
        if (mounted) {
          setState(() {
            movies = value;
          });
        }
      });

      for (int i = 0; i < movies!.length; i++) {
        if (movies![i].releaseDate == widget.releaseYear.toString() &&
            movies![i].type == 'Movie') {
          await moviesApi()
              .getMovieStreamEpisodes(
                  Endpoints.getMovieTVStreamInfo(movies![i].id!))
              .then((value) {
            setState(() {
              epi = value;
            });
          });
          await moviesApi()
              .getMovieStreamLinksAndSubs(
                  Endpoints.getMovieTVStreamLinks(epi![0].id!, movies![i].id!))
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
        if (subLanguage == '') {
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
              .where((element) => element.language!.startsWith(subLanguage))
              .isNotEmpty) {
            await getVttFileAsString((movieVideoSubs!.where(
                        (element) => element.language!.startsWith(subLanguage)))
                    .first
                    .url!)
                .then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: movieVideoSubs!
                        .where((element) =>
                            element.language!.startsWith(subLanguage))
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

      if (movieVideoLinks != null && movieVideoSubs != null) {
        // Create a new watch history entry.

        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return Player(
              sources: reversedVids,
              subs: subs,
              thumbnail: widget.thumbnail,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.background
              ],
              videoProperties: [maxBuffer, seekDuration, videoQuality, autoFS],
            );
          },
        ));
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
              visible: subLanguage != '' ? false : true,
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
