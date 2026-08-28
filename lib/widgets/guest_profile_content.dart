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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
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
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: isTablet ? 24 : 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                children: [
                  // ── 1. Header (Avatar + User Info) ──────────────────────────
                  if (isTablet)
                    _buildTabletHeader(context)
                  else
                    _buildPhoneHeader(),

                  // ── 2. Sync Prompt Banner ──────────────────────────────────
                  SizedBox(height: isTablet ? 20 : 20),
                  _buildSyncBanner(context, isTablet),

                  // ── 3. Main Content (Dual-column on tablet, Single on phone) ─
                  SizedBox(height: isTablet ? 24 : 24),
                  if (isTablet)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column: Stats
                        Expanded(
                          flex: 5,
                          child: _buildStatsCard(),
                        ),
                        const SizedBox(width: 20),
                        // Right column: Settings + Sign In CTA
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildSettingsList(filteredSettings),
                              const SizedBox(height: 18),
                              _buildBottomSignInButton(),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildStatsCard(),
                    const SizedBox(height: 24),
                    _buildSettingsList(filteredSettings),
                    const SizedBox(height: 20),
                    _buildBottomSignInButton(),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header for Tablet (Landscape card layout) ──────────────────────────────
  Widget _buildTabletHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primary.withValues(alpha: 0.12),
              border: Border.all(color: _primary.withValues(alpha: 0.3), width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 42,
                color: _primary,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tr('guest_user'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textPrim,
                        fontFamily: 'PoppinsSB',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _primary.withValues(alpha: 0.35)),
                      ),
                      child: const Text(
                        'GUEST',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
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
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => Get.toNamed(Routes.login),
            icon: const Icon(Icons.login_rounded, size: 18),
            label: Text(
              tr('login_signup'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'PoppinsSB'),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header for Phone (Centered avatar) ──────────────────────────────────────
  Widget _buildPhoneHeader() {
    return Column(
      children: [
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
      ],
    );
  }

  // ── Sync Banner (Responsive for both Phone & Tablet) ────────────────────────
  Widget _buildSyncBanner(BuildContext context, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 18),
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
      child: isTablet
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.cloud_sync_rounded,
                    color: _secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 3),
                      Text(
                        tr('sync_devices_desc'),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: textSec,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: () => Get.toNamed(Routes.login),
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    tr('sign_in_or_create_account'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ],
            )
          : Column(
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
                    onPressed: () => Get.toNamed(Routes.login),
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
    );
  }

  // ── Watch Time Stats Card ──────────────────────────────────────────────────
  Widget _buildStatsCard() {
    return Container(
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
    );
  }

  // ── Settings Container ─────────────────────────────────────────────────────
  Widget _buildSettingsList(List<ProfileModal> filteredSettings) {
    return Container(
      decoration: BoxDecoration(
        color: elevated,
        borderRadius: BorderRadius.circular(18),
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
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
    );
  }

  // ── Bottom Sign In CTA ─────────────────────────────────────────────────────
  Widget _buildBottomSignInButton() {
    return InkWell(
      onTap: () => Get.toNamed(Routes.login),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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
    );
  }
}
