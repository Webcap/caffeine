import 'dart:async';
import 'dart:math';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/models/tv_stream_metadata.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
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
      child: TextButton(
        style: ButtonStyle(
            maximumSize: MaterialStateProperty.all(Size(buttonWidth!, 100)),
            minimumSize: MaterialStateProperty.all(Size(buttonWidth!, 50)),
            backgroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.primary,
            )),
        onPressed: () async {
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
                              episodeId: widget.episodeList.episodeId,
                              episodeName: widget.episodeList.name,
                              episodeNumber: widget.episodeList.episodeNumber!,
                              posterPath: widget.posterPath,
                              seasonNumber: widget.episodeList.seasonNumber!,
                              seriesName: widget.seriesName,
                              tvId: widget.tvId,
                            ));
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
