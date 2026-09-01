import 'package:flutter/material.dart';
import 'package:reelriot/models/tv.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const ratingGold = Color(0xFFEAB308);

  static const bgElevatedDark = Color(0x0DFFFFFF);
  static const bgElevatedLight = Color(0xFFF1F5F9);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF475569);
}

class TVEpisodeOptions extends StatelessWidget {
  const TVEpisodeOptions({super.key, required this.episodeList});

  final EpisodeList episodeList;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elevated = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    final avg = episodeList.voteAverage;
    final ratingStr = avg != null && avg > 0
        ? (avg == avg.truncateToDouble()
            ? avg.toStringAsFixed(0)
            : avg.toStringAsFixed(1))
        : null;
    final voteCount = episodeList.voteCount ?? 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 24 : 16,
        isTablet ? 16 : 12,
        isTablet ? 24 : 16,
        isTablet ? 12 : 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: isTablet ? 10 : 8,
              runSpacing: isTablet ? 10 : 8,
              children: [
                if (ratingStr != null)
                  _RatingChip(
                    icon: Icons.star_rounded,
                    value: '$ratingStr/10',
                    accentColor: _C.ratingGold,
                    elevated: elevated,
                    border: border,
                    textSec: textSec,
                  ),
                _RatingChip(
                  icon: Icons.people_outline_rounded,
                  value: voteCount.toString(),
                  accentColor: _C.primary.withValues(alpha: 0.9),
                  elevated: elevated,
                  border: border,
                  textSec: textSec,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({
    required this.icon,
    required this.value,
    required this.accentColor,
    required this.elevated,
    required this.border,
    required this.textSec,
  });

  final IconData icon;
  final String value;
  final Color accentColor;
  final Color elevated;
  final Color border;
  final Color textSec;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: elevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textSec,
            ),
          ),
        ],
      ),
    );
  }
}
