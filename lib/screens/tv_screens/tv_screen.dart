import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:caffiene/screens/tv_screens/widgets/scrolling_recent_tv_episode.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/widgets/discover_tv.dart';
import 'package:caffiene/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_genre_widgets.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_widgets.dart';
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
    var rEpisodes = Provider.of<RecentProvider>(context).episodes;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return Container(
      child: ListView(
        children: [
          DiscoverTV(
              includeAdult: Provider.of<SettingsProvider>(context).isAdult, discoverType: 'discover',),
          rEpisodes.isEmpty
              ? Container()
              : ScrollingRecentEpisodes(episodesList: rEpisodes),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("popular"),
            api: Endpoints.popularTVUrl(1, lang),
            discoverType: 'popular',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("trending_this_week"),
            api: Endpoints.trendingTVUrl(1, lang),
            discoverType: 'trending',
            isTrending: true,
          ),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("top_rated"),
            api: Endpoints.topRatedTVUrl(1, lang),
            discoverType: 'top_rated',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("airing_today"),
            api: Endpoints.airingTodayUrl(1, lang),
            discoverType: 'airing_today',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("on_the_air"),
            api: Endpoints.onTheAirUrl(1, lang),
            discoverType: 'on_the_air',
            isTrending: false,
          ),
          TVGenreListGrid(api: Endpoints.tvGenresUrl(lang)),
          const TVShowsFromWatchProviders(),
        ],
      ),
    );
  }
}
