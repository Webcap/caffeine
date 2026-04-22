// ignore_for_file: avoid_unnecessary_containers

import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_about.dart';
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

  @override
  bool get wantKeepAlive => true;

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

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero poster + overlay controls + videos chip ─────────────
          SliverToBoxAdapter(
            child: TVDetailQuickInfo(
              tvSeries: widget.tvSeries,
              heroId: widget.heroId,
              onVideosTap: _scrollToVideos,
            ),
          ),

          // ── Compact ratings + bookmark ───────────────────────────────
          SliverToBoxAdapter(
            child: TVDetailOptions(tvSeries: widget.tvSeries),
          ),

          // ── Synopsis + content ─────────────────────────────────────
          SliverToBoxAdapter(
            child: TVAbout(
              tvSeries: widget.tvSeries,
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
          api: Endpoints.getTVWatchProviders(widget.tvSeries.id!, lang),
          country: country,
        );
      },
    );
  }
}
