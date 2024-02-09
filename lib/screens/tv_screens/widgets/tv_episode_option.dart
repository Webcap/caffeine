import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/tv.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TVEpisodeOptions extends StatelessWidget {
  const TVEpisodeOptions({Key? key, required this.episodeList})
      : super(key: key);
  final EpisodeList episodeList;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // user score circle percent indicator
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 18, 0),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 30,
                  percent: (episodeList.voteAverage! / 10),
                  curve: Curves.ease,
                  animation: true,
                  animationDuration: 2500,
                  progressColor: Theme.of(context).colorScheme.primary,
                  center: Text(
                    '${episodeList.voteAverage!.toStringAsFixed(1).endsWith('0') ? episodeList.voteAverage!.toStringAsFixed(0) : episodeList.voteAverage!.toStringAsFixed(1)}/10',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tr("rating"),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 2,
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              // height: 46,
              // width: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                episodeList.voteCount!.toString(),
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  tr("total_ratings"),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ]),
        ),
        const Expanded(child: SizedBox())
      ],
    );
  }
}
