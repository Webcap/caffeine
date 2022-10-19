import 'package:flutter/material.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/provider/adultmode_provider.dart';
import 'package:login/screens/tv_screens/widgets/discover_tv.dart';
import 'package:login/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:login/screens/tv_screens/widgets/tv_genre_widgets.dart';
import 'package:login/screens/tv_screens/widgets/tv_widgets.dart';
import 'package:provider/provider.dart';

class MainTVDisplay extends StatefulWidget {
  const MainTVDisplay({
    Key? key,
  }) : super(key: key);

  @override
  State<MainTVDisplay> createState() => _MainTVDisplayState();
}

class _MainTVDisplayState extends State<MainTVDisplay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          DiscoverTV(
              includeAdult: Provider.of<AdultmodeProvider>(context).isAdult),
          ScrollingTV(
            includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
            title: 'Popular',
            api: Endpoints.popularTVUrl(1),
            discoverType: 'popular',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
            title: 'Trending this week',
            api: Endpoints.trendingTVUrl(1),
            discoverType: 'trending',
            isTrending: true,
          ),
          ScrollingTV(
            includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
            title: 'Top Rated',
            api: Endpoints.topRatedTVUrl(1),
            discoverType: 'top_rated',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
            title: 'Airing today',
            api: Endpoints.airingTodayUrl(1),
            discoverType: 'airing_today',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
            title: 'On the air',
            api: Endpoints.onTheAirUrl(1),
            discoverType: 'on_the_air',
            isTrending: false,
          ),
          TVGenreListGrid(api: Endpoints.tvGenresUrl()),
          const TVShowsFromWatchProviders(),
        ],
      ),
    );
  }
}
