import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:easy_localization/easy_localization.dart';

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

class TVEpisodeQuickInfo extends StatelessWidget {
  const TVEpisodeQuickInfo({
    super.key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    this.seriesName,
  });

  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;

  static String _seasonEpisodeLabel(int? season, int? episode) {
    final s = season ?? 0;
    final e = episode ?? 0;
    final sStr = s <= 9 ? 'S0$s' : 'S$s';
    final eStr = e <= 9 ? 'E0$e' : 'E$e';
    return '$sStr · $eStr';
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

    final recentProvider = Provider.of<RecentProvider>(context);
    bool isWatched = false;
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
        if (total > 0 && (elapsed / total) >= 0.9) {
          isWatched = true;
        }
        break;
      }
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isTablet = screenWidth >= 600;

    // Responsive hero height: capped on tablets, matching the pattern used
    // by movie/TV-show detail (movie_detail_quick_info.dart, tv_detail_quick_info.dart).
    final heroHeight = isTablet
        ? (screenWidth > screenHeight ? 340.0 : 380.0)
        : screenHeight * 0.45;
    final imageUrl = episodeList.stillPath;
    final baseUrl =
        buildImageUrl(tmdbBaseImageUrl, proxyUrl, isProxy, context);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Hero still (full bleed) ─────────────────────────────────────
          Positioned.fill(
            child: imageUrl == null || imageUrl.isEmpty
                ? ColoredBox(
                    color: _C.bgSurfaceDark,
                    child: Icon(
                      Icons.live_tv_rounded,
                      size: 80,
                      color: iconBg,
                    ),
                  )
                : CachedNetworkImage(
                    cacheManager: cacheProp(),
                    imageUrl: '${baseUrl}original/$imageUrl',
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ColoredBox(
                      color: _C.bgSurfaceDark,
                      child: const Center(
                        child: CircularProgressIndicator(color: _C.primary),
                      ),
                    ),
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: _C.bgSurfaceDark,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 64,
                        color: iconBg,
                      ),
                    ),
                  ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: _C.heroOverlay,
              ),
            ),
          ),

          // ── Top overlay: back + open season ────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 24 : 12,
                isTablet ? 16 : 8,
                isTablet ? 24 : 12,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                    iconBg: iconBg,
                    border: border,
                    textColor: textPrim,
                    size: isTablet ? 48 : 42,
                  ),
                  _GlassButton(
                    icon: Icons.list_rounded,
                    onTap: () => Navigator.pop(context),
                    iconBg: iconBg,
                    border: border,
                    textColor: textPrim,
                    size: isTablet ? 48 : 42,
                  ),
                ],
              ),
            ),
          ),

          // ── S00E00 chip (lower-left) ──────────────────────────────────────
          Positioned(
            left: isTablet ? 24 : 16,
            bottom: isTablet ? 112 : 90,
            child: Container(
              height: isTablet ? 32 : 28,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border, width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                _seasonEpisodeLabel(
                    episodeList.seasonNumber, episodeList.episodeNumber),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.secondary,
                  fontFamily: 'PoppinsSB',
                ),
              ),
            ),
          ),

          // ── Episode title + series name (bottom) ───────────────────────────
          Positioned(
            left: isTablet ? 24 : 16,
            right: isTablet ? 24 : 16,
            bottom: isTablet ? 32 : 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episodeList.name ?? '—',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 26 : 20,
                          fontWeight: FontWeight.w700,
                          color: textPrim,
                          height: 1.2,
                          fontFamily: 'PoppinsSB',
                        ),
                      ),
                      if (seriesName != null && seriesName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          seriesName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 13,
                            color: textTert,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isWatched) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    this.size = 42,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconBg;
  final Color border;
  final Color textColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: iconBg,
          border: Border.all(color: border, width: 1),
        ),
        child: Icon(icon, size: size * 0.48, color: textColor),
      ),
    );
  }
}
