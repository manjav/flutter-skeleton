import 'dart:ui' as ui;


import 'package:flutter/material.dart';

import '../../../app_export.dart';

class BattonDecoration extends Decoration {
  final Color? mainColor;
  final Color? strokeColor;
  final double? strokeWidth;
  final double? cornerRadius;
  final bool? isPressed;

  const BattonDecoration({
    this.mainColor,
    this.strokeColor,
    this.strokeWidth,
    this.cornerRadius,
    this.isPressed,
  }) : super();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ButtonPainter(
      mainColor ?? TColors.primary0,
      strokeColor ?? TColors.primary20,
      strokeWidth ?? 4.d,
      cornerRadius ?? 10.d,
      isPressed ?? false,
    );
  }
}

class _ButtonPainter extends BoxPainter {
  final Color mainColor;
  final Color strokeColor;
  final double strokeWidth;
  final double cornerRadius;
  final bool isPressed;
  final _mainPaint = Paint()
    ..style = PaintingStyle.fill
    ..color;
  final _strokePaint = Paint()..style = PaintingStyle.stroke;
  final _hilightPaint = Paint()..style = PaintingStyle.fill;

  _ButtonPainter(
    this.mainColor,
    this.strokeColor,
    this.strokeWidth,
    this.cornerRadius,
    this.isPressed,
  ) : super() {
    _mainPaint.color = mainColor;
    _strokePaint.color = strokeColor;
    _strokePaint.strokeWidth = strokeWidth;
    _strokePaint.strokeJoin = StrokeJoin.round;
    _hilightPaint.color = Color.lerp(mainColor, TColors.white, 0.2)!;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (configuration.size!.width == 0 || configuration.size!.height == 0) {
      return;
    }
    var size = configuration.size!;
    var cr = cornerRadius;
    var r = RRect.fromLTRBXY(offset.dx, offset.dy, offset.dx + size.width,
        offset.dy + size.height, cr, cr);
    var l = _strokePaint.strokeWidth * 0.5;
    var isEnable = true;
    var b = 4.0.d;
    var pressed = isPressed && isEnable;
    _hilightPaint.shader = ui.Gradient.linear(Offset(offset.dx, offset.dy),
        Offset(offset.dx, offset.dy + size.height), [
      pressed ? Color.lerp(mainColor, TColors.white, 0.2)! : mainColor,
      pressed ? mainColor : Color.lerp(mainColor, TColors.white, 0.3)!
    ]);

    var or = RRect.fromLTRBXY(r.left, r.top + b - (pressed ? 0 : b), r.right,
        r.bottom - l - (pressed ? 0 : b), cr, cr);

    canvas.drawRRect(r, _strokePaint);
    canvas.drawRRect(r, _mainPaint);
    canvas.drawRRect(pressed ? r : or, _hilightPaint);
  }
}
