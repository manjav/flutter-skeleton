import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../services/theme.dart';

class SkinnedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color strokeColor;
  final double? strokeWidth;
  final Alignment alignment;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  const SkinnedText(
    this.text, {
    super.key,
    this.style,
    this.strokeColor = TColors.primary10,
    this.textAlign,
    this.strokeWidth,
    this.alignment = Alignment.center,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    var style = this.style ?? TStyles.medium;
    return Stack(alignment: alignment, children: [
      // Positioned.fill(child: Widgets.rect(color: TColors.green.withAlpha(31))),
      Text(text,
          overflow: overflow,
          textAlign: textAlign,
          style: style.copyWith(
              // backgroundColor: TColors.accent,
              foreground: Paint()
                ..strokeWidth = strokeWidth ?? 9.d
                ..color = strokeColor
                ..style = PaintingStyle.stroke,
              shadows: [_shadow(0, style.fontSize! * 0.18)])),
      Text(text,
          overflow: overflow,
          textAlign: textAlign,
          style: style.copyWith(
            color: style.color == TColors.primary10
                ? TColors.primary
                : style.color,
          )),
    ]);
  }

  _shadow(double x, double y) =>
      Shadow(offset: Offset(x, y), color: strokeColor);
}
