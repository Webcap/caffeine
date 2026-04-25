import 'package:reelriot/services/player/caffeine_player_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SubtitleSelectionSheet extends StatefulWidget {
  final List<CaffeinePlayerSubtitlesSource> subtitles;
  final CaffeinePlayerSubtitlesSource? selectedSubtitle;
  final CaffeinePlayerController controller;
  final VoidCallback onSearchPressed;
  final Function(CaffeinePlayerSubtitlesSource?) onSubtitleSelected;

  const SubtitleSelectionSheet({
    super.key,
    required this.subtitles,
    this.selectedSubtitle,
    required this.controller,
    required this.onSearchPressed,
    required this.onSubtitleSelected,
  });

  @override
  State<SubtitleSelectionSheet> createState() => _SubtitleSelectionSheetState();
}

class _SubtitleSelectionSheetState extends State<SubtitleSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    // final currentOffset = (widget.controller.betterPlayerSubtitlesSource?.offset ?? 0) / 1000;
    const currentOffset = 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  tr("subtitles"),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildSubtitleTile(
                  context,
                  title: tr("off"),
                  isSelected: widget.selectedSubtitle == null,
                  onTap: () {
                    widget.onSubtitleSelected(null);
                    if (mounted) Navigator.of(context).pop();
                  },
                ),
                ...widget.subtitles.map((sub) => _buildSubtitleTile(
                      context,
                      title: sub.name ?? tr("unknown"),
                      isSelected: widget.selectedSubtitle == sub,
                      onTap: () {
                        widget.onSubtitleSelected(sub);
                        if (mounted) Navigator.of(context).pop();
                      },
                    )),
                const Divider(),
                _buildSubtitleTile(
                  context,
                  title: tr("search_more_subtitles"),
                  icon: Icons.search,
                  onTap: () {
                    if (mounted) Navigator.of(context).pop();
                    widget.onSearchPressed();
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sync, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "Subtitle Sync",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${currentOffset.toStringAsFixed(1)}s",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SyncButton(
                      label: "-1s",
                      onPressed: () {
                        // Not implemented yet in MediaKit bridge
                      },
                    ),
                    _SyncButton(
                      label: "-0.1s",
                      onPressed: () {
                        // Not implemented yet in MediaKit bridge
                      },
                    ),
                    _SyncButton(
                      label: "Reset",
                      onPressed: () {
                        // Not implemented yet in MediaKit bridge
                      },
                    ),
                    _SyncButton(
                      label: "+0.1s",
                      onPressed: () {
                        // Not implemented yet in MediaKit bridge
                      },
                    ),
                    _SyncButton(
                      label: "+1s",
                      onPressed: () {
                        // Not implemented yet in MediaKit bridge
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSubtitleTile(
    BuildContext context, {
    required String title,
    bool isSelected = false,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon ?? (isSelected ? Icons.check_circle : Icons.closed_caption),
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SyncButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
