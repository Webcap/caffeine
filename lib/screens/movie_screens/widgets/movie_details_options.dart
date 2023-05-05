import 'package:flutter/material.dart';
import 'package:caffiene/controller/database_controller.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class MovieDetailOptions extends StatefulWidget {
  const MovieDetailOptions({Key? key, required this.movie}) : super(key: key);

  final Movie movie;

  @override
  State<MovieDetailOptions> createState() => _MovieDetailOptionsState();
}

class _MovieDetailOptionsState extends State<MovieDetailOptions> {
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  bool visible = false;
  bool? isBookmarked;

  @override
  void initState() {
    bookmarkChecker();
    super.initState();
  }

  void bookmarkChecker() async {
    var iB = await movieDatabaseController.contain(widget.movie.id!);
    if (mounted) {
      setState(() {
        isBookmarked = iB;
      });
    }
    if (isBookmarked == true) {
      movieDatabaseController.updateMovie(widget.movie, widget.movie.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // user score circle percent indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 18, 0),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 30,
                percent: (widget.movie.voteAverage! / 10),
                curve: Curves.ease,
                animation: true,
                animationDuration: 2500,
                progressColor: Theme.of(context).colorScheme.primary,
                center: Text(
                  '${widget.movie.voteAverage!.toStringAsFixed(1)}/10',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'User\nScore',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        Row(children: [
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
              widget.movie.voteCount!.toString(),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Vote\nCounts',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),

        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Container(
            child: ElevatedButton(
                onPressed: () {
                  if (isBookmarked == false) {
                    movieDatabaseController.insertMovie(widget.movie);
                    if (mounted) {
                      setState(() {
                        isBookmarked = true;
                      });
                    }
                  } else if (isBookmarked == true) {
                    movieDatabaseController.deleteMovie(widget.movie.id!);
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
