import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/controller/bookmark_database_controller.dart';

import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/common/watch_providers_dets.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_about.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_detail_quick_info.dart';
import 'package:caffiene/screens/movie_screens/widgets/movie_details_options.dart';
import 'package:caffiene/screens/common/sabth.dart';
import 'package:provider/provider.dart';
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
      'Movie name': '${widget.movie.title}',
      'Movie id': '${widget.movie.id}',
      'Is Movie adult?': '${widget.movie.adult}'
    });
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;

    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            shadowColor: themeMode == "dark" || themeMode == "amoled"
                ? Colors.white
                : Colors.black,
            forceElevated: true,
            backgroundColor: themeMode == "dark" || themeMode == "amoled"
                ? Colors.black
                : Colors.white,
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
            )),
            expandedHeight: 390,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  MovieDetailQuickInfo(
                    heroId: widget.heroId,
                    movie: widget.movie,
                  ),
                  const SizedBox(height: 18),
                  MovieDetailOptions(movie: widget.movie),
                ],
              ),
            ),
          ),

          // body
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [MovieAbout(movie: widget.movie)],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Share.share(tr(
              "share_movie",
              namedArgs: {
                "title": widget.movie.title!,
                "rating": widget.movie.voteAverage!.toStringAsFixed(1),
                "id": widget.movie.id.toString()
              },
            ));
          },
          child: const Icon(Icons.share)),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void modalBottomSheetMenu(String country) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return WatchProvidersDetails(
          api: Endpoints.getMovieWatchProviders(widget.movie.id!, lang),
          country: country,
        );
      },
    );
  }
}
