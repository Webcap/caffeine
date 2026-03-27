import 'package:caffiene/models/recently_watched.dart';
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
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/widgets/banner_ad_widget.dart';
import 'package:caffiene/widgets/featured_match_card.dart';
import 'package:provider/provider.dart';

class MainTVDisplay extends StatefulWidget {
  const MainTVDisplay({
    super.key,
  });

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
    var rEpisodes = Provider.of<RecentProvider>(context).upNextEpisodes;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    final featuredEvent =
        Provider.of<AppDependencyProvider>(context).featuredEvent;
    return Container(
      child: ListView(
        children: [
          if (featuredEvent != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: FeaturedMatchCard(event: featuredEvent),
            ),
          DiscoverTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            discoverType: 'discover',
          ),
          rEpisodes.isEmpty
              ? Container()
              : ScrollingRecentEpisodes(episodesList: rEpisodes),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("popular"),
            api: Endpoints.popularTVUrl(lang),
            discoverType: 'popular',
            isTrending: false,
          ),
          const BannerAdWidget(),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("trending_this_week"),
            api: Endpoints.trendingTVUrl(lang),
            discoverType: 'trending',
            isTrending: true,
          ),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("top_rated"),
            api: Endpoints.topRatedTVUrl(lang),
            discoverType: 'top_rated',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("airing_today"),
            api: Endpoints.airingTodayUrl(lang),
            discoverType: 'airing_today',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("on_the_air"),
            api: Endpoints.onTheAirUrl(lang),
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
