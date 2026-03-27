import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Cinematic shimmer skeleton matching design.json:
/// canvas → gray-950 / gray-50, shimmer highlight → surface-elevated
class HomeLoadingWidget extends StatelessWidget {
  const HomeLoadingWidget({super.key});

  static const Color _bgDark = Color(0xFF030712);
  static const Color _bgLight = Color(0xFFF8FAFC);
  static const Color _baseDark = Color(0xFF111827);
  static const Color _baseLight = Color(0xFFE2E8F0);
  static const Color _highlightDark = Color(0xFF1F2937);
  static const Color _highlightLight = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _bgLight;
    final base = isDark ? _baseDark : _baseLight;
    final highlight = isDark ? _highlightDark : _highlightLight;

    return ColoredBox(
      color: bg,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        period: const Duration(milliseconds: 1400),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ── Featured poster hero ─────────────────────────────────────
            _ShimmerBox(
              width: double.infinity,
              height: 280,
              radius: 20,
            ),
            const SizedBox(height: 12),

            // ── Carousel indicator dots ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == 0 ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Section title (Trending) ──────────────────────────────────
            Row(
              children: [
                const _ShimmerBox(width: 20, height: 20, radius: 4),
                const SizedBox(width: 8),
                const _ShimmerBox(width: 110, height: 18, radius: 6),
              ],
            ),
            const SizedBox(height: 12),

            // ── Horizontal poster card row ────────────────────────────────
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, __) => const _ShimmerBox(
                  width: 106,
                  height: 160,
                  radius: 16,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Section title (Popular) ───────────────────────────────────
            const _ShimmerBox(width: 90, height: 18, radius: 6),
            const SizedBox(height: 12),

            // ── Second horizontal poster row ──────────────────────────────
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, __) => const _ShimmerBox(
                  width: 106,
                  height: 160,
                  radius: 16,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Genre chip row ────────────────────────────────────────────
            const _ShimmerBox(width: 80, height: 18, radius: 6),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                8,
                (i) => _ShimmerBox(
                  width: 60.0 + (i.isEven ? 20 : 0),
                  height: 32,
                  radius: 999,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
