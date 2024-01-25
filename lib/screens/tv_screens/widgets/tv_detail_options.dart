import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/controller/bookmark_database_controller.dart';

import 'package:caffiene/models/tv.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TVDetailOptions extends StatefulWidget {
  const TVDetailOptions({Key? key, required this.tvSeries}) : super(key: key);

  final TV tvSeries;

  @override
  State<TVDetailOptions> createState() => _TVDetailOptionsState();
}

class _TVDetailOptionsState extends State<TVDetailOptions> {
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  bool visible = false;
  bool? isBookmarked;

  @override
  void initState() {
    bookmarkChecker();
    super.initState();
  }

  void bookmarkChecker() async {
    var iB = await tvDatabaseController.contain(widget.tvSeries.id!);
    if (mounted) {
      setState(() {
        isBookmarked = iB;
      });
    }
    if (isBookmarked == true) {
      tvDatabaseController.updateTV(widget.tvSeries, widget.tvSeries.id!);
    }
  }

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
                  percent: (widget.tvSeries.voteAverage! / 10),
                  curve: Curves.ease,
                  animation: true,
                  animationDuration: 2500,
                  progressColor: Theme.of(context).colorScheme.primary,
                  center: Text(
                    '${widget.tvSeries.voteAverage!.toStringAsFixed(1)}/10',
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
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.tvSeries.voteCount!.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
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

        Padding(
          padding: const EdgeInsets.only(left: 10, right: 8),
          child: Container(
            child: ElevatedButton(
                onPressed: () {
                  if (isBookmarked == false) {
                    tvDatabaseController.insertTV(widget.tvSeries);
                    if (mounted) {
                      setState(() {
                        isBookmarked = true;
                      });
                    }
                  } else if (isBookmarked == true) {
                    tvDatabaseController.deleteTV(widget.tvSeries.id!);
                    if (mounted) {
                      setState(() {
                        isBookmarked = false;
                      });
                    }
                  }
                },
                child: Row(
                  children: [
                    isBookmarked == false
                        ? const Icon(Icons.bookmark_add)
                        : const Icon(Icons.bookmark_remove),
                    Visibility(
                        visible: visible,
                        child: const CircularProgressIndicator())
                  ],
                )),
          ),
        ),
      ],
    );
  }
}
