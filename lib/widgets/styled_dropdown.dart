import 'dart:ui';
import 'package:flutter/material.dart';

class StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final List<String> labels;
  final ValueChanged<T?> onChanged;
  final Color textPrim;
  final Color textSec;

  const StyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.labels,
    required this.onChanged,
    required this.textPrim,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = textPrim == const Color(0xFFFFFFFF);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: textPrim.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textPrim.withOpacity(0.08)),
          ),
          child: DropdownButton<T>(
            value: value,
            underline: const SizedBox.shrink(),
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSec, size: 20),
            dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: List.generate(
                items.length,
                (i) => DropdownMenuItem(
                    value: items[i],
                    child: Text(labels[i],
                        style: TextStyle(
                            color: textPrim,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)))),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
