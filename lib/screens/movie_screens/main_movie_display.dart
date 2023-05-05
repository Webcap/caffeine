import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/discover_screens/widgets/discover_movies_widget.dart';
import 'package:caffiene/screens/movie_screens/widgets/genre_list_grid.dart';
import 'package:caffiene/screens/movie_screens/widgets/movies_from_watch_providers.dart';
import 'package:caffiene/screens/movie_screens/widgets/scrolling_widget.dart';
import 'package:provider/provider.dart';

class MainMoviesDisplay extends StatefulWidget {
  const MainMoviesDisplay({
    Key? key,
  }) : super(key: key);

  @override
  State<MainMoviesDisplay> createState() => _MainMoviesDisplayState();
}

class _MainMoviesDisplayState extends State<MainMoviesDisplay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool includeAdult = Provider.of<SettingsProvider>(context).isAdult;
    return Container(
        child: ListView(
      children: [
        DiscoverMovies(),
        ScrollingMovies(
          title: 'Popular',
          api: Endpoints.popularMoviesUrl(1),
          discoverType: 'popular',
          isTrending: false,
          includeAdult: includeAdult,
        ),
        ScrollingMovies(
          title: 'Trending this week',
          api: Endpoints.trendingMoviesUrl(1),
          discoverType: 'Trending',
          isTrending: true,
          includeAdult: includeAdult,
        ),
        ScrollingMovies(
          title: 'Top Rated',
          api: Endpoints.topRatedUrl(1),
          discoverType: 'top_rated',
          isTrending: false,
          includeAdult: includeAdult,
        ),
        ScrollingMovies(
          title: 'Now Playing',
          api: Endpoints.nowPlayingMoviesUrl(1),
          discoverType: 'now_playing',
          isTrending: false,
          includeAdult: includeAdult,
        ),
        ScrollingMovies(
          title: 'Upcoming',
          api: Endpoints.upcomingMoviesUrl(1),
          discoverType: 'upcoming',
          isTrending: false,
          includeAdult: includeAdult,
        ),
        GenreListGrid(api: Endpoints.movieGenresUrl()),
        const MoviesFromWatchProviders(),
      ],
    ));
  }
}
