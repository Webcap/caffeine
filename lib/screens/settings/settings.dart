import 'dart:io';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/models/app_languages.dart';
import 'package:reelriot/models/watchprovider_countries.dart';
import 'package:reelriot/screens/common/country_choose.dart';
import 'package:reelriot/screens/settings/player_settings.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:reelriot/widgets/styled_dropdown.dart';
import 'package:reelriot/widgets/styled_switch.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _Design {
  static const primary = Color(0xFFDC2626);
  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textSecDark = Color(0xB8FFFFFF);
  static const borderDark = Color(0x14FFFFFF);
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

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? countryFlag;
  String? countryName;
  String? languageFlag;
  String? languageName;
  bool isBelow33 = true;

  void androidVersionCheck() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        if (mounted) setState(() => isBelow33 = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    androidVersionCheck();
  }

  List<AppLanguages> get _langs => [
        AppLanguages(
            languageFlag: 'assets/images/country_flags/united-kingdom.png',
            languageName: tr("english"),
            languageCode: 'en'),
        AppLanguages(
            languageFlag: 'assets/images/country_flags/spain.png',
            languageName: tr("spanish"),
            languageCode: 'es'),
      ];

  List<WatchProviderCountries> get _countries => [
        WatchProviderCountries(
            countryName: tr("uae"),
            flagPath: 'assets/images/country_flags/united-arab-emirates.png',
            isoCode: 'AE'),
        WatchProviderCountries(
            countryName: tr("argentina"),
            flagPath: 'assets/images/country_flags/argentina.png',
            isoCode: 'AR'),
        WatchProviderCountries(
            countryName: tr("austria"),
            flagPath: 'assets/images/country_flags/austria.png',
            isoCode: 'AT'),
        WatchProviderCountries(
            countryName: tr("australia"),
            flagPath: 'assets/images/country_flags/australia.png',
            isoCode: 'AU'),
        WatchProviderCountries(
            countryName: tr("belgium"),
            flagPath: 'assets/images/country_flags/belgium.png',
            isoCode: 'BE'),
        WatchProviderCountries(
            countryName: tr("bulgaria"),
            flagPath: 'assets/images/country_flags/bulgaria.png',
            isoCode: 'BG'),
        WatchProviderCountries(
            countryName: tr("brazil"),
            flagPath: 'assets/images/country_flags/brazil.png',
            isoCode: 'BR'),
        WatchProviderCountries(
            countryName: tr("canada"),
            flagPath: 'assets/images/country_flags/canada.png',
            isoCode: 'CA'),
        WatchProviderCountries(
            countryName: tr("switzerland"),
            flagPath: 'assets/images/country_flags/switzerland.png',
            isoCode: 'CH'),
        WatchProviderCountries(
            countryName: tr("cote_divoire"),
            flagPath: 'assets/images/country_flags/ivory-coast.png',
            isoCode: 'CI'),
        WatchProviderCountries(
            countryName: tr("czech_republic"),
            flagPath: 'assets/images/country_flags/czech-republic.png',
            isoCode: 'CZ'),
        WatchProviderCountries(
            countryName: tr("germany"),
            flagPath: 'assets/images/country_flags/germany.png',
            isoCode: 'DE'),
        WatchProviderCountries(
            countryName: tr("denmark"),
            flagPath: 'assets/images/country_flags/denmark.png',
            isoCode: 'DK'),
        WatchProviderCountries(
            countryName: tr("estonia"),
            flagPath: 'assets/images/country_flags/estonia.png',
            isoCode: 'EE'),
        WatchProviderCountries(
            countryName: tr("spain"),
            flagPath: 'assets/images/country_flags/spain.png',
            isoCode: 'ES'),
        WatchProviderCountries(
            countryName: tr("finland"),
            flagPath: 'assets/images/country_flags/finland.png',
            isoCode: 'FI'),
        WatchProviderCountries(
            countryName: tr("france"),
            flagPath: 'assets/images/country_flags/france.png',
            isoCode: 'FR'),
        WatchProviderCountries(
            countryName: tr("uk"),
            flagPath: 'assets/images/country_flags/united-kingdom.png',
            isoCode: 'GB'),
        WatchProviderCountries(
            countryName: tr("hong_kong"),
            flagPath: 'assets/images/country_flags/hong-kong.png',
            isoCode: 'HK'),
        WatchProviderCountries(
            countryName: tr("croatia"),
            flagPath: 'assets/images/country_flags/croatia.png',
            isoCode: 'HR'),
        WatchProviderCountries(
            countryName: tr("hungary"),
            flagPath: 'assets/images/country_flags/hungary.png',
            isoCode: 'HU'),
        WatchProviderCountries(
            countryName: tr("indonesia"),
            flagPath: 'assets/images/country_flags/indonesia.png',
            isoCode: 'ID'),
        WatchProviderCountries(
            countryName: tr("ireland"),
            flagPath: 'assets/images/country_flags/ireland.png',
            isoCode: 'IE'),
        WatchProviderCountries(
            countryName: tr("india"),
            flagPath: 'assets/images/country_flags/india.png',
            isoCode: 'IN'),
        WatchProviderCountries(
            countryName: tr("italy"),
            flagPath: 'assets/images/country_flags/italy.png',
            isoCode: 'IT'),
        WatchProviderCountries(
            countryName: tr("japan"),
            flagPath: 'assets/images/country_flags/japan.png',
            isoCode: 'JP'),
        WatchProviderCountries(
            countryName: tr("kenya"),
            flagPath: 'assets/images/country_flags/kenya.png',
            isoCode: 'KE'),
        WatchProviderCountries(
            countryName: tr("south_korea"),
            flagPath: 'assets/images/country_flags/south-korea.png',
            isoCode: 'KR'),
        WatchProviderCountries(
            countryName: tr("lithuania"),
            flagPath: 'assets/images/country_flags/lithuania.png',
            isoCode: 'LT'),
        WatchProviderCountries(
            countryName: tr("mexico"),
            flagPath: 'assets/images/country_flags/mexico.png',
            isoCode: 'MX'),
        WatchProviderCountries(
            countryName: tr("netherlands"),
            flagPath: 'assets/images/country_flags/netherlands.png',
            isoCode: 'NL'),
        WatchProviderCountries(
            countryName: tr("norway"),
            flagPath: 'assets/images/country_flags/norway.png',
            isoCode: 'NO'),
        WatchProviderCountries(
            countryName: tr("new_zealand"),
            flagPath: 'assets/images/country_flags/new-zealand.png',
            isoCode: 'NZ'),
        WatchProviderCountries(
            countryName: tr("philippines"),
            flagPath: 'assets/images/country_flags/philippines.png',
            isoCode: 'PH'),
        WatchProviderCountries(
            countryName: tr("poland"),
            flagPath: 'assets/images/country_flags/poland.png',
            isoCode: 'PL'),
        WatchProviderCountries(
            countryName: tr("portugal"),
            flagPath: 'assets/images/country_flags/portugal.png',
            isoCode: 'PT'),
        WatchProviderCountries(
            countryName: tr("serbia"),
            flagPath: 'assets/images/country_flags/serbia.png',
            isoCode: 'RS'),
        WatchProviderCountries(
            countryName: tr("russia"),
            flagPath: 'assets/images/country_flags/russia.png',
            isoCode: 'RU'),
        WatchProviderCountries(
            countryName: tr("sweden"),
            flagPath: 'assets/images/country_flags/sweden.png',
            isoCode: 'SE'),
        WatchProviderCountries(
            countryName: tr("slovakia"),
            flagPath: 'assets/images/country_flags/slovakia.png',
            isoCode: 'SK'),
        WatchProviderCountries(
            countryName: tr("turkey"),
            flagPath: 'assets/images/country_flags/turkey.png',
            isoCode: 'TR'),
        WatchProviderCountries(
            countryName: tr("usa"),
            flagPath: 'assets/images/country_flags/united-states.png',
            isoCode: 'US'),
        WatchProviderCountries(
            countryName: tr("south_africa"),
            flagPath: 'assets/images/country_flags/south-africa.png',
            isoCode: 'ZA'),
      ];

  void _syncCountryLang(SettingsProvider sv) {
    for (final c in _countries) {
      if (c.isoCode == sv.defaultCountry) {
        countryFlag = c.flagPath;
        countryName = c.countryName;
        break;
      }
    }
    for (final l in _langs) {
      if (l.languageCode == sv.appLanguage) {
        languageFlag = l.languageFlag;
        languageName = l.languageName;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sv = context.watch<SettingsProvider>();
    _syncCountryLang(sv);

    final themeMode = sv.appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final bg = isDark ? _Design.bgCanvasDark : _Design.bgCanvasLight;
    final surface = isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight;
    final textPrim = isDark ? _Design.textPrimDark : _Design.textPrimLight;
    final textSec = isDark ? _Design.textSecDark : _Design.textSecLight;
    final border = isDark ? _Design.borderDark : _Design.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        title: Text(
          tr("settings"),
          style: TextStyle(
            color: textPrim,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: _Design.screenPadH,
          vertical: _Design.space4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsCard(
              surface: surface,
              border: border,
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: tr("theme_mode"),
                  textPrim: textPrim,
                  textSec: textSec,
                  trailing: StyledDropdown<String>(
                    value: sv.appTheme,
                    items: const ['dark', 'light', 'amoled'],
                    labels: [tr("dark"), tr("light"), tr("amoled")],
                    onChanged: (v) => setState(() => sv.appTheme = v!),
                    textPrim: textPrim,
                    textSec: textSec,
                  ),
                ),
// Material 3 option removed
                const _Divider(),
              ],
            ),
            const SizedBox(height: _Design.space4),
            _SettingsCard(
              surface: surface,
              border: border,
              children: [
                _SettingsTile(
                  icon: Icons.play_arrow_rounded,
                  title: tr("player_settings"),
                  textPrim: textPrim,
                  textSec: textSec,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlayerSettings()),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: textSec, size: 22),
                ),
                const _Divider(),
                _SettingsTile(
                  icon: FontAwesomeIcons.networkWired,
                  title: tr("use_proxy"),
                  subtitle: tr("enable_warning"),
                  textPrim: textPrim,
                  textSec: textSec,
                  trailing: StyledSwitch(
                    value: sv.enableProxy,
                    onChanged: (v) => _onProxyChanged(sv, v),
                    activeColor: _Design.primary,
                    textSec: textSec,
                  ),
                ),
                const _Divider(),
                _SettingsTile(
                  icon: Icons.image_rounded,
                  title: tr("image_quality"),
                  textPrim: textPrim,
                  textSec: textSec,
                  trailing: StyledDropdown<String>(
                    value: sv.imageQuality,
                    items: const [
                      'original/',
                      'w600_and_h900_bestv2/',
                      'w500/'
                    ],
                    labels: [tr("high"), tr("medium"), tr("low")],
                    onChanged: (v) => setState(() => sv.imageQuality = v!),
                    textPrim: textPrim,
                    textSec: textSec,
                  ),
                ),
                const _Divider(),
                _SettingsTile(
                  icon: Icons.view_list_rounded,
                  title: tr("list_view_type"),
                  textPrim: textPrim,
                  textSec: textSec,
                  trailing: StyledDropdown<String>(
                    value: sv.defaultView,
                    items: const ['list', 'grid'],
                    labels: [tr("list"), tr("grid")],
                    onChanged: (v) => setState(() => sv.defaultView = v!),
                    textPrim: textPrim,
                    textSec: textSec,
                  ),
                ),
                const _Divider(),
                _SettingsTile(
                  icon: Icons.phone_android_rounded,
                  title: tr("default_home_screen"),
                  textPrim: textPrim,
                  textSec: textSec,
                  trailing: StyledDropdown<int>(
                    value: sv.defaultValue,
                    items: const [0, 1, 2, 3],
                    labels: [
                      tr("movies"),
                      tr("tv_shows"),
                      tr("discover"),
                      tr("profile")
                    ],
                    onChanged: (v) => setState(() => sv.defaultValue = v!),
                    textPrim: textPrim,
                    textSec: textSec,
                  ),
                ),
              ],
            ),
            const SizedBox(height: _Design.space4),
            _SettingsCard(
              surface: surface,
              border: border,
              children: [
                _SettingsTile(
                  icon: FontAwesomeIcons.language,
                  title: tr("app_language"),
                  textPrim: textPrim,
                  textSec: textSec,
                  trailing: StyledDropdown<String>(
                    value: sv.appLanguage,
                    items: _langs.map((l) => l.languageCode).toList(),
                    labels: _langs.map((l) => l.languageName).toList(),
                    textPrim: textPrim,
                    textSec: textSec,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          sv.appLanguage = v;
                          context.setLocale(Locale(v));
                        });
                      }
                    },
                  ),
                ),
                const _Divider(),
                _SettingsTile(
                  icon: FontAwesomeIcons.earthAmericas,
                  title: tr("watch_country"),
                  textPrim: textPrim,
                  textSec: textSec,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CountryChoose()),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (countryFlag != null)
                        Image.asset(countryFlag!, height: 22, width: 22),
                      const SizedBox(width: _Design.space2),
                      Text(countryName ?? '',
                          style: TextStyle(color: textSec, fontSize: 14)),
                      const SizedBox(width: _Design.space2),
                      Icon(Icons.chevron_right_rounded,
                          color: textSec, size: 22),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: _Design.space4),
            _SettingsCard(
              surface: surface,
              border: border,
              children: [
                _SettingsTile(
                  icon: Icons.tv_rounded,
                  title: tr("pair_tv"),
                  subtitle: tr("pair_tv_subtitle"),
                  textPrim: textPrim,
                  textSec: textSec,
                  onTap: () => Get.toNamed(Routes.pairTv),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: textSec, size: 22),
                ),
                const _Divider(),
                _SettingsTile(
                  icon: FontAwesomeIcons.eraser,
                  title: tr("clear_cache"),
                  textPrim: textPrim,
                  textSec: textSec,
                  trailing: Material(
                    color: _Design.primary,
                    borderRadius: BorderRadius.circular(9999),
                    child: InkWell(
                      onTap: () async {
                        await clearCache().then((v) =>
                            GlobalMethods.showCustomScaffoldMessage(
                                SnackBar(
                                    duration:
                                        const Duration(milliseconds: 1500),
                                    content: Text(v
                                        ? tr("cleared_cache")
                                        : tr("cache_doesnt_exist"))),
                                context));
                        await clearTempCache().then((v) =>
                            GlobalMethods.showCustomScaffoldMessage(
                                SnackBar(
                                    duration:
                                        const Duration(milliseconds: 1500),
                                    content: Text(v
                                        ? tr("cleared_cache")
                                        : tr("cache_doesnt_exist"))),
                                context));
                      },
                      borderRadius: BorderRadius.circular(9999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: _Design.space4,
                            vertical: _Design.space2),
                        child: Text(
                          tr("clear"),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: _Design.space6),
          ],
        ),
      ),
    );
  }

  void _onProxyChanged(SettingsProvider sv, bool value) {
    if (value) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr("use_proxy_title")),
          content: Text(tr("use_proxy_detail")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr("cancel")),
            ),
            TextButton(
              onPressed: () {
                setState(() => sv.enableProxy = value);
                Navigator.pop(ctx);
              },
              child: Text(tr("enable")),
            ),
          ],
        ),
      );
    } else {
      setState(() => sv.enableProxy = value);
    }
  }
}

class _SettingsCard extends StatelessWidget {
  final Color surface;
  final Color border;
  final List<Widget> children;

  const _SettingsCard({
    required this.surface,
    required this.border,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(_Design.radiusMd),
        border: Border.all(color: border),
        boxShadow: const [_Design.shadowCard],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 56);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget trailing;
  final Color textPrim;
  final Color textSec;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.trailing,
    required this.textPrim,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: _Design.space4, vertical: _Design.space3),
      child: Row(
        children: [
          Icon(icon, size: 22, color: _Design.primary),
          const SizedBox(width: _Design.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: textPrim,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(color: textSec, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_Design.radiusMd),
          child: child,
        ),
      );
    }
    return child;
  }
}

// End of settings.dart
