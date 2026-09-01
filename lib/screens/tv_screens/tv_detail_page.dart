// ignore_for_file: avoid_unnecessary_containers

import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_about.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_detail_expanded_layout.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_detail_options.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_detail_quick_info.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_widgets.dart';
import 'package:provider/provider.dart';
import '/models/tv.dart';
import 'package:flutter/material.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const bgCanvasDark = Color(0xFF030712);
  static const bgCanvasLight = Color(0xFFF8FAFC);
}

class TVDetailPage extends StatefulWidget {
  final TV tvSeries;
  final String heroId;

  const TVDetailPage({
    super.key,
    required this.tvSeries,
    required this.heroId,
  });

  @override
  State<TVDetailPage> createState() => TVDetailPageState();
}

class TVDetailPageState extends State<TVDetailPage>
    with AutomaticKeepAliveClientMixin<TVDetailPage> {
  final _scrollController = ScrollController();
  final _videosKey = GlobalKey();
  late TV _tvSeries;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tvSeries = widget.tvSeries;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFullDetailsIfNeeded();
    });
  }

  Future<void> _loadFullDetailsIfNeeded() async {
    if (_tvSeries.id == null) return;
    if (_tvSeries.overview == null ||
        _tvSeries.overview!.isEmpty ||
        _tvSeries.backdropPath == null ||
        _tvSeries.firstAirDate == null ||
        _tvSeries.voteAverage == null) {
      final lang = Provider.of<SettingsProvider>(context, listen: false).appLanguage;
      final isProxy = Provider.of<SettingsProvider>(context, listen: false).enableProxy;
      final proxyUrl = Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
      final api = Endpoints.tvDetailsUrl(_tvSeries.id!, lang);
      try {
        final fullTV = await getTV(api, isProxy, proxyUrl);
        if (mounted) {
          setState(() {
            _tvSeries = fullTV;
          });
        }
      } catch (e) {
        debugPrint('[TVDetailPage] Error fetching full details: $e');
      }
    }
  }

  void _scrollToVideos() {
    final ctx = context;
    final key = _videosKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ctx.mounted) return;
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _C.bgCanvasDark : _C.bgCanvasLight;
    final isExpanded = MediaQuery.sizeOf(context).width >= 840;

    return Scaffold(
      backgroundColor: bg,
      body: isExpanded
          ? TVDetailExpandedLayout(
              tvSeries: _tvSeries,
              heroId: widget.heroId,
              onVideosTap: _scrollToVideos,
            )
          : CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero poster + overlay controls + videos chip ─────────────
          SliverToBoxAdapter(
            child: TVDetailQuickInfo(
              tvSeries: _tvSeries,
              heroId: widget.heroId,
              onVideosTap: _scrollToVideos,
            ),
          ),

          // ── Compact ratings + bookmark ───────────────────────────────
          SliverToBoxAdapter(
            child: TVDetailOptions(tvSeries: _tvSeries),
          ),

          // ── Synopsis + content ─────────────────────────────────────
          SliverToBoxAdapter(
            child: TVAbout(
              tvSeries: _tvSeries,
              videosKey: _videosKey,
            ),
          ),
        ],
      ),
    );
  }

  void modalBottomSheetMenu(String country) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return TVWatchProvidersDetails(
          api: Endpoints.getTVWatchProviders(_tvSeries.id!, lang),
          country: country,
        );
      },
    );
  }
}
