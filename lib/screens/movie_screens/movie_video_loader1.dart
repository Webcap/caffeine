import 'package:better_player/better_player.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/functions.dart';
import 'package:caffiene/models/movie_stream.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/player/player.dart';
import 'package:caffiene/utils/config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieVideoLoaderOne extends StatefulWidget {
  const MovieVideoLoaderOne(
      {required this.download, required this.metadata, Key? key})
      : super(key: key);

  final bool download;
  final List metadata;

  @override
  State<MovieVideoLoaderOne> createState() => _MovieVideoLoaderOneState();
}

class _MovieVideoLoaderOneState extends State<MovieVideoLoaderOne> {
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

    return processedLines.join('\n');
  }

  void loadVideo() async {
    try {
      await moviesApi().fetchMoviesForStream(Endpoints.searchMovieTVForStream(
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
              .getMovieStreamEpisodes(Endpoints.getMovieTVStreamInfo(
                  movies![i].id!, appDep.consumetUrl))
              .then((value) {
            setState(() {
              epi = value;
            });
          });
          await moviesApi()
              .getMovieStreamLinksAndSubs(Endpoints.getMovieTVStreamLinks(
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

      if (movieVideoLinks != null && movieVideoSubs != null) {
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
    } on Exception catch (e) {
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
