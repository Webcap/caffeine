import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
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
  bool? isVisible = false;
  double? buttonWidth = 150;
  late AppDependencyProvider appDependency =
      Provider.of<AppDependencyProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
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
              api: Endpoints.movieDetailsUrl(widget.movie.id!, lang),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const LeadingDot(),
                        Expanded(
                          child: Text(
                            tr("overview"),
                            style: kTextHeaderStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.movie.overview!.isEmpty
                  ? Text(tr("no_overview_movie"))
                  : ReadMoreText(
                      widget.movie.overview!,
                      trimLines: 4,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      colorClickableText: Theme.of(context).colorScheme.primary,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: tr("read_more"),
                      trimExpandedText: tr("read_less"),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, bottom: 4.0, right: 8.0),
                    child: Text(
                      widget.movie.releaseDate == null ||
                              widget.movie.releaseDate!.isEmpty
                          ? tr("no_release_date")
                          : '${tr("release_date")} : ${DateTime.parse(widget.movie.releaseDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.movie.releaseDate!))}, ${DateTime.parse(widget.movie.releaseDate!).year}',
                      style: const TextStyle(fontFamily: 'PoppinsSB'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.movie.releaseDate!.isNotEmpty &&
                        appDependency.displayWatchNowButton
                    ? WatchNowButton(
                        releaseYear:
                            DateTime.parse(widget.movie.releaseDate!).year,
                        movieId: widget.movie.id!,
                        movieName: widget.movie.title,
                        adult: widget.movie.adult,
                        posterPath: widget.movie.posterPath,
                        backdropPath: widget.movie.backdropPath,
                        api: Endpoints.movieDetailsUrl(widget.movie.id!, lang),
                      )
                    : Container()
                // const SizedBox(
                //   width: 15,
                // ),
                // DownloadMovie(
                //   releaseYear: DateTime.parse(widget.movie.releaseDate!).year,
                //   movieId: widget.movie.id!,
                //   movieName: widget.movie.title,
                //   adult: widget.movie.adult,
                //   thumbnail: widget.movie.backdropPath,
                //   api: Endpoints.movieDetailsUrl(widget.movie.id!),
                // )
              ],
            ),
            const SizedBox(height: 15),
            ScrollingArtists(
              api: Endpoints.getCreditsUrl(widget.movie.id!, lang),
              title: tr("cast"),
            ),
            MovieImagesDisplay(
              title: tr("images"),
              api: Endpoints.getImages(widget.movie.id!),
              name: widget.movie.title,
            ),
            MovieVideosDisplay(
              api: Endpoints.getVideos(widget.movie.id!),
              title: tr("videos"),
            ),
            MovieSocialLinks(
              api: Endpoints.getExternalLinksForMovie(widget.movie.id!, lang),
            ),
            const SizedBox(
              height: 10,
            ),
            BelongsToCollectionWidget(
              api: Endpoints.movieDetailsUrl(widget.movie.id!, lang),
            ),
            const SizedBox(
              height: 10,
            ),
            MovieInfoTable(
              api: Endpoints.movieDetailsUrl(widget.movie.id!, lang),
            ),
            const SizedBox(
              height: 10,
            ),
            MovieRecommendationsTab(
              includeAdult: Provider.of<SettingsProvider>(context).isAdult,
              api: Endpoints.getMovieRecommendations(widget.movie.id!, 1, lang),
              movieId: widget.movie.id!,
            ),
            SimilarMoviesTab(
                movieName: widget.movie.title!,
                includeAdult: Provider.of<SettingsProvider>(context).isAdult,
                movieId: widget.movie.id!,
                api: Endpoints.getSimilarMovies(widget.movie.id!, 1, lang)),
            // DidYouKnow(
            //   api: Endpoints.getExternalLinksForMovie(
            //     widget.movie.id!,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
