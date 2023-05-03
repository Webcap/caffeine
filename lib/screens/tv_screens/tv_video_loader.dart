import 'dart:convert';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/api/tv_api.dart';
import 'package:login/models/tv_stream.dart';
import 'package:login/models/functions.dart';
import 'package:http/http.dart' as http;
import 'package:login/screens/player/player.dart';
import 'package:login/utils/config.dart';


class TVVideoLoader extends StatefulWidget {
  const TVVideoLoader(
      {required this.videoTitle,
      required this.thumbnail,
      required this.seasons,
      required this.episodeNumber,
      required this.seasonNumber,
      Key? key})
      : super(key: key);

  final String videoTitle;
  final int seasons;
  final String? thumbnail;
  final int episodeNumber;
  final int seasonNumber;

  @override
  State<TVVideoLoader> createState() => _TVVideoLoaderState();
}
class _TVVideoLoaderState extends State<TVVideoLoader> {
  List<TVResults>? tvShows;
  List<TVEpisodes>? epi;
  TVVideoSources? tvVideoSources;
  List<TVVideoLinks>? tvVideoLinks;
  List<TVVideoSubtitles>? tvVideoSubs;
  TVInfo? tvInfo;

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
      await tvApi().fetchTVForStream(
              Endpoints.searchMovieTVForStream(widget.videoTitle))
          .then((value) {
        setState(() {
          tvShows = value;
        });
      });

      for (int i = 0; i < tvShows!.length; i++) {
        if (tvShows![i].seasons == widget.seasons &&
            tvShows![i].type == 'TV Series') {
          await tvApi().getTVStreamEpisodes(
                  Endpoints.getMovieTVStreamInfo(tvShows![i].id!))
              .then((value) {
            setState(() {
              tvInfo = value;
              epi = tvInfo!.episodes;
            });
          });
          for (int k = 0; k < epi!.length; k++) {
            if (epi![k].episode == widget.episodeNumber &&
                epi![k].season == widget.seasonNumber) {
              await tvApi().getTVStreamLinksAndSubs(Endpoints.getMovieTVStreamLinks(
                      epi![k].id!, tvShows![i].id!))
                  .then((value) {
                setState(() {
                  tvVideoSources = value;
                });
                tvVideoLinks = tvVideoSources!.videoLinks;
                tvVideoSubs = tvVideoSources!.videoSubtitles;
              });
              break;
            }
          }

          break;
        }
      }

      Map<String, String> videos = {};
      List<BetterPlayerSubtitlesSource> subs = [];

      if (tvVideoSubs != null) {
        for (int i = 0; i < tvVideoSubs!.length; i++) {
          await getVttFileAsString(tvVideoSubs![i].url!).then((value) {
            subs.addAll({
              BetterPlayerSubtitlesSource(
                  name: tvVideoSubs![i].language!,
                  content: processVttFileTimestamps(value),
                  selectedByDefault: tvVideoSubs![i].language == 'English' ||
                          tvVideoSubs![i].language == 'English - English' ||
                          tvVideoSubs![i].language == 'English - SDH'
                      ? true
                      : false,
                  type: BetterPlayerSubtitlesSourceType.memory)
            });
          });
        }
      }

      if (tvVideoLinks != null) {
        for (int k = 0; k < tvVideoLinks!.length; k++) {
          videos.addAll({tvVideoLinks![k].quality!: tvVideoLinks![k].url!});
        }
      }

      List<MapEntry<String, String>> reversedVideoList =
          videos.entries.toList().reversed.toList();
      Map<String, String> reversedVids = Map.fromEntries(reversedVideoList);

      if (tvVideoLinks != null && tvVideoSubs != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return Player(
              sources: reversedVids,
              subs: subs,
              thumbnail: widget.thumbnail,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).backgroundColor
              ],
            );
          },
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The TV episode couldn\'t be found on our servers :(',
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
            'The TV episode couldn\'t be found on our servers :( Error: ${e.toString()}',
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
