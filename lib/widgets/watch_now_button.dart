// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:math';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/models/movie_stream_metadata.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/textStyle.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_video_loader.dart';
import 'package:provider/provider.dart';

class WatchNowButton extends StatefulWidget {
  const WatchNowButton({
    Key? key,
    required this.posterPath,
    required this.movieId,
    this.movieName,
    this.movieImdbId,
    this.api,
    required this.releaseYear,
    required this.backdropPath,
    this.adult,
  }) : super(key: key);
  final String? movieName;
  final int movieId;
  final int? movieImdbId;
  final bool? adult;
  final String? api;
  final int releaseYear;
  final String? posterPath;
  final String? backdropPath;

  @override
  WatchNowButtonState createState() => WatchNowButtonState();
}

class WatchNowButtonState extends State<WatchNowButton> {
  bool? isVisible = false;
  double? buttonWidth = 160;

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
    _timer?.cancel();
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
          maximumSize: MaterialStateProperty.all(Size(buttonWidth!, 45)),
          minimumSize: MaterialStateProperty.all(Size(buttonWidth!, 45)),
        ).copyWith(
            backgroundColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.primary,
        )),
        onPressed: () async {
          await checkConnection().then((value) {
            value
                ? Navigator.push(context,
                    MaterialPageRoute(builder: ((context) {
                    return MovieVideoLoader(
                      route: fetchRoute == "flixHQ"
                          ? StreamRoute.flixHQ
                          : StreamRoute.tmDB,
                      download: false,
                      metadata: MovieStreamMetadata(
                          backdropPath: widget.backdropPath,
                          elapsed: null,
                          isAdult: widget.adult,
                          movieId: widget.movieId,
                          movieName: widget.movieName,
                          posterPath: widget.posterPath,
                          releaseYear: widget.releaseYear),
                      /*
                      
                      [
                        widget.movieId,
                        widget.movieName,
                        widget.posterPath,
                        widget.releaseYear,
                        
                        elapsed
                      ],
                      */
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
        },
        child: Row(
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
