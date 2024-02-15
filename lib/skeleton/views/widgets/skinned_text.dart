import 'package:flutter/material.dart';

import '../../export.dart';

class SkinnedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color strokeColor;
  final double? strokeWidth;
  final Alignment alignment;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final TextDirection? textDirection;
  final double shadowScale;
  const SkinnedText(
    this.text, {
    super.key,
    this.style,
    this.strokeColor = TColors.primary10,
    this.textAlign,
    this.strokeWidth,
    this.alignment = Alignment.topCenter,
    this.textDirection,
    this.shadowScale = 1.0,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    var style = this.style ?? TStyles.medium;
    return Stack(alignment: alignment, children: [
      Text(text,
          overflow: overflow,
          textAlign: textAlign,
          textDirection: textDirection,
          style: style.copyWith(
            foreground: Paint()
              ..strokeWidth = strokeWidth ?? style.fontSize! * 0.15
              ..color = strokeColor
              ..style = PaintingStyle.stroke,
          )),
      Padding(
        padding: EdgeInsets.only(top: 3.5.d),
        child: Text(text,
            overflow: overflow,
            textAlign: textAlign,
            textDirection: textDirection,
            style: style.copyWith(
              foreground: Paint()
                ..strokeWidth = strokeWidth ?? style.fontSize! * 0.15
                ..color = strokeColor
                ..style = PaintingStyle.stroke,
            )),
      ),
      Text(text,
          overflow: overflow,
          textAlign: textAlign,
          textDirection: textDirection,
          style: style.copyWith(
            color: style.color == TColors.primary10
                ? TColors.primary
                : style.color,
          )),
    ]);
  }
}
