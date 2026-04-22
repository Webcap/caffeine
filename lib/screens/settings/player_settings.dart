import 'package:reelriot/models/sub_languages.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:reelriot/widgets/styled_dropdown.dart';
import 'package:reelriot/widgets/styled_switch.dart';
import '/provider/settings_provider.dart';

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _Design {
  static const primary = Color(0xFFDC2626);
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

class PlayerSettings extends StatefulWidget {
  const PlayerSettings({super.key});

  @override
  State<PlayerSettings> createState() => _PlayerSettingsState();
}

class _PlayerSettingsState extends State<PlayerSettings> {
  void _colorPickerDialog(
      BuildContext context, int type, Color currentColor, SettingsProvider sv) {
    Color pickerColor = currentColor;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => pickerColor = color,
              hexInputBar: true,
              enableAlpha: true,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(tr("cancel")),
            ),
            FilledButton(
              onPressed: () {
                if (type == 1) {
                  sv.subtitleForegroundColor = pickerColor.toString();
                } else {
                  sv.subtitleBackgroundColor = pickerColor.toString();
                }
                Navigator.of(ctx).pop();
                setState(() {});
              },
              child: Text(tr("save")),
            ),
          ],
        );
      },
    );
  }

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

    final bgColor = _parseColor(sv.subtitleBackgroundColor);
    final fgColor = _parseColor(sv.subtitleForegroundColor);
    final st = sv.subtitleTextStyle;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        leading: Padding(
          padding: const EdgeInsets.only(left: _Design.space2),
          child: _CircleBackButton(
            onTap: () => Navigator.pop(context),
            iconColor: textPrim,
            bgColor: isDark ? _Design.iconBgDark : border,
          ),
        ),
        title: Text(
          tr("player_settings"),
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
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Subtitle section ───────────────────────────────────────────
            Row(
              children: [
                const LeadingDot(),
                Text(
                  tr("subtitle"),
                  style: TextStyle(
                    color: textPrim,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: _Design.space3),
            _Card(
              surface: surface,
              border: border,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(_Design.radiusMd - 4),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        Image.asset('assets/images/sample_frame.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 220),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            tr("sample_player_text"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              backgroundColor: bgColor,
                              color: fgColor,
                              fontFamily: st == 'regular'
                                  ? 'Poppins'
                                  : st == 'bold'
                                      ? 'PoppinsSB'
                                      : 'PoppinsLight',
                              fontSize: sv.subtitleFontSize.toDouble(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(_Design.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr("text_size"),
                                style: TextStyle(
                                    color: textPrim,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                            Text('${sv.subtitleFontSize}',
                                style: TextStyle(color: textSec, fontSize: 14)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: _Design.primary,
                            thumbColor: _Design.primary,
                            overlayColor: _Design.primary.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: sv.subtitleFontSize.toDouble(),
                            onChanged: (v) =>
                                setState(() => sv.subtitleFontSize = v.toInt()),
                            min: 5,
                            max: 30,
                          ),
                        ),
                        const SizedBox(height: _Design.space2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr("text_color"),
                                style: TextStyle(
                                    color: textPrim,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                            GestureDetector(
                              onTap: () =>
                                  _colorPickerDialog(context, 1, fgColor, sv),
                              child: Container(
                                height: 32,
                                width: 64,
                                decoration: BoxDecoration(
                                  color: fgColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: border),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: _Design.space3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr("background_color"),
                                style: TextStyle(
                                    color: textPrim,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                            GestureDetector(
                              onTap: () =>
                                  _colorPickerDialog(context, 2, bgColor, sv),
                              child: Container(
                                height: 32,
                                width: 64,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: border),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: _Design.space3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr("text_weight"),
                                style: TextStyle(
                                    color: textPrim,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                            StyledDropdown<String>(
                              value: sv.subtitleTextStyle,
                              items: const ['light', 'regular', 'bold'],
                              labels: [tr("light"), tr("regular"), tr("bold")],
                              textPrim: textPrim,
                              textSec: textSec,
                              onChanged: (v) =>
                                  setState(() => sv.subtitleTextStyle = v!),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _Design.space6),

            // ─── General section ────────────────────────────────────────────
            Row(
              children: [
                const LeadingDot(),
                Text(
                  tr("general"),
                  style: TextStyle(
                    color: textPrim,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: _Design.space3),
            _Card(
              surface: surface,
              border: border,
              child: Column(
                children: [
                  _Tile(
                    icon: FontAwesomeIcons.expand,
                    title: tr("auto_full_screen"),
                    textPrim: textPrim,
                    textSec: textSec,
                    trailing: StyledSwitch(
                      value: sv.defaultViewMode,
                      onChanged: (v) => setState(() => sv.defaultViewMode = v),
                      activeColor: _Design.primary,
                      textSec: textSec,
                    ),
                  ),
                  const _TileDivider(),
                  _Tile(
                    icon: FontAwesomeIcons.rotateRight,
                    title: tr("seek_second"),
                    textPrim: textPrim,
                    textSec: textSec,
                    trailing: StyledDropdown<int>(
                      value: sv.defaultSeekDuration,
                      items: const [5, 10, 15, 20, 30],
                      labels: const ['5s', '10s', '15s', '20s', '30s'],
                      textPrim: textPrim,
                      textSec: textSec,
                      onChanged: (v) =>
                          setState(() => sv.defaultSeekDuration = v!),
                    ),
                  ),
                  const _TileDivider(),
                  _Tile(
                    icon: FontAwesomeIcons.spinner,
                    title: tr("buffer_amount"),
                    textPrim: textPrim,
                    textSec: textSec,
                    trailing: StyledDropdown<int>(
                      value: sv.defaultMaxBufferDuration,
                      items: const [
                        15000,
                        30000,
                        45000,
                        60000,
                        90000,
                        120000,
                        150000,
                        180000,
                        240000,
                        300000,
                        360000,
                        420000,
                        500000,
                        600000
                      ],
                      labels: const [
                        '15s',
                        '30s',
                        '45s',
                        '60s',
                        '90s',
                        '120s',
                        '150s',
                        '180s',
                        '240s',
                        '300s',
                        '360s',
                        '420s',
                        '500s',
                        '600s'
                      ],
                      textPrim: textPrim,
                      textSec: textSec,
                      onChanged: (v) =>
                          setState(() => sv.defaultMaxBufferDuration = v!),
                    ),
                  ),
                  const _TileDivider(),
                  _Tile(
                    icon: FontAwesomeIcons.fileVideo,
                    title: tr("video_resolution"),
                    textPrim: textPrim,
                    textSec: textSec,
                    trailing: StyledDropdown<int>(
                      value: sv.defaultVideoResolution,
                      items: const [0, 360, 720, 1080],
                      labels: [tr("auto"), '360p', '720p', '1080p'],
                      textPrim: textPrim,
                      textSec: textSec,
                      onChanged: (v) =>
                          setState(() => sv.defaultVideoResolution = v!),
                    ),
                  ),
                  const _TileDivider(),
                  _Tile(
                    icon: FontAwesomeIcons.solidClock,
                    title: tr("player_time_display"),
                    textPrim: textPrim,
                    textSec: textSec,
                    trailing: StyledDropdown<int>(
                      value: sv.playerTimeDisplay,
                      items: const [1, 2],
                      labels: [tr("elapsed_total"), tr("elapsed_remaining")],
                      textPrim: textPrim,
                      textSec: textSec,
                      onChanged: (v) =>
                          setState(() => sv.playerTimeDisplay = v!),
                    ),
                  ),
                  const _TileDivider(),
                  _Tile(
                    icon: FontAwesomeIcons.language,
                    title: tr("default_audio_language"),
                    textPrim: textPrim,
                    textSec: textSec,
                    trailing: StyledDropdown<String>(
                      value: sv.defaultAudioLanguage,
                      items: supportedLanguages
                          .where((l) => l.languageCode != '')
                          .map((l) => l.languageCode)
                          .toList(),
                      labels: supportedLanguages
                          .where((l) => l.languageCode != '')
                          .map((l) => l.englishName)
                          .toList(),
                      textPrim: textPrim,
                      textSec: textSec,
                      onChanged: (v) =>
                          setState(() => sv.defaultAudioLanguage = v!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _Design.space6),
          ],
        ),
      ),
    );
  }

  static Color _parseColor(String s) {
    try {
      final hex =
          s.replaceAll("Color(0x", "").replaceAll(")", "").replaceAll(" ", "");
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return const Color(0xff443a49);
    }
  }

// Removed _bufferOptions as it is now inline in StyledDropdown call
}

class _CircleBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final Color bgColor;

  const _CircleBackButton(
      {required this.onTap, required this.iconColor, required this.bgColor});

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

class _Card extends StatelessWidget {
  final Color surface;
  final Color border;
  final Widget child;

  const _Card(
      {required this.surface, required this.border, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(_Design.radiusMd),
        border: Border.all(color: border),
        boxShadow: const [_Design.shadowCard],
      ),
      child: child,
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 56);
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final Color textPrim;
  final Color textSec;

  const _Tile({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.textPrim,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: _Design.space4, vertical: _Design.space3),
      child: Row(
        children: [
          Icon(icon, size: 22, color: _Design.primary),
          const SizedBox(width: _Design.space3),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  color: textPrim, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
