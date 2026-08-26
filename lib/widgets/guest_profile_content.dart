import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:reelriot/preferences/profile_tab_preference.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:reelriot/widgets/watch_stat_card.dart';

class GuestProfileContent extends StatelessWidget {
  const GuestProfileContent({
    super.key,
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.elevated,
    required this.border,
    required this.textPrim,
    required this.textSec,
    required this.textTert,
    required this.appDep,
  });

  final bool isDark;
  final Color bg;
  final Color surface;
  final Color elevated;
  final Color border;
  final Color textPrim;
  final Color textSec;
  final Color textTert;
  final AppDependencyProvider appDep;

  static const _primary = Color(0xFFDC2626);
  static const _secondary = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final showActivateTv =
        appDep.isFeatureEnabled('toggle_tv_activate_button', defaultValue: true);
    final filteredSettings = settingdata
        .where((item) =>
            item.tital != tr("edit_profile") &&
            (showActivateTv || item.tital != tr("pair_tv")))
        .toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              children: [
                // ── Guest Avatar & Header ─────────────────────────
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary.withValues(alpha: 0.12),
                    border: Border.all(color: border, width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: _primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tr('guest_user'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textPrim,
                    fontFamily: 'PoppinsSB',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  tr('guest_mode_subtitle'),
                  style: TextStyle(
                    fontSize: 13,
                    color: textSec,
                    fontFamily: 'Poppins',
                  ),
                ),

                // ── Sync Prompt Card ─────────────────────────────
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFF1E1B4B).withValues(alpha: 0.6),
                              const Color(0xFF311042).withValues(alpha: 0.6),
                            ]
                          : [
                              const Color(0xFFEEF2FF),
                              const Color(0xFFFAF5FF),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _secondary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.cloud_sync_rounded,
                              color: _secondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('sync_across_devices'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textPrim,
                                    fontFamily: 'PoppinsSB',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tr('sync_devices_desc'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSec,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            Get.toNamed(Routes.login);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            tr('sign_in_or_create_account'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              fontFamily: 'PoppinsSB',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Watch time stats (Disabled for Guest Mode) ──
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: elevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 20,
                            color: textTert,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tr('last_2_weeks'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textSec,
                              fontFamily: 'PoppinsSB',
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _primary.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 12,
                                  color: _primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tr('sign_in_to_track'),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: _primary,
                                    letterSpacing: 0.5,
                                    fontFamily: 'PoppinsSB',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Dimmed / Disabled Stat Cards
                      Opacity(
                        opacity: 0.45,
                        child: Row(
                          children: [
                            Expanded(
                              child: WatchStatCard(
                                icon: Icons.movie_creation_rounded,
                                label: tr('movies'),
                                value: '--',
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: WatchStatCard(
                                icon: Icons.live_tv_rounded,
                                label: tr('tv_series'),
                                value: '--',
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Friendly callout prompt
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: border,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _primary.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.auto_graph_rounded,
                                    size: 16,
                                    color: _primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    tr('track_viewing_habits'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: textPrim,
                                      fontFamily: 'PoppinsSB',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              tr('track_viewing_habits_desc'),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: textSec,
                                height: 1.4,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Settings list ────────────────────────────────
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: elevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSettings.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: border,
                      indent: 56,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, i) {
                      return InkWell(
                        onTap: filteredSettings[i].onTap,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                filteredSettings[i].iconImage,
                                colorFilter: ColorFilter.mode(
                                  textPrim,
                                  BlendMode.srcIn,
                                ),
                                height: 22,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  filteredSettings[i].tital,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textPrim,
                                    fontFamily: 'PoppinsSB',
                                  ),
                                ),
                              ),
                              if (filteredSettings[i].subTital != null)
                                Text(
                                  '${filteredSettings[i].subTital}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textSec,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: textTert,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Bottom Sign In Action ────────────────────────
                const SizedBox(height: 20),
                InkWell(
                  onTap: () => Get.toNamed(Routes.login),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.login_rounded,
                          color: _primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          tr('login_signup'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                            fontFamily: 'PoppinsSB',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
