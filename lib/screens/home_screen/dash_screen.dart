import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/bookmarks_provider.dart';
import 'package:reelriot/provider/sign_in_provider.dart';
import 'package:reelriot/screens/common/update_screen.dart';
import 'package:reelriot/screens/profile/profile_page.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/config_api.dart';
import 'package:reelriot/utils/version_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reelriot/provider/settings_provider.dart';

import 'package:reelriot/screens/movie_screens/main_movie_display.dart';
import 'package:reelriot/screens/search/search_view.dart' show SearchPage;
import 'package:reelriot/screens/tv_screens/tv_screen.dart';
import 'package:reelriot/widgets/drawer_widget.dart';
import 'package:provider/provider.dart';

// ─── Design token constants (mirrors design.json) ────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const primaryLight = Color(0xFFEF4444);
  static const secondary = Color(0xFF7C3AED);

  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceLight = Color(0xFFFFFFFF);

  static const tabBarDark = Color(0xE0111827);
  static const tabBarLight = Color(0xEBFFFFFF);

  static const iconBgDark = Color(0x14FFFFFF);
  static const iconBgLight = Color(0x140F172A);

  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);

  static const inactiveDark = Color(0x80FFFFFF);
  static const inactiveLight = Color(0xFF64748B);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
}

// ─── Shell ───────────────────────────────────────────────────────────────────

class CaffieneHomePage extends StatefulWidget {
  const CaffieneHomePage({super.key});

  @override
  State<CaffieneHomePage> createState() => _CaffieneHomePageState();
}

class _CaffieneHomePageState extends State<CaffieneHomePage> {
  late int selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<_TabMeta> _tabs = [
    _TabMeta(icon: Icons.movie_creation_rounded, label: 'Movies'),
    _TabMeta(icon: Icons.tv_rounded, label: 'TV'),
    _TabMeta(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    defHome();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForcedUpdate();
      Provider.of<BookmarksProvider>(context, listen: false).syncIfNeeded();
    });
    super.initState();
  }

  void defHome() {
    final defaultHome =
        Provider.of<SettingsProvider>(context, listen: false).defaultValue;
    setState(() => selectedIndex = defaultHome >= _tabs.length ? 0 : defaultHome);
  }

  Future<void> checkForcedUpdate() async {
    if (!mounted) return;
    final provider = Provider.of<AppDependencyProvider>(context, listen: false);
    try {
      final info = await fetchUpdateInfoFromApi(provider);
      if (!mounted) return;
      if (info.forcedUpdate &&
          isUpdateAvailable(currentAppVersion, info.latestVersion)) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpdateScreen(isForced: true)),
        );
      }
    } catch (_) {
      // Keep app usable if config fetch fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.appLanguage;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark ? _C.bgCanvasDark : _C.bgSurfaceLight,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: isDark ? _C.bgCanvasDark : _C.bgCanvasLight,
        drawer: Drawer(
          backgroundColor: isDark ? _C.bgSurfaceDark : _C.bgSurfaceLight,
          child: const DrawerWidget(),
        ),

        // ── Cinematic AppBar ────────────────────────────────────────────────
        appBar: _HomeAppBar(
          isDark: isDark,
          selectedIndex: selectedIndex,
          scaffoldKey: _scaffoldKey,
          onSearchTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchPage(
                includeAdult: settings.isAdult,
                lang: lang,
              ),
            ),
          ),
        ),

        // ── Cinematic Bottom Tab Bar ────────────────────────────────────────
        bottomNavigationBar: _CinematicTabBar(
          tabs: _tabs,
          selectedIndex: selectedIndex,
          isDark: isDark,
          onTabChange: (i) => setState(() => selectedIndex = i),
        ),

        body: IndexedStack(
          index: selectedIndex,
          children: const <Widget>[
            MainMoviesDisplay(),
            MainTVDisplay(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}

// ─── Smart AppBar — greeting on Movies tab, wordmark elsewhere ───────────

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final int selectedIndex;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback onSearchTap;

  const _HomeAppBar({
    required this.isDark,
    required this.selectedIndex,
    required this.scaffoldKey,
    required this.onSearchTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // Show personalized greeting only on the Movies tab (index 0)
    final showGreeting = selectedIndex == 0;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? _C.bgCanvasDark : _C.bgCanvasLight,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: showGreeting
          ? _GreetingTitle(isDark: isDark, scaffoldKey: scaffoldKey)
          : Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.notes_rounded,
                    isDark: isDark,
                    onTap: () => scaffoldKey.currentState?.openDrawer(),
                  ),
                  const Spacer(),
                  _GradientWordmark(isDark: isDark),
                  const Spacer(),
                ],
              ),
            ),
      actions: [
        _CircleIconButton(
          icon: Icons.search_rounded,
          isDark: isDark,
          onTap: onSearchTap,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ─── Personalized greeting row ───────────────────────────────────────────────

class _GreetingTitle extends StatelessWidget {
  final bool isDark;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _GreetingTitle({
    required this.isDark,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final signIn = context.watch<SignInProvider>();
    final displayName = signIn.username ?? signIn.name ?? 'Guest';
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textSec = isDark ? const Color(0xB8FFFFFF) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          // Avatar / drawer opener
          GestureDetector(
            onTap: () => scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.primary.withValues(alpha: 0.15),
                border: Border.all(
                  color: _C.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: _buildAvatar(signIn),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Greeting text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Hi Welcome',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSec,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('👋', style: TextStyle(fontSize: 12)),
                ],
              ),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrim,
                  fontFamily: 'PoppinsSB',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Mirrors the avatar resolution in ProfilePage:
  ///   1. OAuth / external image_url  → CachedNetworkImage
  ///   2. Numeric profileId           → assets/images/profiles/{id}.png
  ///   3. Fallback                    → generic icon
  Widget _buildAvatar(SignInProvider signIn) {
    final imageUrl = signIn.imageUrl ?? '';
    if (imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        memCacheWidth: 84,
        memCacheHeight: 84,
        placeholder: (_, __) => _AvatarFallback(),
        errorWidget: (_, __, ___) => _AvatarFallback(),
      );
    }

    // Use the numeric profile avatar chosen by the user in edit_profile
    final profileId = signIn.profileId;
    if (profileId != null && profileId != 0) {
      return Image.asset(
        'assets/images/profiles/$profileId.png',
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _AvatarFallback(),
      );
    }

    return _AvatarFallback();
  }
}

class _AvatarFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.primary.withValues(alpha: 0.2),
      child: const Icon(Icons.person_rounded, color: _C.primary, size: 22),
    );
  }
}

