// ignore_for_file: unused_local_variable, unused_import

import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/widgets/unified_video_loader.dart';
import 'package:reelriot/utils/config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadMovie extends StatelessWidget {
  const DownloadMovie({
    super.key,
    required this.adult,
    required this.api,
    required this.movieId,
    this.movieImdbId,
    required this.movieName,
    required this.releaseYear,
    required this.thumbnail,
  });

  final String? movieName;
  final int movieId;
  final int? movieImdbId;
  final bool? adult;
  final String? api;
  final int releaseYear;
  final String? thumbnail;

  @override
  Widget build(BuildContext context) {
    bool? isVisible = false;
    double? buttonWidth = 150;
    final fetchRoute = Provider.of<AppDependencyProvider>(context).fetchRoute;
    return TextButton(
      style: ButtonStyle(
          maximumSize: WidgetStateProperty.all(Size(buttonWidth, 50)),
        ).copyWith(
            backgroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.primary,
        )),
        onPressed: () async {
          // await checkConnection().then((value) {
          //   value
          //       ? Navigator.push(context,
          //           MaterialPageRoute(builder: ((context) {
          //           return MovieVideoLoader(
          //             download: true,
          //             route: fetchRoute == "flixHQ"
          //                 ? StreamRoute.flixHQ
          //                 : StreamRoute.tmDB,
          //             metadata: [
          //               movieId,
          //               movieName,
          //               thumbnail,
          //               releaseYear,
          //               0.0
          //             ],
          //           );
          //         })))
          //       : ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(
          //             content: Text(
          //               tr("check_connection"),
          //               maxLines: 3,
          //               style: kTextSmallBodyStyle,
          //             ),
          //             duration: const Duration(seconds: 3),
          //           ),
          //         );
          //});
        },
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.download_rounded,
                color: Colors.white,
              ),
            ),
            Text(
              tr("download"),
              style: const TextStyle(color: Colors.white),
            ),
            Visibility(
              visible: isVisible,
              child: const Padding(
                padding: EdgeInsets.only(
                  left: 10.0,
                ),
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
      );
  }
}
