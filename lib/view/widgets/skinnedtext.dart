import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../services/theme.dart';

class SkinnedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? strokeColor;
  final TextAlign? textAlign;
  final double? strokeWidth;

  const SkinnedText(
    this.text, {
    Key? key,
    this.style,
    this.strokeColor,
    this.textAlign,
    this.strokeWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var style = this.style ?? TStyles.large;
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: style.copyWith(
            height: -0.18,
            foreground: Paint()
              ..strokeWidth = strokeWidth ?? 10.d
              ..color = strokeColor ?? TColors.primary10
              ..style = PaintingStyle.stroke,
          ),
        ),
        Text(text, textAlign: textAlign, style: style.copyWith(height: -0.3)),
      ],
    );
  }
}
