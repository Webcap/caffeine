import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/widgets/collecrions_widget.dart';
import 'package:caffiene/screens/movie_screens/widgets/genre_list_grid.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_image_display.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_info_tab.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_social_links.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_video_display.dart';
import 'package:caffiene/screens/movie_screens/widgets/reccomend.dart';
import 'package:caffiene/screens/movie_screens/widgets/scrolling_artist.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:caffiene/widgets/watch_now_button.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:intl/intl.dart';

class MovieAbout extends StatefulWidget {
  const MovieAbout({required this.movie, Key? key}) : super(key: key);
  final Movie movie;

  @override
  State<MovieAbout> createState() => _MovieAboutState();
}

class _MovieAboutState extends State<MovieAbout> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // physics: const BouncingScrollPhysics(),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: <Widget>[
            GenreDisplay(
              api: Endpoints.movieDetailsUrl(widget.movie.id!),
            ),
            const Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Overview',
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.movie.overview!.isEmpty
                  ? const Text('There is no overview for this movie')
                  : ReadMoreText(
                      widget.movie.overview!,
                      trimLines: 4,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      colorClickableText: Theme.of(context).colorScheme.primary,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: 'read more',
                      trimExpandedText: 'read less',
                      lessStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                      moreStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                  child: Text(
                    widget.movie.releaseDate == null ||
                            widget.movie.releaseDate!.isEmpty
                        ? 'Release date: N/A'
                        : 'Release date : ${DateTime.parse(widget.movie.releaseDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.movie.releaseDate!))}, ${DateTime.parse(widget.movie.releaseDate!).year}',
                    style: const TextStyle(fontFamily: 'PoppinsSB'),
                  ),
                ),
              ],
            ),
            WatchNowButton(
              releaseYear: DateTime.parse(widget.movie.releaseDate!).year,
              movieId: widget.movie.id!,
              movieName: widget.movie.title,
              adult: widget.movie.adult,
              thumbnail: widget.movie.backdropPath,
              api: Endpoints.movieDetailsUrl(widget.movie.id!),
            ),
            ScrollingArtists(
              api: Endpoints.getCreditsUrl(widget.movie.id!),
              title: 'Cast',
            ),
            MovieImagesDisplay(
              title: 'Images',
              api: Endpoints.getImages(widget.movie.id!),
              name: widget.movie.title,
            ),
            MovieVideosDisplay(
              api: Endpoints.getVideos(widget.movie.id!),
              title: 'Videos',
            ),
            MovieSocialLinks(
              api: Endpoints.getExternalLinksForMovie(
                widget.movie.id!,
              ),
            ),
            BelongsToCollectionWidget(
              api: Endpoints.movieDetailsUrl(widget.movie.id!),
            ),
            MovieInfoTable(
              api: Endpoints.movieDetailsUrl(widget.movie.id!),
            ),
            const SizedBox(
              height: 10,
            ),
            MovieRecommendationsTab(
              includeAdult: Provider.of<SettingsProvider>(context).isAdult,
              api: Endpoints.getMovieRecommendations(widget.movie.id!, 1),
              movieId: widget.movie.id!,
            ),
            SimilarMoviesTab(
                movieName: widget.movie.title!,
                includeAdult: Provider.of<SettingsProvider>(context).isAdult,
                movieId: widget.movie.id!,
                api: Endpoints.getSimilarMovies(widget.movie.id!, 1)),
            DidYouKnow(
              api: Endpoints.getExternalLinksForMovie(
                widget.movie.id!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
