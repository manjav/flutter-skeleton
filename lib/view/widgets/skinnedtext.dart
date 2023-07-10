import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../services/theme.dart';

class SkinnedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? strokeColor;
  final double? strokeWidth;

  const SkinnedText(
    this.text, {
    Key? key,
    this.style,
    this.strokeColor,
    this.strokeWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var style = this.style ?? TStyles.medium;
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          style: style.copyWith(
            height: -0.22,
            foreground: Paint()
              ..strokeWidth = strokeWidth ?? 9.d
              ..color = strokeColor ?? TColors.primary10
              ..style = PaintingStyle.stroke,
          ),
        ),
        Text(text, style: style.copyWith(height: -0.3, color: TColors.primary)),
      ],
    );
  }
}
