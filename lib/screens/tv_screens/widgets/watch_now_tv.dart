import 'dart:async';
import 'dart:math';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/models/tv_stream_metadata.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/screens/tv_screens/tv_video_loader.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/globlal_methods.dart';
import 'package:caffiene/utils/textStyle.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatchNowButtonTV extends StatefulWidget {
  const WatchNowButtonTV(
      {Key? key,
      required this.episode,
      required this.seriesName,
      required this.tvId,
      required this.posterPath})
      : super(key: key);

  final String seriesName, posterPath;
  final int tvId;
  final EpisodeList episode;

  @override
  State<WatchNowButtonTV> createState() => _WatchNowButtonTVState();
}

class _WatchNowButtonTVState extends State<WatchNowButtonTV> {
  TVDetails? tvDetails;

  Color _borderColor = Colors.red; // Initial border color
  Timer? _timer;
  Random random = Random();

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
      child: GestureDetector(
        onTap: () async {
          if (mounted) {
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
                            metadata: TVStreamMetadata(
                                elapsed: null,
                                episodeId: widget.episode.episodeId,
                                episodeName: widget.episode.name,
                                episodeNumber: widget.episode.episodeNumber!,
                                posterPath: widget.posterPath,
                                seasonNumber: widget.episode.seasonNumber!,
                                seriesName: widget.seriesName,
                                tvId: widget.tvId,
                                airDate: widget.episode.airDate));
                      })))
                    : GlobalMethods.showCustomScaffoldMessage(
                        SnackBar(
                          content: Text(
                            tr("check_connection"),
                            maxLines: 3,
                            style: kTextSmallBodyStyle,
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                        context);
              });
            }
          }
        },
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(
                Icons.play_circle_fill_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 6),
              Text(tr("watch_now"),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ))
            ])),
      ),
    );
  }
}
