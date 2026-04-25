import 'package:reelriot/utils/globals.dart';
import 'dart:async';
import 'dart:math';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/models/tv_stream_metadata.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/widgets/unified_video_loader.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';

class WatchNowButtonTV extends StatefulWidget {
  const WatchNowButtonTV(
      {super.key,
      required this.episode,
      required this.seriesName,
      required this.tvId,
      required this.posterPath});

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
  bool _isProcessing = false;

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
    final recentProvider = Provider.of<RecentProvider>(context);

    int? elapsedValue;
    double progress = 0.0;
    for (var e in recentProvider.episodes) {
      if (e.id != null &&
          e.id == widget.episode.episodeId &&
          e.seasonNum != null &&
          e.seasonNum == widget.episode.seasonNumber &&
          e.episodeNum != null &&
          e.episodeNum == widget.episode.episodeNumber) {
        final elapsed = e.elapsed ?? 0;
        final remaining = e.remaining ?? 0;
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
            if (!context.mounted) return;
            final connected = await checkConnection();
            if (!context.mounted) return;
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
              if (!context.mounted) return;
              final bool? continueWatching = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Continue Watching?"),
                  content: const Text(
                      "Would you like to resume where you left off or start from the beginning?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(
                          context, false), // false means start over
                      child: const Text("Start Over"),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, true), // true means continue
                      child: const Text("Continue"),
                    ),
                  ],
                ),
              );

              if (continueWatching == null) return;
              elapsedToPass = continueWatching ? elapsedValue : 0;
            }

            if (!context.mounted) return;
            Navigator.push(context, MaterialPageRoute(builder: ((context) {
              return UnifiedVideoLoader(
                mediaType: MediaType.tvShow,
                download: false,
                route: fetchRoute == "flixHQ"
                    ? StreamRoute.flixHQ
                    : StreamRoute.tmDB,
                tvMetadata: TVStreamMetadata(
                    elapsed: elapsedToPass,
                    episodeId: widget.episode.episodeId,
                    episodeName: widget.episode.name,
                    episodeNumber: widget.episode.episodeNumber!,
                    posterPath: widget.posterPath,
                    seasonNumber: widget.episode.seasonNumber!,
                    seriesName: widget.seriesName,
                    tvId: widget.tvId,
                    airDate: widget.episode.airDate),
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
      ),
    );
  }
}
