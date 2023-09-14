import 'package:better_player/better_player.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/api/tv_api.dart';
import 'package:caffiene/models/tv_stream.dart';
import 'package:caffiene/models/functions.dart';
import 'package:caffiene/screens/player/player.dart';
import 'package:caffiene/utils/config.dart';
import 'package:provider/provider.dart';

class TVVideoLoader extends StatefulWidget {
  const TVVideoLoader(
      {required this.metadata, required this.download, Key? key})
      : super(key: key);

  final List metadata;
  final bool download;

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
      await tvApi().fetchTVForStream(Endpoints.searchMovieTVForStream1(
              widget.metadata.elementAt(1), appDep.consumetUrl))
          .then((value) {
        if (mounted) {
          setState(() {
            tvShows = value;
          });
        }
      });
      for (int i = 0; i < tvShows!.length; i++) {
        if (tvShows![i].seasons == widget.metadata.elementAt(5) &&
            tvShows![i].type == 'TV Series') {
          await tvApi().getTVStreamEpisodes(Endpoints.getMovieTVStreamInfo1(
                  tvShows![i].id!, appDep.consumetUrl))
              .then((value) {
            setState(() {
              tvInfo = value;
              epi = tvInfo!.episodes;
            });
          });
          print('wtf');
          for (int k = 0; k < epi!.length; k++) {
            if (epi![k].episode == widget.metadata.elementAt(3) &&
                epi![k].season == widget.metadata.elementAt(4)) {
              await tvApi().getTVStreamLinksAndSubs(Endpoints.getMovieTVStreamLinks1(
                      epi![k].id!, tvShows![i].id!, appDep.consumetUrl))
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

        if (tvShows![i].seasons == (widget.metadata.elementAt(5) - 1) &&
            tvShows![i].type == 'TV Series') {
          await tvApi().getTVStreamEpisodes(Endpoints.getMovieTVStreamInfo1(
                  tvShows![i].id!, appDep.consumetUrl))
              .then((value) {
            setState(() {
              tvInfo = value;
              epi = tvInfo!.episodes;
            });
          });
          print('wtf');
          for (int k = 0; k < epi!.length; k++) {
            if (epi![k].episode == widget.metadata.elementAt(3) &&
                epi![k].season == widget.metadata.elementAt(4)) {
              await tvApi().getTVStreamLinksAndSubs(Endpoints.getMovieTVStreamLinks1(
                      epi![k].id!, tvShows![i].id!, appDep.consumetUrl))
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
        if (settings.defaultSubtitleLanguage == '') {
          for (int i = 0; i < tvVideoSubs!.length - 1; i++) {
            setState(() {
              loadProgress = (i / tvVideoSubs!.length) * 100;
            });
            await getVttFileAsString(tvVideoSubs![i].url!).then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: tvVideoSubs![i].language!,
                    content: processVttFileTimestamps(value),
                    selectedByDefault: tvVideoSubs![i].language == 'English' ||
                            tvVideoSubs![i].language == 'English - English' ||
                            tvVideoSubs![i].language == 'English - SDH' ||
                            tvVideoSubs![i].language == 'English 1'
                        ? true
                        : false,
                    type: BetterPlayerSubtitlesSourceType.memory)
              });
            });
          }
        } else {
          if (tvVideoSubs!
              .where((element) => element.language!
                  .startsWith(settings.defaultSubtitleLanguage))
              .isNotEmpty) {
            await getVttFileAsString(tvVideoSubs!
                    .where((element) => element.language!
                        .startsWith(settings.defaultSubtitleLanguage))
                    .first
                    .url!)
                .then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: tvVideoSubs!
                        .where((element) => element.language!
                            .startsWith(settings.defaultSubtitleLanguage))
                        .first
                        .language,
                    content: processVttFileTimestamps(value),
                    selectedByDefault: true,
                    type: BetterPlayerSubtitlesSourceType.memory)
              });
            });
          }
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr("tv_vid_404"),
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
            tr("tv_vid_404_desc", namedArgs: {"err": e.toString()}),
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
