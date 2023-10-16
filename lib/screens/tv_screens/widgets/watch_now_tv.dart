import 'dart:async';
import 'dart:math';
import 'package:caffiene/controller/recently_watched_database_controller.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/tv_video_loader.dart';
import 'package:caffiene/utils/config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatchNowButtonTV extends StatefulWidget {
  const WatchNowButtonTV(
      {Key? key,
      required this.episodeList,
      required this.seriesName,
      required this.tvId,
      required this.posterPath})
      : super(key: key);

  final String seriesName, posterPath;
  final int tvId;
  final EpisodeList episodeList;

  @override
  State<WatchNowButtonTV> createState() => _WatchNowButtonTVState();
}

class _WatchNowButtonTVState extends State<WatchNowButtonTV> {
  bool? isVisible = false;
  double? buttonWidth = 160;
  TVDetails? tvDetails;

  Color _borderColor = Colors.red; // Initial border color
  Timer? _timer;
  Random random = Random();

  RecentlyWatchedEpisodeController recentlyWatchedEpisodeController =
      RecentlyWatchedEpisodeController();

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Generate random RGB values between 0 and 255
        int red = random.nextInt(256);
        int green = random.nextInt(256);
        int blue = random.nextInt(256);

        _borderColor = Color.fromRGBO(red, green, blue, 1.0);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    final fetchRoute = Provider.of<AppDependencyProvider>(context).fetchRoute;
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          // Add an outer box shadow here
          BoxShadow(
            color: _borderColor,
            spreadRadius: 2.5,
            blurRadius: 4.25,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: TextButton(
        style: ButtonStyle(
            maximumSize: MaterialStateProperty.all(Size(buttonWidth!, 100)),
            minimumSize: MaterialStateProperty.all(Size(buttonWidth!, 50)),
            backgroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.primary,
            )),
        onPressed: () async {
          mixpanel.track('Most viewed TV series', properties: {
            'TV series name': widget.seriesName,
            'TV series id': '${widget.tvId}',
            'TV series episode name': '${widget.episodeList.name}',
            'TV series season number': '${widget.episodeList.seasonNumber}',
            'TV series episode number': '${widget.episodeList.episodeNumber}'
          });
          setState(() {
            isVisible = true;
            buttonWidth = 200;
          });
          if (mounted) {
            var isBookmarked = await recentlyWatchedEpisodeController
                .contain(widget.episodeList.episodeId!);
            int elapsed = 0;
            if (isBookmarked) {
              if (mounted) {
                var rEpisodes =
                    Provider.of<RecentProvider>(context, listen: false)
                        .episodes;

                int index = rEpisodes.indexWhere(
                    (element) => element.id == widget.episodeList.episodeId);
                setState(() {
                  elapsed = rEpisodes[index].elapsed!;
                });
              }
            }
            setState(() {
              isVisible = false;
              buttonWidth = 160;
            });
            if (mounted) {
              await checkConnection().then((value) {
                value
                    ? Navigator.push(context,
                        MaterialPageRoute(builder: ((context) {
                        return TVVideoLoader(
                          download: false,
                          route: fetchRoute == "flixHQ"
                              ? StreamRoute.flixHQ
                              : StreamRoute.tmDB,
                          metadata: [
                            widget.episodeList.episodeId,
                            widget.seriesName,
                            widget.episodeList.name,
                            widget.episodeList.episodeNumber!,
                            widget.episodeList.seasonNumber!,
                            widget.posterPath,
                            elapsed,
                            widget.tvId,
                          ],
                        );
                      })))
                    : ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tr("check_connection"),
                            maxLines: 3,
                            style: kTextSmallBodyStyle,
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
              });
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 10, left: 10),
              child: Icon(
                Icons.play_circle,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                tr("watch_now"),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Visibility(
              visible: isVisible!,
              child: const Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
