import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../skinnedtext.dart';
import '../../../services/deviceinfo.dart';
import '../../../services/theme.dart';

import '../../widgets.dart';

class Powerbalance extends StatelessWidget {
  final int value, maxValue;
  const Powerbalance(this.value, this.maxValue, {super.key});

  @override
  Widget build(BuildContext context) {
    var p = 8.d;
    var w = 36.d;
    var r = 56.d;
    var c = 100.d;
    var h = DeviceInfo.size.height - 800.d;
    var height = (1 - (value.abs() / maxValue)) * h * 0.5;
    var color = value == 0
        ? TColors.transparent
        : value > 0
            ? TColors.green
            : TColors.accent;
    var bgColor = TColors.primary10;
    return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Widgets.rect(width: w, height: h, color: bgColor, radius: r),
          Widgets.rect(width: c, height: c, radius: r, color: bgColor),
          Widgets.rect(
              width: c - p * 2, height: c - p * 2, radius: r, color: color),
          AnimatedPositioned(
              bottom: value > 0 ? p + height : h * 0.5,
              top: value < 0 ? p + height : h * 0.5,
              curve: Curves.easeOutCubic,
              duration: const Duration(seconds: 1),
              child:
                  Widgets.rect(width: w - p * 2, color: color, radius: r - p)),
          Positioned(left: 132.d, child: SkinnedText(value.compact()))
        ]);
  }
}
