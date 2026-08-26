import 'package:flutter/material.dart';

class WatchStatCard extends StatelessWidget {
  const WatchStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  static const _secondary = Color(0xFF7C3AED);
  static const _textPrimDark = Color(0xFFFFFFFF);
  static const _textPrimLight = Color(0xFF0B0F14);
  static const _textTertDark = Color(0x80FFFFFF);
  static const _textTertLight = Color(0xFF94A3B8);
  static const _bgSurfaceDark = Color(0xFF0B0F14);
  static const _bgElevatedLight = Color(0xFFF1F5F9);
  static const _borderDark = Color(0x14FFFFFF);
  static const _borderLight = Color(0x140F172A);

  @override
  Widget build(BuildContext context) {
    final textPrim = isDark ? _textPrimDark : _textPrimLight;
    final textTert = isDark ? _textTertDark : _textTertLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? _bgSurfaceDark : _bgElevatedLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? _borderDark : _borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: _secondary),
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
