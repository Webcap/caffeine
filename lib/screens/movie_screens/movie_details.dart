import 'package:flutter/material.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/movie_screens/widgets/movie_about.dart';
import 'package:reelriot/screens/movie_screens/widgets/movie_detail_quick_info.dart';
import 'package:reelriot/screens/movie_screens/widgets/movie_details_options.dart';
import 'package:reelriot/widgets/watch_now_button.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/widgets/native_ad_banner.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const bgCanvasDark = Color(0xFF030712);
  static const bgCanvasLight = Color(0xFFF8FAFC);
}

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final String heroId;

  const MovieDetailPage({
    super.key,
    required this.movie,
    required this.heroId,
  });

  @override
  MovieDetailPageState createState() => MovieDetailPageState();
}

class MovieDetailPageState extends State<MovieDetailPage>
    with AutomaticKeepAliveClientMixin<MovieDetailPage> {
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
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    final appDep = Provider.of<AppDependencyProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _C.bgCanvasDark : _C.bgCanvasLight;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero poster + overlay controls + trailer chip ─────────────
          SliverToBoxAdapter(
            child: MovieDetailQuickInfo(
              heroId: widget.heroId,
              movie: widget.movie,
              onTrailerTap: _scrollToVideos,
            ),
          ),

          // ── Compact ratings + favorite heart ────────────────────────
          SliverToBoxAdapter(
            child: MovieDetailOptions(movie: widget.movie),
          ),

          // ── Full-width "Watch now" pill (primary CTA) ───────────────
          if (widget.movie.releaseDate?.isNotEmpty == true &&
              appDep.displayWatchNowButton &&
              DateTime.tryParse(widget.movie.releaseDate!)!
                  .isBefore(DateTime.now()))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: WatchNowButton(
                    releaseYear:
                        DateTime.tryParse(widget.movie.releaseDate!)!.year,
                    movieId: widget.movie.id!,
                    movieName: widget.movie.title,
                    adult: widget.movie.adult,
                    posterPath: widget.movie.posterPath,
                    backdropPath: widget.movie.backdropPath,
                    api: Endpoints.movieDetailsUrl(widget.movie.id!, lang),
                    releaseDate: widget.movie.releaseDate,
                  ),
                ),
              ),
            ),

          // ── Synopsis + content ─────────────────────────────────────
          SliverToBoxAdapter(
            child: MovieAbout(
              movie: widget.movie,
              videosKey: _videosKey,
            ),
          ),

          // ── Native Ultra Banner Ad ──────────────────────────────────
          if (appDep.enableADS)
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  final bannerAds = appDep.initialAds.where((a) => a.matchesPlacement('banner') || a.matchesPlacement('ultra')).toList();
                  if (bannerAds.isEmpty) return const SizedBox.shrink();
                  
                  return NativeAdBanner(
                    ad: bannerAds.first,
                    type: NativeAdBannerType.ultra,
                  );
                }
              ),
            ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
