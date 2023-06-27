import 'package:flutter/material.dart';
import 'package:flutter_skeleton/services/theme.dart';

import '../../services/deviceinfo.dart';

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
    var style = this.style ??
        TextStyle(
            fontSize: 12.d,
            foreground: Paint()..color = TColors.white,
            decorationThickness: 2);

    return Stack(
      children: [
        Center(
            heightFactor: 0.5,
            child: Text(
              text,
              textAlign: textAlign,
              style: style.copyWith(
                foreground: Paint()
                  ..strokeWidth = strokeWidth ?? 8.d
                  ..color = strokeColor ?? TColors.primary10
                  ..style = PaintingStyle.stroke,
              ),
            )),
        Center(
            heightFactor: 0.42,
            child: Text(text, textAlign: textAlign, style: style)),
      ],
    );
  }
}
