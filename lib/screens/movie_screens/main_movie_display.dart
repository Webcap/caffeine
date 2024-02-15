import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:caffiene/screens/common/update_screen.dart';
import 'package:caffiene/screens/movie_screens/widgets/scrolling_recent_movies.dart';
import 'package:caffiene/utils/config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/discover_screens/widgets/discover_movies_widget.dart';
import 'package:caffiene/screens/movie_screens/widgets/genre_list_grid.dart';
import 'package:caffiene/screens/movie_screens/widgets/movies_from_watch_providers.dart';
import 'package:caffiene/screens/movie_screens/widgets/scrolling_movie_list.dart';
import 'package:provider/provider.dart';

class MainMoviesDisplay extends StatefulWidget {
  const MainMoviesDisplay({
    Key? key,
  }) : super(key: key);

  @override
  State<MainMoviesDisplay> createState() => _MainMoviesDisplayState();
}

class _MainMoviesDisplayState extends State<MainMoviesDisplay> {
  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool includeAdult = Provider.of<SettingsProvider>(context).isAdult;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    var rMovies = Provider.of<RecentProvider>(context).movies;
    return Container(
      child: ListView(
        children: [
          DiscoverMovies(
            includeAdult: includeAdult,
            discoverType: "discover"
          ),
          devMode == false
            ? const UpdateBottom()
            : Container(),
          // ScrollingMovies(
          //   title: tr("trending_horror_movies"),
          //   api: Endpoints.halloweenMoviesUrl(1, lang),
          //   discoverType: 'horror',
          //   isTrending: true,
          //   includeAdult: includeAdult,
          // ),
          rMovies.isEmpty
              ? Container()
              : ScrollingRecentMovies(moviesList: rMovies),
          ScrollingMovies(
            title: tr("popular"),
            api: Endpoints.popularMoviesUrl(1, lang),
            discoverType: 'popular',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          // UnityBannerAd(
          //   placementId: 'Movies_one',
          //   onLoad: (placementId) => print('Banner loaded: $placementId'),
          //   onClick: (placementId) => print('Banner clicked: $placementId'),
          //   onFailed: (placementId, error, message) =>
          //       print('Banner Ad $placementId failed: $error $message'),
          // ),
          ScrollingMovies(
            title: tr("trending_this_week"),
            api: Endpoints.trendingMoviesUrl(1, includeAdult, lang),
            discoverType: 'Trending',
            isTrending: true,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: tr("top_rated"),
            api: Endpoints.topRatedUrl(1, lang),
            discoverType: 'top_rated',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: tr("now_playing"),
            api: Endpoints.nowPlayingMoviesUrl(1, lang),
            discoverType: 'now_playing',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: tr("upcoming"),
            api: Endpoints.upcomingMoviesUrl(1, lang),
            discoverType: 'upcoming',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          GenreListGrid(api: Endpoints.movieGenresUrl(lang)),
          const MoviesFromWatchProviders(),
        ],
      ),
    );
  }
}