// ─── Brand wordmark with crimson↔violet gradient ──────────────────────────

class _GradientWordmark extends StatelessWidget {
  final bool isDark;
  const _GradientWordmark({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [_C.secondary, _C.primaryLight],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: const Text(
        'Reelriot',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: Colors.white,
          fontFamily: 'PoppinsSB',
        ),
      ),
    );
  }
}

// ─── Translucent circular icon button (design.json: topOverlayControls) ───

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _CircleIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? _C.iconBgDark : _C.iconBgLight,
              border: Border.all(
                color: isDark ? _C.borderDark : _C.borderLight,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isDark ? _C.textPrimDark : _C.textPrimLight,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Metadata struct for a tab ────────────────────────────────────────────

class _TabMeta {
  final IconData icon;
  final String label;
  const _TabMeta({required this.icon, required this.label});
}

// ─── Cinematic tab bar (design.json: bottomTabBar) ────────────────────────

class _CinematicTabBar extends StatelessWidget {
  final List<_TabMeta> tabs;
  final int selectedIndex;
  final bool isDark;
  final ValueChanged<int> onTabChange;

  const _CinematicTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.isDark,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _C.tabBarDark : _C.tabBarLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? _C.borderDark : _C.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(tabs.length, (i) {
                  return _TabButton(
                    meta: tabs[i],
                    isActive: i == selectedIndex,
                    isDark: isDark,
                    onTap: () => onTabChange(i),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Individual tab button ────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final _TabMeta meta;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _TabButton({
    required this.meta,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark ? _C.inactiveDark : _C.inactiveLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 9)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isActive
              ? _C.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              meta.icon,
              size: 18,
              color: isActive ? _C.primary : inactiveColor,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              child: isActive
                  ? Row(
                      children: [
                        const SizedBox(width: 7),
                        Text(
                          meta.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _C.primary,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
