// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:caffiene/controller/recently_watched_database_controller.dart';
import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/config.dart';
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
    RecentlyWatchedMoviesController recentlyWatchedMoviesController =
        RecentlyWatchedMoviesController();
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
          setState(() {
            isVisible = true;
            buttonWidth = 200;
          });
          final mixpanel =
              Provider.of<SettingsProvider>(context, listen: false).mixpanel;
          mixpanel.track('Most viewed movies', properties: {
            'Movie name': widget.movieName,
            'Movie id': widget.movieId,
            'Is Movie adult?': widget.adult ?? 'unknown',
          });
          var isBookmarked =
              await recentlyWatchedMoviesController.contain(widget.movieId);
          int elapsed = 0;
          if (isBookmarked) {
            var rMovies =
                Provider.of<RecentProvider>(context, listen: false).movies;
            int index =
                rMovies.indexWhere((element) => element.id == widget.movieId);
            setState(() {
              elapsed = rMovies[index].elapsed!;
            });
          }
          setState(() {
            isVisible = false;
            buttonWidth = 160;
          });
          Navigator.push(context, MaterialPageRoute(builder: ((context) {
            return MovieVideoLoader(
              route: StreamRoute.tmDB,
              download: false,
              metadata: [
                widget.movieId,
                widget.movieName,
                widget.posterPath,
                widget.releaseYear,
                widget.backdropPath,
                elapsed
              ],
            );
          })));
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
