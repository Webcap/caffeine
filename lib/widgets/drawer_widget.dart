import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/screens/common/server_status_screen.dart';
import 'package:reelriot/screens/tv_screens/live_tv_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reelriot/screens/bookmarks/bookmark_screen.dart';
import 'package:reelriot/screens/common/update_screen.dart';
import 'package:reelriot/utils/app_images.dart';
import 'package:reelriot/utils/helpers/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// ─── Design tokens (mirrors design.json) ─────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const secondary = Color(0xFF7C3AED);

  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgElevatedDark = Color(0xFF111827);

  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const bgElevatedLight = Color(0xFFF1F5F9);

  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF475569);
}

// ─── Drawer ───────────────────────────────────────────────────────────────────

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appDep = Provider.of<AppDependencyProvider>(context);

    final bg = isDark ? _C.bgSurfaceDark : _C.bgSurfaceLight;
    final surface = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;

    return Container(
      color: bg,
      child: Column(
        children: [
          // ── Brand header ──────────────────────────────────────────────────
          _DrawerHeader(
            isDark: isDark,
            surface: surface,
            border: border,
            textPrim: textPrim,
            textSec: textSec,
          ),

          // ── Nav items ─────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _DrawerItem(
                  icon: FontAwesomeIcons.bookmark,
                  label: tr('bookmarks'),
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  textPrim: textPrim,
                  onTap: () {
                    Navigator.pop(context);
                    nextScreen(context, const BookmarkScreen());
                  },
                ),
                if (appDep.displayOTTDrawer)
                  _DrawerItem(
                    icon: FontAwesomeIcons.tv,
                    label: tr('live_tv'),
                    isDark: isDark,
                    surface: surface,
                    border: border,
                    textPrim: textPrim,
                    onTap: () {
                      Navigator.pop(context);
                      nextScreen(context, const ChannelList());
                    },
                  ),
                _DrawerItem(
                  icon: Icons.system_update_rounded,
                  label: tr('check_for_update'),
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  textPrim: textPrim,
                  onTap: () {
                    Navigator.pop(context);
                    nextScreen(context, const UpdateScreen(isForced: false));
                  },
                ),
                _DrawerItem(
                  icon: FontAwesomeIcons.server,
                  label: tr('check_server'),
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  textPrim: textPrim,
                  onTap: () {
                    Navigator.pop(context);
                    nextScreen(context, const ServerStatusScreen());
                  },
                ),
                _DrawerItem(
                  icon: Icons.share_rounded,
                  label: tr('shared_the_app'),
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  textPrim: textPrim,
                  onTap: () => SharePlus.instance
                      .share(ShareParams(text: tr('share_text'))),
                ),
              ],
            ),
          ),

          // ── Footer version line ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _C.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Powered by TMDB',
                  style: TextStyle(
                    fontSize: 11,
                    color: textSec,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Brand header section ─────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrim;
  final Color textSec;

  const _DrawerHeader({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrim,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          bottom: BorderSide(color: border, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo container
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(),
            child: SvgPicture.asset(MovixIcon.appLogo),
          ),
          const SizedBox(height: 14),
          // Gradient wordmark
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [_C.secondary, Color(0xFFEF4444)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: const Text(
              'Caffeine',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: Colors.white,
                fontFamily: 'PoppinsSB',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your cinematic streaming universe',
            style: TextStyle(
              fontSize: 12,
              color: textSec,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single nav row item ──────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrim;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: _C.primary.withValues(alpha: 0.08),
          highlightColor: _C.primary.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 1),
            ),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _C.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 16, color: _C.primary),
                ),
                const SizedBox(width: 14),
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textPrim,
                      height: 1.2,
                    ),
                  ),
                ),
                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark
                      ? const Color(0x60FFFFFF)
                      : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
