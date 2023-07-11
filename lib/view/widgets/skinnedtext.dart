import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../services/theme.dart';

class SkinnedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? strokeColor;
  final double? strokeWidth;
  final Alignment alignment;

  const SkinnedText(
    this.text, {
    Key? key,
    this.style,
    this.strokeColor,
    this.strokeWidth,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var style = this.style ?? TStyles.medium;
    return Stack(
      alignment: alignment,
      children: [
        Column(
          children: [
            Text(
              text,
              style: style.copyWith(
                // height: 0.82,
                foreground: Paint()
                  ..strokeWidth = strokeWidth ?? 9.d
                  ..color = strokeColor ?? TColors.primary10
                  ..style = PaintingStyle.stroke,
              ),
            ),
            SizedBox(height: style.fontSize! * 0.2)
          ],
        ),
        Column(
          children: [
            Text(text,
                style: style.copyWith(
                  // height: 0.9,
                  color: TColors.primary,
                )),
            SizedBox(height: style.fontSize! * 0.32)
          ],
        )
      ],
    );
  }
}
