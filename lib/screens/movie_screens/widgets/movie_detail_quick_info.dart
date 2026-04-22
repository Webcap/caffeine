import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);

  static const bgSurfaceDark = Color(0xFF0B0F14);

  static const iconBgDark = Color(0x14FFFFFF);
  static const iconBgLight = Color(0x140F172A);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);

  // heroOverlayDark: rgba(0,0,0,0.05) → 0.45 → 0.92
  static const heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x0D000000),
      Color(0x73000000),
      Color(0xEB000000),
    ],
  );
}

class MovieDetailQuickInfo extends StatelessWidget {
  const MovieDetailQuickInfo({
    super.key,
    required this.movie,
    required this.heroId,
    this.onTrailerTap,
  });

  final Movie movie;
  final String heroId;
  final VoidCallback? onTrailerTap;

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isProxy = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final iconBg = isDark ? _C.iconBgDark : _C.iconBgLight;
    final border = isDark ? _C.borderDark : _C.borderLight;

    final recentProvider = Provider.of<RecentProvider>(context);
    bool isWatched = false;
    for (var m in recentProvider.movies) {
      if (m.id == movie.id) {
        final elapsed = m.elapsed ?? 0;
        final remaining = m.remaining ?? 0;
        final total = elapsed + remaining;
        if (total > 0 && (elapsed / total) >= 0.9) {
          isWatched = true;
        }
        break;
      }
    }

    // Hero occupies ~45–55% of screen; use 0.5 of height
    final heroHeight = MediaQuery.of(context).size.height * 0.50;
    final imageUrl = movie.backdropPath ?? movie.posterPath;
    final baseUrl =
        buildImageUrl(TMDB_BASE_IMAGE_URL, proxyUrl, isProxy, context);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Hero poster (full bleed) ──────────────────────────────────────
          Positioned.fill(
            child: imageUrl == null
                ? ColoredBox(
                    color: _C.bgSurfaceDark,
                    child: Icon(
                      Icons.movie_outlined,
                      size: 80,
                      color: iconBg,
                    ),
                  )
                : CachedNetworkImage(
                    cacheManager: cacheProp(),
                    imageUrl: baseUrl +
                        (movie.backdropPath != null
                            ? 'original/${movie.backdropPath}'
                            : imageQuality + movie.posterPath!),
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ColoredBox(
                      color: _C.bgSurfaceDark,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: _C.primary,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: _C.bgSurfaceDark,
                      child: Icon(Icons.broken_image_outlined,
                          size: 64, color: iconBg),
                    ),
                  ),
          ),

          // ── Gradient overlay for readability ──────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _C.heroOverlay,
              ),
            ),
          ),

          // ── Top overlay controls ──────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                    iconBg: iconBg,
                    border: border,
                    textColor: textPrim,
                  ),
                  _GlassButton(
                    icon: Icons.share_rounded,
                    onTap: () => _shareMovie(context),
                    iconBg: iconBg,
                    border: border,
                    textColor: textPrim,
                  ),
                ],
              ),
            ),
          ),

          // ── Watch trailer chip (lower-left over artwork) ───────────────────
          Positioned(
            left: 16,
            bottom: 100,
            child: GestureDetector(
              onTap: onTrailerTap ?? () {},
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: border, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_fill_rounded,
                        size: 18, color: _C.primary),
                    const SizedBox(width: 6),
                    Text(
                      tr('videos'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Movie title + year (anchored at bottom of hero) ────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Hero(
              tag: heroId,
              child: Material(
                type: MaterialType.transparency,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        movie.releaseDate != null &&
                                movie.releaseDate!.isNotEmpty
                            ? '${movie.title} (${DateTime.tryParse(movie.releaseDate!)?.year ?? ''})'
                            : movie.title ?? '—',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textPrim,
                          height: 1.2,
                          letterSpacing: 0.2,
                          fontFamily: 'PoppinsSB',
                        ),
                      ),
                    ),
                    if (isWatched) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.green, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              tr('Watched'), // simple string
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareMovie(BuildContext context) {
    Share.share(tr('share_movie', namedArgs: {
      'title': movie.title ?? '—',
      'rating': (movie.voteAverage ?? 0).toString(),
      'id': '${movie.id}',
    }));
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconBg;
  final Color border;
  final Color textColor;

  const _GlassButton({
    required this.icon,
    required this.onTap,
    required this.iconBg,
    required this.border,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: iconBg,
          border: Border.all(color: border, width: 1),
        ),
        child: Icon(icon, size: 20, color: textColor),
      ),
    );
  }
}
