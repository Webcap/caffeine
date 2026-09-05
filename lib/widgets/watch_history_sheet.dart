import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/utils/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

/// Trakt-style watch history: shows every logged watch event for one movie
/// or episode, each removable. Reused by both the movie detail "watched"
/// button and the TV episode long-press menu.
class WatchHistorySheet {
  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Future<List<WatchEvent>> Function() loadEvents,
    required Future<void> Function(WatchEvent event) onRemove,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _WatchHistorySheetBody(
        title: title,
        subtitle: subtitle,
        loadEvents: loadEvents,
        onRemove: onRemove,
      ),
    );
  }
}

class _WatchHistorySheetBody extends StatefulWidget {
  const _WatchHistorySheetBody({
    required this.title,
    this.subtitle,
    required this.loadEvents,
    required this.onRemove,
  });

  final String title;
  final String? subtitle;
  final Future<List<WatchEvent>> Function() loadEvents;
  final Future<void> Function(WatchEvent event) onRemove;

  @override
  State<_WatchHistorySheetBody> createState() => _WatchHistorySheetBodyState();
}

class _WatchHistorySheetBodyState extends State<_WatchHistorySheetBody> {
  List<WatchEvent>? _events;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final events = await widget.loadEvents();
    if (mounted) setState(() => _events = events);
  }

  Future<void> _remove(WatchEvent event) async {
    setState(() => _events?.removeWhere((e) => e.eventId == event.eventId));
    await widget.onRemove(event);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 18, color: textColor),
                      const SizedBox(width: 8),
                      Text(
                        tr("watch_history"),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 14, color: subColor),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: TextStyle(fontSize: 12, color: subColor),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: _events == null
                  ? _buildSkeletonList(isDark)
                  : _events!.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            tr("no_watches_logged"),
                            style: TextStyle(color: subColor),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: _events!.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final event = _events![index];
                            final watchedAt = DateTime.tryParse(event.watchedAt);
                            final formatted = watchedAt != null
                                ? DateFormat('MMM d, yyyy • h:mm a').format(watchedAt)
                                : event.watchedAt;
                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                              leading: const Icon(Icons.check_circle_rounded,
                                  color: AppSemanticColors.successDefault, size: 20),
                              title: Text(
                                formatted,
                                style: TextStyle(fontSize: 15, color: textColor),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: AppSemanticColors.dangerDefault),
                                tooltip: tr("remove_watch"),
                                onPressed: () => _remove(event),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList(bool isDark) {
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.10);
    final placeholderColor = isDark ? Colors.white12 : Colors.black12;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: placeholderColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: placeholderColor,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: placeholderColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
