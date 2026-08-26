import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/models/live_tv.dart';
import 'package:reelriot/screens/tv_screens/live_event_screen.dart';
import 'package:reelriot/utils/sports_helpers.dart';
import 'package:flutter/material.dart';

class FeaturedMatchCard extends StatefulWidget {
  const FeaturedMatchCard({
    super.key,
    required this.event,
  });

  final FeaturedEvent event;

  @override
  State<FeaturedMatchCard> createState() => _FeaturedMatchCardState();
}

class _FeaturedMatchCardState extends State<FeaturedMatchCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = resolveSportTheme(
      sport: widget.event.sport,
      title: widget.event.title,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: theme.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            // Background thumbnail (if available)
            if (widget.event.thumbnailUrl.isNotEmpty)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2,
                  child: CachedNetworkImage(
                    imageUrl: widget.event.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

            // Sport watermark icon on right side
            Positioned(
              right: -10,
              bottom: -15,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  theme.icon,
                  size: 160,
                  color: Colors.white,
                ),
              ),
            ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Live Sport Badge + Featured Match Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.accentColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _pulseCtrl,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: theme.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${theme.label} · LIVE NOW',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 12, color: Color(0xFFFCD34D)),
                          SizedBox(width: 4),
                          Text(
                            'FEATURED',
                            style: TextStyle(
                              color: Color(0xFFFCD34D),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Match Title
                Text(
                  widget.event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Watch Button
                SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveEventScreen(
                            event: StreameastEvent(
                              id: widget.event.id,
                              title: widget.event.title,
                              url: '',
                              logoUrl: widget.event.thumbnailUrl,
                              sport: widget.event.sport,
                            ),
                            videoUrl: widget.event.videoUrl,
                            referrer: widget.event.referrer ?? '',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded,
                        color: Colors.black, size: 20),
                    label: const Text(
                      'Watch Live Stream',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shadowColor: theme.accentColor.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
