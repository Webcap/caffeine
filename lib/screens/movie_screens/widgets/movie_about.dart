import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/movie_screens/widgets/collecrions_widget.dart';
import 'package:reelriot/screens/movie_screens/widgets/genre_list_grid.dart';
import 'package:reelriot/screens/movie_screens/widgets/movie_image_display.dart';
import 'package:reelriot/screens/movie_screens/widgets/movie_info_tab.dart';
import 'package:reelriot/screens/movie_screens/widgets/movie_social_links.dart';
import 'package:reelriot/screens/movie_screens/widgets/movie_video_display.dart';
import 'package:reelriot/screens/movie_screens/widgets/reccomend.dart';
import 'package:reelriot/screens/movie_screens/widgets/scrolling_artist.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class MovieAbout extends StatefulWidget {
  const MovieAbout({
    super.key,
    required this.movie,
    this.videosKey,
    this.scrollable = true,
  });
  final Movie movie;
  final GlobalKey? videosKey;

  /// When false, renders its content directly (no SingleChildScrollView) so
  /// a caller can place it inside a scroll region it already owns — used by
  /// the expanded (tablet-landscape) layout, which shares one scroll view
  /// across the title block, ratings, watch-now button, and this content.
  final bool scrollable;

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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    final content = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32.0 : 16.0,
                  vertical: 8.0,
                ),
                child: widget.movie.overview == null ||
                        widget.movie.overview!.isEmpty
                  ? Text(tr("no_overview_movie"))
                  : ReadMoreText(
                      widget.movie.overview!,
                      trimLines: 3,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xB8FFFFFF)
                            : const Color(0xFF475569),
                      ),
                      colorClickableText: Theme.of(context).colorScheme.primary,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: ' See More',
                      trimExpandedText: ' See Less',
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
            widget.videosKey != null
                ? KeyedSubtree(
                    key: widget.videosKey!,
                    child: MovieVideosDisplay(
                      api: Endpoints.getVideos(widget.movie.id!),
                      title: tr("videos"),
                    ),
                  )
                : MovieVideosDisplay(
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

    return widget.scrollable ? SingleChildScrollView(child: content) : content;
  }
}
