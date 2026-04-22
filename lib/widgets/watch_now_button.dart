// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:math';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/models/movie_stream_metadata.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/widgets/unified_video_loader.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';

class WatchNowButton extends StatefulWidget {
  const WatchNowButton({
    super.key,
    required this.posterPath,
    required this.movieId,
    this.movieName,
    this.movieImdbId,
    this.api,
    required this.releaseYear,
    required this.releaseDate,
    required this.backdropPath,
    this.adult,
  });
  final String? movieName;
  final int movieId;
  final int? movieImdbId;
  final bool? adult;
  final String? api;
  final int releaseYear;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;

  @override
  WatchNowButtonState createState() => WatchNowButtonState();
}

class WatchNowButtonState extends State<WatchNowButton> {
  bool? isVisible = false;
  double? buttonWidth = 160;
  bool _isProcessing = false;

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
    final recentProvider = Provider.of<RecentProvider>(context);

    int? elapsedValue;
    double progress = 0.0;
    for (var m in recentProvider.movies) {
      if (m.id == widget.movieId) {
        final elapsed = m.elapsed ?? 0;
        final remaining = m.remaining ?? 0;
        final total = elapsed + remaining;
        if (total > 0 && elapsed > 0 && (elapsed / total) < 0.9) {
          elapsedValue = elapsed;
          progress = elapsed / total;
        }
        break;
      }
    }

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
            if (_isProcessing) return;
            setState(() => _isProcessing = true);
            try {
              final connected = await checkConnection();
            if (!connected) {
              GlobalMethods.showCustomScaffoldMessage(
                  SnackBar(
                    content: Text(
                      tr("check_connection"),
                      maxLines: 3,
                      style: kTextSmallBodyStyle,
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                  context);
              return;
            }

            int? elapsedToPass;
            if (elapsedValue != null) {
              final bool? continueWatching = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Continue Watching?"),
                  content: const Text(
                      "Would you like to resume where you left off or start from the beginning?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Start Over"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Continue"),
                    ),
                  ],
                ),
              );

              if (continueWatching == null) return;
              elapsedToPass = continueWatching ? elapsedValue : 0;
            }

            if (!mounted) return;
            Navigator.push(context, MaterialPageRoute(builder: ((context) {
              return UnifiedVideoLoader(
                mediaType: MediaType.movie,
                route: fetchRoute == "flixHQ"
                    ? StreamRoute.flixHQ
                    : StreamRoute.tmDB,
                download: false,
                movieMetadata: MovieStreamMetadata(
                    backdropPath: widget.backdropPath,
                    elapsed: elapsedToPass,
                    isAdult: widget.adult,
                    movieId: widget.movieId,
                    movieName: widget.movieName,
                    posterPath: widget.posterPath,
                    releaseYear: widget.releaseYear,
                    releaseDate: widget.releaseDate),
              );
            })));
          } finally {
            if (mounted) {
              setState(() => _isProcessing = false);
            }
          }
        },
          child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    if (elapsedValue != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: LinearProgressIndicator(
                          value: progress,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.5),
                          backgroundColor: Colors.transparent,
                          minHeight: 4,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_fill_rounded,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            elapsedValue != null
                                ? "Continue Watching"
                                : tr("watch_now"),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }
}
