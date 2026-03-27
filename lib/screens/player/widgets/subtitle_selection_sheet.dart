import 'package:better_player/better_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SubtitleSelectionSheet extends StatefulWidget {
  final List<BetterPlayerSubtitlesSource> subtitles;
  final BetterPlayerSubtitlesSource? selectedSubtitle;
  final VoidCallback onSearchPressed;
  final Function(BetterPlayerSubtitlesSource?) onSubtitleSelected;

  const SubtitleSelectionSheet({
    super.key,
    required this.subtitles,
    this.selectedSubtitle,
    required this.onSearchPressed,
    required this.onSubtitleSelected,
  });

  @override
  State<SubtitleSelectionSheet> createState() => _SubtitleSelectionSheetState();
}

class _SubtitleSelectionSheetState extends State<SubtitleSelectionSheet> {
  @override
  Widget build(BuildContext context) {
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
              color: Colors.grey.withOpacity(0.3),
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
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
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
