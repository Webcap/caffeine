import 'package:reelriot/screens/discover_screens/widgets/discover_movies_tab.dart';
import 'package:reelriot/screens/discover_screens/widgets/discover_tv_tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const secondary = Color(0xFF7C3AED);

  static const bgCanvasDark = Color(0xFF030712);
  static const bgCanvasLight = Color(0xFFF8FAFC);

  static const bgElevatedDark = Color(0x0DFFFFFF);
  static const bgElevatedLight = Color(0xFFF1F5F9);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgSurfaceLight = Color(0xFFFFFFFF);

  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF64748B);
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _C.bgCanvasDark : _C.bgCanvasLight;
    final surface = isDark ? _C.bgSurfaceDark : _C.bgSurfaceLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;
    final border = isDark ? _C.borderDark : _C.borderLight;

    return Container(
      color: bg,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: _C.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.primary.withValues(alpha: 0.5)),
              ),
              dividerColor: Colors.transparent,
              labelColor: _C.primary,
              unselectedLabelColor: textSec,
              labelStyle: const TextStyle(
                fontFamily: 'PoppinsSB',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.clapperboard, size: 16),
                      const SizedBox(width: 8),
                      Text(tr("movies")),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.tv, size: 16),
                      const SizedBox(width: 8),
                      Text(tr("tv_series")),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [DiscoverMoviesTab(), DiscoverTVTab()],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
