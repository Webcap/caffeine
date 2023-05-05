import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/controller/database_controller.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/common/watch_providers_dets.dart';
import 'package:caffiene/screens/movie_screens/movie_source_screen.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/screens/movie_screens/widgets/cast_tab_widget.dart';
import 'package:caffiene/screens/movie_screens/widgets/collecrions_widget.dart';
import 'package:caffiene/screens/movie_screens/widgets/genre_list_grid.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_about.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_detail_quick_info.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_details_options.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_image_display.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_info_tab.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_social_links.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_video_display.dart';
import 'package:caffiene/screens/movie_screens/widgets/reccomend.dart';
import 'package:caffiene/screens/common/sabth.dart';
import 'package:caffiene/screens/movie_screens/widgets/scrolling_artist.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/movie_page_buttons.dart';
import 'package:caffiene/widgets/movie_rec.dart';
import 'package:caffiene/widgets/watch_now_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final String heroId;

  const MovieDetailPage({
    Key? key,
    required this.movie,
    required this.heroId,
  }) : super(key: key);
  @override
  MovieDetailPageState createState() => MovieDetailPageState();
}

class MovieDetailPageState extends State<MovieDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<MovieDetailPage> {
  late TabController tabController;
  bool? isBookmarked;
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed movie pages', properties: {
      'Movie name': '${widget.movie.originalTitle}',
      'Movie id': '${widget.movie.id}',
      'Is Movie adult?': '${widget.movie.adult}'
    });
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            shadowColor: isDark ? Colors.white : Colors.black,
            forceElevated: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
              child: Text(
                widget.movie.releaseDate == null
                    ? widget.movie.title!
                    : widget.movie.releaseDate == ""
                        ? widget.movie.title!
                        : '${widget.movie.title!} (${DateTime.parse(widget.movie.releaseDate!).year})',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            expandedHeight: 390,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  MovieDetailQuickInfo(
                      heroId: widget.heroId, movie: widget.movie),
                  const SizedBox(height: 18),
                  // ratings / lists / bookmark options
                  MovieDetailOptions(movie: widget.movie),
                ],
              ),
            ),
          ),
          //body
          SliverList(
            delegate: SliverChildListDelegate.fixed(
                [MovieAbout(movie: widget.movie)]),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () async {
      //       await Share.share(
      //           'Checkout the movie \'${widget.movie.title}\'!\nIt is rated ${widget.movie.voteAverage!.toStringAsFixed(1)} out of 10\nhttps://themoviedb.org/movie/${widget.movie.id}');
      //     },
      //     child: const Icon(Icons.share)),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void modalBottomSheetMenu(String country) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return WatchProvidersDetails(
          api: Endpoints.getMovieWatchProviders(widget.movie.id!),
          country: country,
        );
      },
    );
  }
}
