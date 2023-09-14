import 'package:caffiene/screens/movie_screens/widgets/movie_video_loader.dart';
import 'package:flutter/material.dart';

class DownloadMovie extends StatelessWidget {
  const DownloadMovie({
    Key? key,
    required this.adult,
    required this.api,
    required this.movieId,
    this.movieImdbId,
    required this.movieName,
    required this.releaseYear,
    required this.thumbnail,
  }) : super(key: key);

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
    return Container(
      child: TextButton(
        style: ButtonStyle(
          maximumSize: MaterialStateProperty.all(Size(buttonWidth, 50)),
        ).copyWith(
            backgroundColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.primary,
        )),
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: ((context) {
            return MovieVideoLoaderNoAds(
              metadata: [movieId, movieName, thumbnail, releaseYear, 0.0],
              download: true,
            );
          })));
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
            const Text(
              'DOWNLOAD',
              style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}
