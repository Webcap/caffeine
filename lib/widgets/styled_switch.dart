import 'package:flutter/material.dart';

class StyledSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color textSec;

  const StyledSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      activeTrackColor: activeColor.withOpacity(0.4),
      inactiveThumbColor: textSec.withOpacity(0.8),
      inactiveTrackColor: textSec.withOpacity(0.2),
    );
  }
}
