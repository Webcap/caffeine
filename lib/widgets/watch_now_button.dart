import 'package:flutter/material.dart';
import 'package:login/models/movie_models.dart';
import 'package:login/provider/mixpanel_provider.dart';
import 'package:login/screens/movie_screens/movie_source_screen.dart';
import 'package:login/screens/movie_screens/movie_stream.dart';
import 'package:login/screens/movie_screens/widgets/movie_video_loader.dart';
import 'package:login/utils/config.dart';
import 'package:login/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:login/api/movies_api.dart';

class WatchNowButton extends StatefulWidget {
  const WatchNowButton({
    Key? key,
    required this.thumbnail,
    required this.movieId,
    this.movieName,
    this.movieImdbId,
    this.api,
    required this.releaseYear,
    required this.adult,
  }) : super(key: key);
  final String? movieName;
  final int movieId;
  final int? movieImdbId;
  final bool? adult;
  final String? api;
  final int releaseYear;
  final String? thumbnail;

  @override
  State<WatchNowButton> createState() => _WatchNowButtonState();
}

class _WatchNowButtonState extends State<WatchNowButton> {
  Moviedetail? movieDetails;
  bool? isVisible = false;
  double? buttonWidth = 150;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        style: ButtonStyle(
          maximumSize: MaterialStateProperty.all(Size(buttonWidth!, 50)),
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.primary,
        )),
        onPressed: () async {
         Navigator.push(context, MaterialPageRoute(builder: (context) {
            // return MovieStream(
            //   streamUrl:
            //       'https://www.2embed.to/embed/tmdb/movie?id=${widget.movieId}',
            //   movieName: widget.movieName!,
            // );
            return MovieVideoLoader(
              videoTitle: widget.movieName!,
              releaseYear: widget.releaseYear,
              thumbnail: widget.thumbnail,
            );
          }));
        },
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.play_circle,
                color: Colors.white,
              ),
            ),
            const Text(
              'WATCH NOW',
              style: TextStyle(color: Colors.white),
            ),
            Visibility(
              visible: isVisible!,
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
