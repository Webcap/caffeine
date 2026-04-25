import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/models/watchprovider_countries.dart';
import 'package:reelriot/provider/settings_provider.dart';
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

class CountryChoose extends StatefulWidget {
  const CountryChoose({super.key});

  @override
  State<CountryChoose> createState() => _CountryChooseState();
}

class _CountryChooseState extends State<CountryChoose> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<WatchProviderCountries> countries = [
    WatchProviderCountries(
      countryName: tr("uae"),
      flagPath: 'assets/images/country_flags/united-arab-emirates.png',
      isoCode: 'AE',
    ),
    WatchProviderCountries(
      countryName: tr("argentina"),
      flagPath: 'assets/images/country_flags/argentina.png',
      isoCode: 'AR',
    ),
    WatchProviderCountries(
      countryName: tr("austria"),
      flagPath: 'assets/images/country_flags/austria.png',
      isoCode: 'AT',
    ),
    WatchProviderCountries(
      countryName: tr("australia"),
      flagPath: 'assets/images/country_flags/australia.png',
      isoCode: 'AU',
    ),
    WatchProviderCountries(
      countryName: tr("belgium"),
      flagPath: 'assets/images/country_flags/belgium.png',
      isoCode: 'BE',
    ),
    WatchProviderCountries(
      countryName: tr("bulgaria"),
      flagPath: 'assets/images/country_flags/bulgaria.png',
      isoCode: 'BG',
    ),
    WatchProviderCountries(
      countryName: tr("brazil"),
      flagPath: 'assets/images/country_flags/brazil.png',
      isoCode: 'BR',
    ),
    WatchProviderCountries(
      countryName: tr("canada"),
      flagPath: 'assets/images/country_flags/canada.png',
      isoCode: 'CA',
    ),
    WatchProviderCountries(
      countryName: tr("switzerland"),
      flagPath: 'assets/images/country_flags/switzerland.png',
      isoCode: 'CH',
    ),
    WatchProviderCountries(
      countryName: tr("cote_divoire"),
      flagPath: 'assets/images/country_flags/ivory-coast.png',
      isoCode: 'CI',
    ),
    WatchProviderCountries(
      countryName: tr("czech_republic"),
      flagPath: 'assets/images/country_flags/czech-republic.png',
      isoCode: 'CZ',
    ),
    WatchProviderCountries(
      countryName: tr("germany"),
      flagPath: 'assets/images/country_flags/germany.png',
      isoCode: 'DE',
    ),
    WatchProviderCountries(
      countryName: tr("denmark"),
      flagPath: 'assets/images/country_flags/denmark.png',
      isoCode: 'DK',
    ),
    WatchProviderCountries(
      countryName: tr("estonia"),
      flagPath: 'assets/images/country_flags/estonia.png',
      isoCode: 'EE',
    ),
    WatchProviderCountries(
      countryName: tr("spain"),
      flagPath: 'assets/images/country_flags/spain.png',
      isoCode: 'ES',
    ),
    WatchProviderCountries(
      countryName: tr("finland"),
      flagPath: 'assets/images/country_flags/finland.png',
      isoCode: 'FI',
    ),
    WatchProviderCountries(
      countryName: tr("france"),
      flagPath: 'assets/images/country_flags/france.png',
      isoCode: 'FR',
    ),
    WatchProviderCountries(
      countryName: tr("uk"),
      flagPath: 'assets/images/country_flags/united-kingdom.png',
      isoCode: 'GB',
    ),
    WatchProviderCountries(
      countryName: tr("hong_kong"),
      flagPath: 'assets/images/country_flags/hong-kong.png',
      isoCode: 'HK',
    ),
    WatchProviderCountries(
      countryName: tr("croatia"),
      flagPath: 'assets/images/country_flags/croatia.png',
      isoCode: 'HR',
    ),
    WatchProviderCountries(
      countryName: tr("hungary"),
      flagPath: 'assets/images/country_flags/hungary.png',
      isoCode: 'HU',
    ),
    WatchProviderCountries(
      countryName: tr("indonesia"),
      flagPath: 'assets/images/country_flags/indonesia.png',
      isoCode: 'ID',
    ),
    WatchProviderCountries(
      countryName: tr("ireland"),
      flagPath: 'assets/images/country_flags/ireland.png',
      isoCode: 'IE',
    ),
    WatchProviderCountries(
      countryName: tr("india"),
      flagPath: 'assets/images/country_flags/india.png',
      isoCode: 'IN',
    ),
    WatchProviderCountries(
      countryName: tr("italy"),
      flagPath: 'assets/images/country_flags/italy.png',
      isoCode: 'IT',
    ),
    WatchProviderCountries(
      countryName: tr("japan"),
      flagPath: 'assets/images/country_flags/japan.png',
      isoCode: 'JP',
    ),
    WatchProviderCountries(
      countryName: tr("kenya"),
      flagPath: 'assets/images/country_flags/kenya.png',
      isoCode: 'KE',
    ),
    WatchProviderCountries(
      countryName: tr("south_korea"),
      flagPath: 'assets/images/country_flags/south-korea.png',
      isoCode: 'KR',
    ),
    WatchProviderCountries(
      countryName: tr("lithuania"),
      flagPath: 'assets/images/country_flags/lithuania.png',
      isoCode: 'LT',
    ),
    WatchProviderCountries(
      countryName: tr("mexico"),
      flagPath: 'assets/images/country_flags/mexico.png',
      isoCode: 'MX',
    ),
    WatchProviderCountries(
      countryName: tr("netherlands"),
      flagPath: 'assets/images/country_flags/netherlands.png',
      isoCode: 'NL',
    ),
    WatchProviderCountries(
      countryName: tr("norway"),
      flagPath: 'assets/images/country_flags/norway.png',
      isoCode: 'NO',
    ),
    WatchProviderCountries(
      countryName: tr("new_zealand"),
      flagPath: 'assets/images/country_flags/new-zealand.png',
      isoCode: 'NZ',
    ),
    WatchProviderCountries(
      countryName: tr("philippines"),
      flagPath: 'assets/images/country_flags/philippines.png',
      isoCode: 'PH',
    ),
    WatchProviderCountries(
      countryName: tr("poland"),
      flagPath: 'assets/images/country_flags/poland.png',
      isoCode: 'PL',
    ),
    WatchProviderCountries(
      countryName: tr("portugal"),
      flagPath: 'assets/images/country_flags/portugal.png',
      isoCode: 'PT',
    ),
    WatchProviderCountries(
      countryName: tr("serbia"),
      flagPath: 'assets/images/country_flags/serbia.png',
      isoCode: 'RS',
    ),
    WatchProviderCountries(
      countryName: tr("russia"),
      flagPath: 'assets/images/country_flags/russia.png',
      isoCode: 'RU',
    ),
    WatchProviderCountries(
      countryName: tr("sweden"),
      flagPath: 'assets/images/country_flags/sweden.png',
      isoCode: 'SE',
    ),
    WatchProviderCountries(
      countryName: tr("slovakia"),
      flagPath: 'assets/images/country_flags/slovakia.png',
      isoCode: 'SK',
    ),
    WatchProviderCountries(
      countryName: tr("turkey"),
      flagPath: 'assets/images/country_flags/turkey.png',
      isoCode: 'TR',
    ),
    WatchProviderCountries(
      countryName: tr("usa"),
      flagPath: 'assets/images/country_flags/united-states.png',
      isoCode: 'US',
    ),
    WatchProviderCountries(
      countryName: tr("south_africa"),
      flagPath: 'assets/images/country_flags/south-africa.png',
      isoCode: 'ZA',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sv = context.watch<SettingsProvider>();
    final themeMode = sv.appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final bg = isDark ? _Design.bgCanvasDark : _Design.bgCanvasLight;
    final surface = isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight;
    final textPrim = isDark ? _Design.textPrimDark : _Design.textPrimLight;
    final textSec = isDark ? _Design.textSecDark : _Design.textSecLight;
    final border = isDark ? _Design.borderDark : _Design.borderLight;

    List<WatchProviderCountries> filtered = countries
        .where((c) => c.countryName.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    filtered.sort((a, b) => a.countryName.compareTo(b.countryName));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        title: Text(
          tr("choose_country"),
          style: TextStyle(
            color: textPrim,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(_Design.screenPadH),
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
                boxShadow: const [_Design.shadowCard],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(color: textPrim),
                decoration: InputDecoration(
                  hintText: tr("search_country"),
                  hintStyle: TextStyle(color: textSec, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: textSec),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: _Design.screenPadH,
                vertical: _Design.space2,
              ),
              child: _SettingsCard(
                surface: surface,
                border: border,
                children: filtered
                    .asMap()
                    .entries
                    .map((entry) {
                      final i = entry.key;
                      final c = entry.value;
                      final isSelected = sv.defaultCountry == c.isoCode;
                      return Column(
                        children: [
                          _SettingsTile(
                            flagPath: c.flagPath,
                            title: c.countryName,
                            textPrim: textPrim,
                            textSec: textSec,
                            isSelected: isSelected,
                            onTap: () => setState(() => sv.defaultCountry = c.isoCode),
                          ),
                          if (i < filtered.length - 1)
                            const Divider(height: 1, indent: 56),
                        ],
                      );
                    })
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
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

class _SettingsTile extends StatelessWidget {
  final String flagPath;
  final String title;
  final Color textPrim;
  final Color textSec;
  final bool isSelected;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.flagPath,
    required this.title,
    required this.textPrim,
    required this.textSec,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_Design.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: _Design.space4, vertical: _Design.space3),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(flagPath, height: 24, width: 24, fit: BoxFit.cover),
              ),
              const SizedBox(width: _Design.space3),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      color: textPrim,
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: _Design.primary, size: 22)
              else
                Icon(Icons.circle_outlined, color: textSec.withValues(alpha: 0.3), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
