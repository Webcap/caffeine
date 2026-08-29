import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/widgets/mobile_context_menu.dart';

/// Trakt-style "add a watch" quick menu: lets the user pick when the watch
/// happened (just now, the media's release date, a custom date, or unknown)
/// instead of always defaulting to "now".
class AddWatchMenu {
  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    DateTime? releaseDate,
    required void Function(String? watchedAtIso) onPick,
  }) {
    MobileContextMenu.show(
      context: context,
      title: title,
      subtitle: subtitle,
      items: [
        MobileContextMenuItem(
          label: tr("watch_just_now"),
          icon: Icons.bolt_rounded,
          onTap: () => onPick(DateTime.now().toIso8601String()),
        ),
        if (releaseDate != null)
          MobileContextMenuItem(
            label: tr("watch_release_date"),
            icon: Icons.event_rounded,
            onTap: () => onPick(releaseDate.toIso8601String()),
          ),
        MobileContextMenuItem(
          label: tr("watch_other_date"),
          icon: Icons.calendar_month_rounded,
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(1900),
              lastDate: now,
            );
            if (picked != null) onPick(picked.toIso8601String());
          },
        ),
        MobileContextMenuItem(
          label: tr("watch_unknown_date"),
          icon: Icons.help_outline_rounded,
          onTap: () => onPick(''),
        ),
      ],
    );
  }
}
