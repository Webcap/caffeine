import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:reelriot/provider/settings_provider.dart';

/// Layout-matching shimmer skeleton screen that renders immediately when opening
/// Movie or TV detail views, preventing jarring spinners and layout shifts.
class MediaDetailSkeleton extends StatelessWidget {
  const MediaDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isDark = settings.appTheme == 'dark' || settings.appTheme == 'amoled';

    final baseColor = isDark ? const Color(0xFF1E1E24) : Colors.grey.shade300;
    final highlightColor = isDark ? const Color(0xFF2E2E38) : Colors.grey.shade100;
    final blockColor = isDark ? const Color(0xFF262630) : Colors.grey.shade400;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Backdrop Placeholder ──────────────────────────────
            Container(
              height: 250,
              width: double.infinity,
              color: blockColor,
            ),

            // ── Overlapping Poster & Metadata Block ───────────────────
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Poster Card
                        Container(
                          width: 110,
                          height: 165,
                          decoration: BoxDecoration(
                            color: blockColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title & Tags Stack
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title row 1
                              Container(
                                width: double.infinity,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: blockColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Title row 2 (shorter)
                              Container(
                                width: 140,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: blockColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Chips row
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: blockColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 58,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: blockColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 48,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: blockColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Primary Action Buttons Row ──────────────────────────
                    Row(
                      children: [
                        // Large Play Button Pill
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: blockColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Circular Bookmark Button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: blockColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Circular Share Button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: blockColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Synopsis Paragraph Skeleton ─────────────────────────
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 220,
                      height: 12,
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Cast Avatars Row ───────────────────────────────────
                    Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        4,
                        (index) => Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: blockColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 50,
                              height: 10,
                              decoration: BoxDecoration(
                                color: blockColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
