import 'package:reelriot/provider/settings_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reelriot/utils/version_helper.dart';
import 'package:reelriot/utils/flavor_config.dart';

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _Design {
  static const primary = Color(0xFFDC2626);

  static const bgCanvasDark = Color(0xFF030712);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);
  static const iconBgDark = Color(0x14FFFFFF);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF64748B);

  static const radiusMd = 16.0;
  static const screenPadH = 24.0;
  static const space2 = 8.0;
  static const space4 = 16.0;
  static const shadowCard = BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
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
        leading: Padding(
          padding: const EdgeInsets.only(left: _Design.space2),
          child: Material(
            color: isDark ? _Design.iconBgDark : border,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22,
                  color: textPrim,
                ),
              ),
            ),
          ),
        ),
        iconTheme: IconThemeData(color: textPrim),
        title: Text(
          tr("about"),
          style: TextStyle(
            color: textPrim,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: _Design.screenPadH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 28),

            // App icon card
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(_Design.radiusMd),
                border: Border.all(color: border),
                boxShadow: const [_Design.shadowCard],
              ),
              padding: const EdgeInsets.all(_Design.space4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_Design.radiusMd),
                child: Image.asset(
                  appConfig.app_icon,
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Version (from pubspec via tool/version_gen.dart)
            VersionDisplay(
              version: currentAppVersion,
              isVertical: true,
              style: TextStyle(
                color: textPrim,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            if (FlavorConfig.isDev) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'DEVELOPMENT BUILD',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Disclaimer card
            _AboutCard(
              surface: surface,
              border: border,
              child: Text(
                'This app does not host any content on its server',
                maxLines: 5,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSec,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // TMDB endorsement card
            _AboutCard(
              surface: surface,
              border: border,
              child: Column(
                children: [
                  Text(
                    tr("endorsment"),
                    maxLines: 5,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textSec,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      launchUrl(
                        Uri.parse('https://themoviedb.org'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Image.asset(
                      'assets/images/tmdb_logo.png',
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bug notice link
            GestureDetector(
              onTap: () {
                // launchUrl(Uri.parse('https://t.me/'),
                //     mode: LaunchMode.externalApplication);
              },
              child: Text(
                tr("bug_notice"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _Design.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: _Design.primary,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Footer
            Text(
              tr("made_with"),
              textAlign: TextAlign.center,
              style: TextStyle(color: textSec, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              tr("made_in"),
              style: TextStyle(color: textSec, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              tr("year_range", namedArgs: {"startYear": "2016"}),
              style: TextStyle(color: textSec, fontSize: 14),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final Color surface;
  final Color border;
  final Widget child;

  const _AboutCard({
    required this.surface,
    required this.border,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(_Design.radiusMd),
        border: Border.all(color: border),
        boxShadow: const [_Design.shadowCard],
      ),
      padding: const EdgeInsets.all(_Design.space4),
      child: child,
    );
  }
}
