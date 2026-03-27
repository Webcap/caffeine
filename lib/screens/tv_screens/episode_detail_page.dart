import 'package:flutter/material.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/screens/tv_screens/widgets/episode_about.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_episode_option.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_episode_quick_info.dart';

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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _C.bgCanvasDark : _C.bgCanvasLight;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: TVEpisodeQuickInfo(
              episodeList: widget.episodeList,
              seriesName: widget.seriesName,
              tvId: widget.tvId,
            ),
          ),
          SliverToBoxAdapter(
            child: TVEpisodeOptions(episodeList: widget.episodeList),
          ),
          SliverToBoxAdapter(
            child: EpisodeAbout(
              episodeList: widget.episodeList,
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
