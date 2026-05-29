import 'package:flutter/material.dart';

class VersionDisplay extends StatelessWidget {
  final String version;
  final TextStyle? style;
  final double? buildFontSize;
  final Color? buildColor;
  final MainAxisAlignment mainAxisAlignment;
  final bool isVertical;

  const VersionDisplay({
    super.key,
    required this.version,
    this.style,
    this.buildFontSize,
    this.buildColor,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!version.contains('+')) {
      return Text('v$version', style: style);
    }

    final parts = version.split('+');
    final baseVersion = parts[0];
    final buildNumber = parts[1];

    final defaultStyle = style ?? Theme.of(context).textTheme.bodyMedium;

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('v$baseVersion', style: defaultStyle),
          const SizedBox(height: 8),
          _buildChip(context, buildNumber, defaultStyle),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('v$baseVersion', style: defaultStyle),
        const SizedBox(width: 8),
        _buildChip(context, buildNumber, defaultStyle),
      ],
    );
  }

  Widget _buildChip(
      BuildContext context, String buildNumber, TextStyle? defaultStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (buildColor ?? defaultStyle?.color ?? Colors.white)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (buildColor ?? defaultStyle?.color ?? Colors.white)
              .withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        'Build $buildNumber',
        style: TextStyle(
          color: (buildColor ?? defaultStyle?.color ?? Colors.white)
              .withValues(alpha: 0.8),
          fontSize: buildFontSize ?? (defaultStyle?.fontSize ?? 14) * 0.6,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
