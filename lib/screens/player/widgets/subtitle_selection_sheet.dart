import 'package:reelriot/services/player/caffeine_player_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SubtitleSelectionSheet extends StatefulWidget {
  final List<CaffeinePlayerSubtitlesSource> subtitles;
  final CaffeinePlayerSubtitlesSource? selectedSubtitle;
  final CaffeinePlayerController controller;
  final VoidCallback onSearchPressed;
  final Function(CaffeinePlayerSubtitlesSource?) onSubtitleSelected;
  final bool isLoading;

  const SubtitleSelectionSheet({
    super.key,
    required this.subtitles,
    this.selectedSubtitle,
    required this.controller,
    required this.onSearchPressed,
    required this.onSubtitleSelected,
    this.isLoading = false,
  });

  @override
  State<SubtitleSelectionSheet> createState() => _SubtitleSelectionSheetState();
}

class _SubtitleSelectionSheetState extends State<SubtitleSelectionSheet> {
  CaffeinePlayerSubtitlesSource? _selectedSubtitle;

  @override
  void initState() {
    super.initState();
    _selectedSubtitle = widget.selectedSubtitle;
  }

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
                  isSelected: _selectedSubtitle == null,
                  onTap: () {
                    widget.onSubtitleSelected(null);
                    setState(() {
                      _selectedSubtitle = null;
                    });
                    if (mounted) Navigator.pop(context);
                  },
                ),
                ...widget.subtitles.map((sub) {
                  final parts = (sub.name ?? "").split(" (");
                  final title = parts[0];
                  final subtitle = parts.length > 1
                      ? parts[1].replaceAll(")", "")
                      : null;

                  return _buildSubtitleTile(
                    context,
                    title: title,
                    subtitle: subtitle != null ? "ID: $subtitle" : null,
                    isSelected: _selectedSubtitle == sub,
                    onTap: () {
                      widget.onSubtitleSelected(sub);
                      setState(() {
                        _selectedSubtitle = sub;
                      });
                      if (mounted) Navigator.pop(context);
                    },
                  );
                }),
                const Divider(),
                _buildSubtitleTile(
                  context,
                  title: widget.isLoading
                      ? '${tr("searching")}...'
                      : tr("search_more_subtitles"),
                  icon: widget.isLoading ? null : Icons.search,
                  trailing: widget.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                  onTap: widget.isLoading
                      ? () {}
                      : () {
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
    String? subtitle,
    bool isSelected = false,
    IconData? icon,
    Widget? trailing,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.7)
                            : Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 16),
              trailing,
            ],
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
