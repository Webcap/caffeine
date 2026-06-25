import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/common/watch_providers_dets.dart';
import 'package:reelriot/screens/movie_screens/widgets/watch_provider_button.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/screens/tv_screens/episode_detail_page.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_seasons_list.dart';
import 'package:reelriot/models/recently_watched.dart';
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

class TVDetailQuickInfo extends StatelessWidget {
  const TVDetailQuickInfo({
    super.key,
    required this.tvSeries,
    required this.heroId,
    this.onVideosTap,
  });

  final TV tvSeries;
  final String heroId;
  final VoidCallback? onVideosTap;

  @override
  Widget build(BuildContext context) {
    final recentProvider = Provider.of<RecentProvider>(context);
    bool isWatched = false;
    for (var e in recentProvider.episodes) {
      if (e.id == tvSeries.id) {
        final elapsed = e.elapsed ?? 0;
        final remaining = e.remaining ?? 0;
        final total = elapsed + remaining;
        if (total > 0 && (elapsed / total) >= 0.9) {
          isWatched = true;
          break;
        }
      }
    }

    final appLang = Provider.of<SettingsProvider>(context).appLanguage;
    final watchCountry = Provider.of<SettingsProvider>(context).defaultCountry;
    final isProxy = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final iconBg = isDark ? _C.iconBgDark : _C.iconBgLight;
    final border = isDark ? _C.borderDark : _C.borderLight;

    final heroHeight = MediaQuery.of(context).size.height * 0.55;
    final imageUrl = tvSeries.backdropPath ?? tvSeries.posterPath;
    final baseUrl =
        buildImageUrl(tmdbBaseImageUrl, proxyUrl, isProxy, context);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Hero backdrop (full bleed) ─────────────────────────────────
          Positioned.fill(
            child: imageUrl == null
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
                    imageUrl: baseUrl +
                        (tvSeries.backdropPath != null
                            ? 'original/${tvSeries.backdropPath}'
                            : 'w500/${tvSeries.posterPath}'),
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

          // ── Gradient overlay for readability ───────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: _C.heroOverlay,
              ),
            ),
          ),

          // ── Top overlay controls ──────────────────────────────────────
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: WatchProvidersButton(
                          country: watchCountry,
                          api: Endpoints.getTVWatchProviders(
                              tvSeries.id!, appLang),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (builder) => WatchProvidersDetails(
                                country: watchCountry,
                                api: Endpoints.getTVWatchProviders(
                                    tvSeries.id!, appLang),
                              ),
                            );
                          },
                        ),
                      ),
                      _GlassButton(
                        icon: Icons.share_rounded,
                        onTap: () => _shareTV(context),
                        iconBg: iconBg,
                        border: border,
                        textColor: textPrim,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Centered Play Button (Watch Now / Continue) ────────────────────────
          Center(
            child: _WatchNowButton(tvSeries: tvSeries),
          ),

          // ── TV title + year (anchored at bottom of hero) ───────────────
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
                        tvSeries.firstAirDate != null &&
                                tvSeries.firstAirDate!.isNotEmpty
                            ? '${tvSeries.name} (${DateTime.tryParse(tvSeries.firstAirDate!)?.year ?? ''})'
                            : tvSeries.name ?? '—',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
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
                              tr('Watched'),
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

  void _shareTV(BuildContext context) {
    Share.share(tr('share_tv', namedArgs: {
      'title': tvSeries.name ?? '—',
      'rating': (tvSeries.voteAverage ?? 0).toString(),
      'id': '${tvSeries.id}',
    }));
  }
}

class _WatchNowButton extends StatelessWidget {
  final TV tvSeries;
  const _WatchNowButton({required this.tvSeries});

  @override
  Widget build(BuildContext context) {
    final recentProvider = Provider.of<RecentProvider>(context);
    
    // Find if we have an "Up Next" or "In Progress" episode for this show
    RecentEpisode? target;
    
    // 1. Check Up Next
    for (var e in recentProvider.upNextEpisodes) {
      if (e.seriesId == tvSeries.id) {
        target = e;
        break;
      }
    }
    
    // 2. Check In Progress (In progress takes priority for "Resume")
    for (var e in recentProvider.continueWatchingEpisodes) {
      if (e.seriesId == tvSeries.id) {
        target = e;
        break;
      }
    }

    final String label = target == null 
        ? tr('watch_now') 
        : (target.elapsed! > 0 ? tr('resume') : tr('watch_next'));
    
    final String subtitle = target == null 
        ? 'S1 | E1' 
        : 'S${target.seasonNum} | E${target.episodeNum}';

    return GestureDetector(
      onTap: () async {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        final isProxy = settings.enableProxy;
        final proxyUrl = Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
        final lang = settings.appLanguage;
        
        try {
          if (target == null) {
            // Fetch season 1 details
            final s1 = await fetchTVDetails(
              Endpoints.getSeasonDetails(tvSeries.id!, 1, lang),
              isProxy,
              proxyUrl
            );
            
            if (s1.episodes != null && s1.episodes!.isNotEmpty && context.mounted) {
              final ep = s1.episodes!.first;
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EpisodeDetailPage(
                    seriesName: tvSeries.name,
                    posterPath: tvSeries.posterPath,
                    tvId: tvSeries.id,
                    episodes: s1.episodes,
                    episodeList: ep,
                  )
                )
              );
            }
          } else {
             final seasonDetails = await fetchTVDetails(
              Endpoints.getSeasonDetails(tvSeries.id!, target.seasonNum!, lang),
              isProxy,
              proxyUrl
            );
            
            final epMeta = seasonDetails.episodes?.firstWhere(
              (e) => e.episodeNumber == target!.episodeNum,
              orElse: () => EpisodeList()
            );

            if (epMeta != null && epMeta.episodeId != null && context.mounted) {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EpisodeDetailPage(
                    seriesName: tvSeries.name,
                    posterPath: tvSeries.posterPath,
                    tvId: tvSeries.id,
                    episodes: seasonDetails.episodes,
                    episodeList: epMeta,
                  )
                )
              );
            }
          }
        } catch (e) {
           if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr('error_loading_episode')))
              );
           }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.5),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
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
