// ignore_for_file: unused_field

import 'package:reelriot/provider/bookmarks_provider.dart';
import 'package:reelriot/screens/bookmarks/bookmark_tv_screen.dart';
import 'package:reelriot/screens/bookmarks/movie_bookmark_tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const secondary = Color(0xFF7C3AED);

  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgElevatedDark = Color(0xFF111827);

  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const bgElevatedLight = Color(0xFFF1F5F9);

  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF64748B);
  static const textTertDark = Color(0x80FFFFFF);
  static const textTertLight = Color(0xFF94A3B8);
}

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<BookmarksProvider>(context, listen: false);
      provider.fetchMovies();
      provider.fetchTV();
      provider.syncIfNeeded();
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookmarksProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? _C.bgCanvasDark : _C.bgCanvasLight;
    final surface = isDark ? _C.bgSurfaceDark : _C.bgSurfaceLight;
    final elevated = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textTert = isDark ? _C.textTertDark : _C.textTertLight;

    if (provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.errorMessage!)),
          );
          provider.clearError();
        }
      });
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Cinematic header ─────────────────────────────────────────────
            Container(
              color: surface,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: elevated,
                              border: Border.all(color: border, width: 1),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: textPrim,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [_C.secondary, _C.primary],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds),
                            child: Text(
                              tr('bookmarks'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'PoppinsSB',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab bar
                  Container(
                    decoration: BoxDecoration(
                      color: elevated,
                      border: Border(
                        top: BorderSide(color: border, width: 1),
                      ),
                    ),
                    child: TabBar(
                      controller: tabController,
                      indicatorColor: _C.primary,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: _C.primary,
                      unselectedLabelColor: textTert,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PoppinsSB',
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(
                                  FontAwesomeIcons.clapperboard,
                                  size: 16,
                                ),
                              ),
                              Text(tr('movies')),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.live_tv_rounded, size: 18),
                              ),
                              Text(tr('tv_series')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  MovieBookmark(movieList: provider.movies),
                  TVBookmark(tvList: provider.tvList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
