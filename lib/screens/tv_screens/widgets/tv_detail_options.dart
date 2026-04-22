import 'package:flutter/material.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/bookmarks_provider.dart';
import 'package:provider/provider.dart';

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

class TVDetailOptions extends StatefulWidget {
  const TVDetailOptions({super.key, required this.tvSeries});

  final TV tvSeries;

  @override
  State<TVDetailOptions> createState() => _TVDetailOptionsState();
}

class _TVDetailOptionsState extends State<TVDetailOptions> {
  bool? isBookmarked;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final provider = Provider.of<BookmarksProvider>(context, listen: false);
    final b = await provider.containsTV(widget.tvSeries.id!);
    if (mounted) setState(() => isBookmarked = b);
    if (mounted && b) await provider.updateTV(widget.tvSeries);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elevated = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;

    final avg = widget.tvSeries.voteAverage;
    final ratingStr = avg != null && avg > 0
        ? (avg == avg.truncateToDouble()
            ? avg.toStringAsFixed(0)
            : avg.toStringAsFixed(1))
        : null;
    final voteCount = widget.tvSeries.voteCount ?? 0;

    return Consumer<BookmarksProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              // ── Rating badges (compact capsules) ────────────────────────
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
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

              // ── Bookmark button (design.json: primary action) ───────────
              GestureDetector(
                onTap: () async {
                  if (isBookmarked == false) {
                    try {
                      await provider.addTV(widget.tvSeries);
                      if (mounted) setState(() => isBookmarked = true);
                    } catch (_) {
                      if (mounted && provider.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.errorMessage!)),
                        );
                        provider.clearError();
                      }
                    }
                  } else if (isBookmarked == true) {
                    try {
                      await provider.removeTV(widget.tvSeries.id!);
                      if (mounted) setState(() => isBookmarked = false);
                    } catch (_) {
                      if (mounted && provider.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.errorMessage!)),
                        );
                        provider.clearError();
                      }
                    }
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: elevated,
                    border: Border.all(color: border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: (isBookmarked == true
                                ? _C.primary
                                : Colors.transparent)
                            .withValues(alpha: 0.2),
                        blurRadius: isBookmarked == true ? 10 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    isBookmarked == true
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 20,
                    color: isBookmarked == true ? _C.primary : textSec,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
