import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/widgets/episode_about.dart';
import 'package:reelriot/screens/tv_screens/widgets/episode_detail_expanded_layout.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_episode_option.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_episode_quick_info.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const bgCanvasDark = Color(0xFF030712);
  static const bgCanvasLight = Color(0xFFF8FAFC);
}

class EpisodeDetailPage extends StatefulWidget {
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;
  final String? posterPath;

  const EpisodeDetailPage({
    super.key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    this.seriesName,
    required this.posterPath,
  });

  @override
  State<EpisodeDetailPage> createState() => EpisodeDetailPageState();
}

class EpisodeDetailPageState extends State<EpisodeDetailPage>
    with AutomaticKeepAliveClientMixin<EpisodeDetailPage> {
  final _scrollController = ScrollController();
  late EpisodeList _currentEpisode;
  List<EpisodeList>? _episodes;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentEpisode = widget.episodeList;
    _episodes = widget.episodes;
    _fetchFullDetailsIfNeeded();
  }

  Future<void> _fetchFullDetailsIfNeeded() async {
    final tvId = widget.tvId;
    final seasonNum = _currentEpisode.seasonNumber;
    if (tvId == null || seasonNum == null) return;

    if (_currentEpisode.overview == null ||
        _currentEpisode.overview!.isEmpty ||
        _episodes == null ||
        _episodes!.isEmpty) {
      try {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
        final isProxy = settings.enableProxy;
        final proxyUrl = appDep.tmdbProxy;
        final lang = settings.appLanguage;

        final seasonDetails = await fetchTVDetails(
          Endpoints.getSeasonDetails(tvId, seasonNum, lang),
          isProxy,
          proxyUrl,
        );

        if (seasonDetails.episodes != null && mounted) {
          final matched = seasonDetails.episodes!.firstWhere(
            (e) => e.episodeNumber == _currentEpisode.episodeNumber,
            orElse: () => _currentEpisode,
          );
          setState(() {
            _episodes = seasonDetails.episodes;
            _currentEpisode = matched;
          });
        }
      } catch (e) {
        debugPrint('[EpisodeDetailPage] Error fetching season details: $e');
      }
    }
  }

  // Tablet-landscape / unfolded-foldable width: switch to the two-column
  // "media left, content right" layout instead of stretching the mobile
  // single-column layout across the extra width.
  static const double _expandedBreakpoint = 840;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _C.bgCanvasDark : _C.bgCanvasLight;
    final isExpanded =
        MediaQuery.sizeOf(context).width >= _expandedBreakpoint;

    return Scaffold(
      backgroundColor: bg,
      body: isExpanded
          ? EpisodeDetailExpandedLayout(
              episodeList: _currentEpisode,
              episodes: _episodes,
              seriesName: widget.seriesName,
              tvId: widget.tvId,
              posterPath: widget.posterPath,
            )
          : CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: TVEpisodeQuickInfo(
                    episodeList: _currentEpisode,
                    episodes: _episodes,
                    seriesName: widget.seriesName,
                    tvId: widget.tvId,
                  ),
                ),
                SliverToBoxAdapter(
                  child: TVEpisodeOptions(
                    episodeList: _currentEpisode,
                    tvId: widget.tvId,
                    seriesName: widget.seriesName,
                  ),
                ),
                SliverToBoxAdapter(
                  child: EpisodeAbout(
                    episodeList: _currentEpisode,
                    episodes: _episodes,
                    seriesName: widget.seriesName,
                    tvId: widget.tvId,
                    posterPath: widget.posterPath,
                  ),
                ),
              ],
            ),
    );
  }
}
