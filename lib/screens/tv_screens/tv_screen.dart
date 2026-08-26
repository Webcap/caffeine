import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/screens/tv_screens/widgets/scrolling_recent_tv_episode.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/widgets/discover_tv.dart';
import 'package:reelriot/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_genre_widgets.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_widgets.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/widgets/banner_ad_widget.dart';
import 'package:reelriot/widgets/featured_match_card.dart';
import 'package:reelriot/screens/common/update_screen.dart';
import 'package:provider/provider.dart';

class MainTVDisplay extends StatefulWidget {
  const MainTVDisplay({
    super.key,
  });

  @override
  State<MainTVDisplay> createState() => _MainTVDisplayState();
}

class _MainTVDisplayState extends State<MainTVDisplay> {
  Key _refreshKey = UniqueKey();

  Future<void> _refreshData() async {
    final recent = Provider.of<RecentProvider>(context, listen: false);
    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);

    await Future.wait([
      recent.fetchEpisodes(),
      recent.fetchWatchStatsFromApi(),
      appDep.fetchSportsStreams(),
    ]).catchError((e) {
      debugPrint('[MainTVDisplay] Refresh error: $e');
      return <void>[];
    });

    if (mounted) {
      setState(() {
        _refreshKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.appTheme == 'dark' || settings.appTheme == 'amoled';
    final rEpisodes = Provider.of<RecentProvider>(context).upNextEpisodes;
    final inProgress = Provider.of<RecentProvider>(context).inProgressEpisodes;
    final lang = settings.appLanguage;
    final featuredEvent =
        Provider.of<AppDependencyProvider>(context).featuredEvent;

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFFDC2626),
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF8FAFC),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          if (featuredEvent != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: FeaturedMatchCard(event: featuredEvent),
            ),
          DiscoverTV(
            key: ValueKey('discover_${_refreshKey.toString()}'),
            includeAdult: settings.isAdult,
            discoverType: 'discover',
          ),
          const UpdateBottom(),
          if (inProgress.isNotEmpty)
            ScrollingRecentEpisodes(
              episodesList: inProgress,
              title: tr("recently_watched"),
            ),
          if (rEpisodes.isNotEmpty)
            ScrollingRecentEpisodes(
              episodesList: rEpisodes,
              title: tr("up_next"),
            ),
          ScrollingTV(
            key: ValueKey('popular_${_refreshKey.toString()}'),
            includeAdult: settings.isAdult,
            title: tr("popular"),
            api: Endpoints.popularTVUrl(lang),
            discoverType: 'popular',
            isTrending: false,
          ),
          const BannerAdWidget(),
          ScrollingTV(
            key: ValueKey('trending_${_refreshKey.toString()}'),
            includeAdult: settings.isAdult,
            title: tr("trending_this_week"),
            api: Endpoints.trendingTVUrl(lang),
            discoverType: 'trending',
            isTrending: true,
          ),
          ScrollingTV(
            key: ValueKey('top_rated_${_refreshKey.toString()}'),
            includeAdult: settings.isAdult,
            title: tr("top_rated"),
            api: Endpoints.topRatedTVUrl(lang),
            discoverType: 'top_rated',
            isTrending: false,
          ),
          ScrollingTV(
            key: ValueKey('airing_today_${_refreshKey.toString()}'),
            includeAdult: settings.isAdult,
            title: tr("airing_today"),
            api: Endpoints.airingTodayUrl(lang),
            discoverType: 'airing_today',
            isTrending: false,
          ),
          ScrollingTV(
            key: ValueKey('on_the_air_${_refreshKey.toString()}'),
            includeAdult: settings.isAdult,
            title: tr("on_the_air"),
            api: Endpoints.onTheAirUrl(lang),
            discoverType: 'on_the_air',
            isTrending: false,
          ),
          TVGenreListGrid(
            key: ValueKey('genres_${_refreshKey.toString()}'),
            api: Endpoints.tvGenresUrl(lang),
          ),
          TVShowsFromWatchProviders(
            key: ValueKey('providers_${_refreshKey.toString()}'),
          ),
        ],
      ),
    );
  }
}
