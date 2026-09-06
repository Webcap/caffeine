import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/widgets/episode_about.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_episode_option.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const secondary = Color(0xFF7C3AED);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const iconBgDark = Color(0x14FFFFFF);
  static const iconBgLight = Color(0x140F172A);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textTertDark = Color(0x80FFFFFF);
  static const textTertLight = Color(0xFF94A3B8);
}

/// Two-column layout for the episode detail page on tablet-landscape /
/// unfolded-foldable widths (>= 840dp): still image pinned in a contained
/// media card on the left, title/ratings/synopsis/cast/images scrolling
/// together on the right. Implements the "media left, content right"
/// large-screen composition design.json already specified for detail
/// pages but that no screen in this app had built yet.
class EpisodeDetailExpandedLayout extends StatelessWidget {
  const EpisodeDetailExpandedLayout({
    super.key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    this.seriesName,
    required this.posterPath,
  });

  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;
  final String? posterPath;

  static String _seasonEpisodeLabel(int? season, int? episode) {
    final s = season ?? 0;
    final e = episode ?? 0;
    final sStr = s <= 9 ? 'S0$s' : 'S$s';
    final eStr = e <= 9 ? 'E0$e' : 'E$e';
    return '$sStr · $eStr';
  }

  bool _computeIsWatched(BuildContext context) {
    final recentProvider = Provider.of<RecentProvider>(context);
    for (var e in recentProvider.episodes) {
      if (e.id != null &&
          e.id == episodeList.episodeId &&
          e.seasonNum != null &&
          e.seasonNum == episodeList.seasonNumber &&
          e.episodeNum != null &&
          e.episodeNum == episodeList.episodeNumber) {
        final elapsed = e.elapsed ?? 0;
        final remaining = e.remaining ?? 0;
        final total = elapsed + remaining;
        return total > 0 && (elapsed / total) >= 0.9;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isProxy = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textTert = isDark ? _C.textTertDark : _C.textTertLight;
    final iconBg = isDark ? _C.iconBgDark : _C.iconBgLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final isWatched = _computeIsWatched(context);

    final imageUrl = episodeList.stillPath;
    final baseUrl = buildImageUrl(tmdbBaseImageUrl, proxyUrl, isProxy, context);

    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: pinned media card ──────────────────────────────────────
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 12, 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl == null || imageUrl.isEmpty
                          ? ColoredBox(
                              color: _C.bgSurfaceDark,
                              child: Icon(Icons.live_tv_rounded,
                                  size: 64, color: iconBg),
                            )
                          : CachedNetworkImage(
                              cacheManager: cacheProp(),
                              imageUrl: '${baseUrl}original/$imageUrl',
                              fit: BoxFit.cover,
                              placeholder: (_, __) => ColoredBox(
                                color: _C.bgSurfaceDark,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: _C.primary),
                                ),
                              ),
                              errorWidget: (_, __, ___) => ColoredBox(
                                color: _C.bgSurfaceDark,
                                child: Icon(Icons.broken_image_outlined,
                                    size: 56, color: iconBg),
                              ),
                            ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _GlassButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                          iconBg: iconBg,
                          border: border,
                          textColor: textPrim,
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: border, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _seasonEpisodeLabel(episodeList.seasonNumber,
                                episodeList.episodeNumber),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _C.secondary,
                              fontFamily: 'PoppinsSB',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Right: title + ratings + synopsis + cast + images ───────────
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 24, 24, 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            episodeList.name ?? '—',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: textPrim,
                              height: 1.15,
                              fontFamily: 'PoppinsSB',
                            ),
                          ),
                        ),
                        if (isWatched) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.check_circle_rounded,
                                    color: Colors.green, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Watched',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (seriesName != null && seriesName!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        seriesName!,
                        style: TextStyle(
                          fontSize: 16,
                          color: textTert,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    TVEpisodeOptions(
                      episodeList: episodeList,
                      tvId: tvId,
                      seriesName: seriesName,
                    ),
                    EpisodeAbout(
                      episodeList: episodeList,
                      episodes: episodes,
                      seriesName: seriesName,
                      tvId: tvId,
                      posterPath: posterPath,
                      scrollable: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.onTap,
    required this.iconBg,
    required this.border,
    required this.textColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconBg;
  final Color border;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
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
