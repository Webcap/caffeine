// ignore_for_file: unused_local_variable
import 'dart:async';

import 'package:reelriot/preferences/profile_tab_preference.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/provider/sign_in_provider.dart';
import 'package:reelriot/screens/auth_screens/welcome.dart';
import 'package:reelriot/utils/app_images.dart';
import 'package:reelriot/utils/config_api.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const secondary = Color(0xFF7C3AED);
  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgElevatedDark = Color(0x0AFFFFFF);
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = Supabase.instance.client.auth;
  final _supabase = Supabase.instance.client;
  String? uid;
  bool? userAnonymous;
  Map<String, dynamic>? profileData;
  String? month;
  int? year;
  Stream<Map<String, dynamic>?>? _profileStream;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initProfileStream();
    getData();
    
    // Auth listener for basic state (login/logout)
    _authSubscription = _auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn || 
          data.event == AuthChangeEvent.signedOut) {
        _initProfileStream();
        getData();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !context.mounted) return;
      final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
      await refreshConfig(appDep);
      if (!mounted) return;
      final recentPrv = Provider.of<RecentProvider>(context, listen: false);
      await recentPrv.syncFromCloud();
      if (!mounted) return;
      await recentPrv.fetchWatchStatsFromApi();
    });
  }

  void _initProfileStream() {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      setState(() {
        _profileStream = null;
        userAnonymous = user?.isAnonymous ?? true;
      });
      return;
    }

    setState(() {
      userAnonymous = false;
      uid = user.id;
      // Real-time stream from Supabase - the "Gold Standard" for sync
      _profileStream = _supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('id', user.id)
          .limit(1)
          .map((data) {
            if (data.isNotEmpty) {
              debugPrint('[Avatar Sync] 🟢 Received real-time update: profile_id=${data.first['profile_id']}');
              profileData = data.first;
              return data.first;
            }
            debugPrint('[Avatar Sync] ⚠️ Received empty profile update');
            return profileData;
          })
          .handleError((error) {
            debugPrint('[Avatar Sync] ⚠️ Stream error: $error');
            return profileData;
          });
    });
  }

  // Legacy method kept for non-avatar metadata if needed
  Future<void> getData() async {
    final user = _auth.currentUser;
    if (user != null && !user.isAnonymous) {
      try {
        final res = await _supabase.from('profiles').select().eq('id', user.id).limit(1);
        if (res.isNotEmpty && mounted) {
          final data = res[0];
          setState(() {
            profileData = data;
            if (data['joined_at'] != null) {
              try {
                final dt = DateTime.parse(data['joined_at'].toString());
                month = DateFormat('MMMM').format(DateTime(0, dt.month));
                year = dt.year;
              } catch (_) {}
            }
          });
        }
      } catch (e) {
        debugPrint('[ProfilePage] getData failed: $e');
      }
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sp = context.watch<SignInProvider>();
    final recent = context.watch<RecentProvider>();
    final settings = context.watch<SettingsProvider>();
    final appDep = context.watch<AppDependencyProvider>();

    final bg = isDark ? _C.bgCanvasDark : _C.bgCanvasLight;

    if (!sp.isSignedIn) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: CircularProgressIndicator(color: _C.primary),
        ),
      );
    }

    final surface = isDark ? _C.bgSurfaceDark : _C.bgSurfaceLight;
    final elevated = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;
    final textTert = isDark ? _C.textTertDark : _C.textTertLight;

    if (userAnonymous == null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: CircularProgressIndicator(color: _C.primary),
        ),
      );
    }

    if (userAnonymous == true) {
      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tr('current_account_anonymous'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: textSec,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () async {
                      final sp =
                          Provider.of<SignInProvider>(context, listen: false);
                      await sp.userSignOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WelcomeScreen()),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _C.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(tr('login_signup')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _profileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return Scaffold(
            backgroundColor: bg,
            body: Center(
              child: CircularProgressIndicator(color: _C.primary),
            ),
          );
        }
        final data = snapshot.data ??
            profileData ??
            <String, dynamic>{
              'name': sp.name ?? 'ReelRiot User',
              'username': sp.name ?? 'ReelRiot User',
              'profile_id': sp.profileId ?? '0',
              'image_url': sp.imageUrl ?? '',
            };

        final moviesMin = recent.movieWatchTimeMinutesLast2Weeks;
        final tvMin = recent.tvWatchTimeMinutesLast2Weeks;
        final moviesFormatted = recent.formatWatchTime(moviesMin);
        final tvFormatted = recent.formatWatchTime(tvMin);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  children: [
                    // ── Avatar & name ─────────────────────────────────────
                    // Smart resolution: Prioritize DB stream, fallback to Provider metadata
                    Builder(
                      builder: (context) {
                        final authProvider = Provider.of<SignInProvider>(context, listen: false);
                        final dbProfileId = data['profile_id']?.toString();
                        final dbImageUrl = data['image_url']?.toString();
                        
                        // The "Fry" avatar is ID 5. If DB says 0 but Auth says 5, use 5.
                        final metadataId = authProvider.profileId?.toString();
                        final avatarId = (dbProfileId != null && dbProfileId != '0') 
                            ? dbProfileId 
                            : (metadataId ?? '0');
                        
                        debugPrint('[Avatar Sync] 🎯 Final decision: db=$dbProfileId, metadata=$metadataId -> choosing=$avatarId');
                        
                        final imageUrl = (dbImageUrl != null && dbImageUrl.isNotEmpty)
                            ? dbImageUrl
                            : (authProvider.imageUrl ?? '');

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(48),
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 192,
                                  memCacheHeight: 192,
                                  placeholder: (_, __) => const SizedBox(
                                    width: 96,
                                    height: 96,
                                  ),
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 48,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/profiles/$avatarId.png',
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                ),
                        );
                      }
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data['name'] ?? data['username'] ?? 'caffeineUser123',
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
                      '${tr('joined')}: ${month ?? ''} ${year ?? ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: textTert,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          data['email'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSec,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        if (data['verified'] == true)
                          Icon(
                            Icons.verified_rounded,
                            size: 18,
                            color: _C.primary,
                          ),
                      ],
                    ),

                    // ── Premium Banner ────────────────────────────────────
                    if (appDep.displayPremiumBanner) ...[
                      const SizedBox(height: 24),
                      _PremiumBanner(
                        onTap: () => Get.toNamed(Routes.premium),
                        isDark: isDark,
                      ),
                    ],

                    // ── Watch time stats (last 2 weeks) ───────────────────
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: elevated,
                        borderRadius: BorderRadius.circular(16),
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
                                color: _C.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tr('last_2_weeks'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textPrim,
                                  fontFamily: 'PoppinsSB',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _WatchStatCard(
                                  icon: Icons.movie_creation_rounded,
                                  label: tr('movies'),
                                  value: moviesFormatted,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _WatchStatCard(
                                  icon: Icons.live_tv_rounded,
                                  label: tr('tv_series'),
                                  value: tvFormatted,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Settings list ────────────────────────────────────
                    const SizedBox(height: 24),
                    Builder(
                      builder: (context) {
                        final showActivateTv = appDep.isFeatureEnabled('toggle_tv_activate_button', defaultValue: true);
                        final filteredSettings = settingdata.where((item) => showActivateTv || item.tital != tr("pair_tv")).toList();
                        return Container(
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
                        );
                      }
                    ),

                    // ── Logout ───────────────────────────────────────────
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _showSignOutSheet(context, sp),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              MovixIcon.logOut,
                              colorFilter: ColorFilter.mode(
                                _C.primary,
                                BlendMode.srcIn,
                              ),
                              height: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              tr('sign_out'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _C.primary,
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
      },
    );
  }

  void _showSignOutSheet(BuildContext context, SignInProvider sp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? _C.bgSurfaceDark : _C.bgSurfaceLight;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isDark ? _C.textTertDark : _C.textTertLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              tr('sign_out'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _C.primary,
                fontFamily: 'PoppinsSB',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr('want_to_sign_out'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: textPrim,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _C.borderDark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      tr('cancel'),
                      style: TextStyle(
                        color: textPrim,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PoppinsSB',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await sp.userSignOut();
                      Get.back();
                      Get.offNamed(Routes.login);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _C.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      tr('yes_sign_out'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PoppinsSB',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({
    required this.onTap,
    required this.isDark,
  });

  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                : [const Color(0xFF4338CA), const Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFFACC15),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get Reelriot Premium',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ad-free, Live Sports & 24/7 Support',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchStatCard extends StatelessWidget {
  const _WatchStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textTert = isDark ? _C.textTertDark : _C.textTertLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? _C.bgSurfaceDark : _C.bgElevatedLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? _C.borderDark : _C.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: _C.secondary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrim,
              fontFamily: 'PoppinsSB',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textTert,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
