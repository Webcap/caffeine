import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/movie_stream.dart';
import 'package:caffiene/models/functions.dart';
import 'package:caffiene/screens/player/player.dart';
import 'package:caffiene/utils/admob.dart';
import 'package:caffiene/utils/config.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:http/http.dart' as http;
import 'package:better_player/better_player.dart';

class MovieVideoLoader extends StatefulWidget {
  const MovieVideoLoader(
      {required this.videoTitle,
      required this.thumbnail,
      required this.releaseYear,
      required this.interstitialAd,
      Key? key})
      : super(key: key);

  final String videoTitle;
  final int releaseYear;
  final String? thumbnail;
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

  @override
  void initState() {
    super.initState();
    if (showAds == true) {
      widget.interstitialAd.show();
    }
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
      await moviesApi()
          .fetchMoviesForStream(
              Endpoints.searchMovieTVForStream(widget.videoTitle))
          .then((value) {
        setState(() {
          movies = value;
        });
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
        for (int i = 0; i < movieVideoSubs!.length; i++) {
          await getVttFileAsString(movieVideoSubs![i].url!).then((value) {
            subs.addAll({
              BetterPlayerSubtitlesSource(
                  name: movieVideoSubs![i].language!,
                  //  urls: [movieVideoSubs![i].url],
                  content: processVttFileTimestamps(value),
                  selectedByDefault: movieVideoSubs![i].language == 'English' ||
                          movieVideoSubs![i].language == 'English - English' ||
                          movieVideoSubs![i].language == 'English - SDH'
                      ? true
                      : false,
                  type: BetterPlayerSubtitlesSourceType.memory),
            });
          });
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
              sources: reversedVids,
              subs: subs,
              thumbnail: widget.thumbnail,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.background
              ],
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
    SpinKitChasingDots spinKitChasingDots = const SpinKitChasingDots(
      color: Colors.white,
      size: 60,
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            spinKitChasingDots,
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Initializing player',
                style: kTextSmallHeaderStyle,
              ),
            )
          ],
        ),
      ),
    );
  }
}
