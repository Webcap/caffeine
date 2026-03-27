import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'shimmer_widget.dart';

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class CastCrewDesign {
  CastCrewDesign._();
  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textSecDark = Color(0xB8FFFFFF);
  static const borderDark = Color(0x14FFFFFF);
  static const iconBgDark = Color(0x14FFFFFF);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecLight = Color(0xFF64748B);
  static const borderLight = Color(0x140F172A);

  static const radiusMd = 16.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space6 = 24.0;
  static const screenPadH = 16.0;
  static const shadowCard = BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );
}

class CastCrewCircleBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final Color bgColor;

  const CastCrewCircleBackButton({
    super.key,
    required this.onTap,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(Icons.arrow_back_rounded, size: 22, color: iconColor),
        ),
      ),
    );
  }
}

class CastCrewSectionCard extends StatelessWidget {
  final Color surface;
  final Color border;
  final Widget child;

  const CastCrewSectionCard({
    super.key,
    required this.surface,
    required this.border,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(CastCrewDesign.radiusMd),
        border: Border.all(color: border),
        boxShadow: const [CastCrewDesign.shadowCard],
      ),
      child: child,
    );
  }
}

class CastCrewEmptyCard extends StatelessWidget {
  final Color surface;
  final Color border;
  final String message;
  final Color textSec;

  const CastCrewEmptyCard({
    super.key,
    required this.surface,
    required this.border,
    required this.message,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: CastCrewDesign.space6, horizontal: CastCrewDesign.space4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(CastCrewDesign.radiusMd),
        border: Border.all(color: border),
        boxShadow: const [CastCrewDesign.shadowCard],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: textSec, fontSize: 14),
      ),
    );
  }
}

class CastCrewTileDivider extends StatelessWidget {
  final double indent;

  const CastCrewTileDivider({super.key, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: indent, endIndent: CastCrewDesign.space4);
  }
}

class CastCrewTile extends StatelessWidget {
  final String creditId;
  final String? profilePath;
  final String name;
  final String subtitle;
  final Color textPrim;
  final Color textSec;
  final VoidCallback onTap;
  final String themeMode;

  const CastCrewTile({
    super.key,
    required this.creditId,
    this.profilePath,
    required this.name,
    required this.subtitle,
    required this.textPrim,
    required this.textSec,
    required this.onTap,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CastCrewDesign.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: CastCrewDesign.space4,
              vertical: CastCrewDesign.space3),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Hero(
                  tag: creditId,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: profilePath == null || profilePath!.isEmpty
                        ? Image.asset(
                            'assets/images/na_rect.png',
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                          )
                        : CachedNetworkImage(
                            cacheManager: cacheProp(),
                            fadeOutDuration: const Duration(milliseconds: 300),
                            fadeInDuration: const Duration(milliseconds: 700),
                            imageUrl: buildImageUrl(TMDB_BASE_IMAGE_URL,
                                    proxyUrl, isProxyEnabled, context) +
                                imageQuality +
                                profilePath!,
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                            placeholder: (_, __) =>
                                castAndCrewTabImageShimmer(themeMode),
                            errorWidget: (_, __, ___) => Image.asset(
                              'assets/images/na_rect.png',
                              fit: BoxFit.cover,
                              width: 56,
                              height: 56,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: CastCrewDesign.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: textPrim,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textSec,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: textSec, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
