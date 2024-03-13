import 'package:flutter/material.dart';

import '../../../app_export.dart';

class BattonDecoration extends Decoration {
  final Color? mainColor;
  final Color? outlineColor;
  final double? outlineSize;
  final double? strokeSize;
  final double? cornerRadius;
  final bool? isPressed;
  final bool? isEnable;

  const BattonDecoration({
    this.mainColor,
    this.outlineColor,
    this.outlineSize,
    this.strokeSize,
    this.cornerRadius,
    this.isPressed,
    this.isEnable,
  }) : super();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ButtonPainter(
      mainColor ?? TColors.orange,
      outlineSize ?? 2.d,
      strokeSize ?? 3.d,
      cornerRadius ?? 10.d,
      isPressed ?? false,
      isEnable ?? true,
    );
  }
}

class _ButtonPainter extends BoxPainter {
  final Color mainColor;
  final double outlineSize;
  final double strokeSize;
  final double cornerRadius;
  final bool isPressed;
  final bool isEnable;
  final _mainPaint = Paint()
    ..style = PaintingStyle.fill
    ..color;
  final _strokePaint = Paint()..style = PaintingStyle.fill;
  bool _hasOutline = false;

  _ButtonPainter(
    this.mainColor,
    this.outlineSize,
    this.strokeSize,
    this.cornerRadius,
    this.isPressed,
    this.isEnable,
  ) : super() {
    _mainPaint.color = mainColor;
    _hasOutline = mainColor == TColors.white;
    _strokePaint.color = Color.lerp(mainColor, TColors.black, 0.3)!;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (configuration.size!.width == 0 || configuration.size!.height == 0) {
      return;
    }
    var cr = cornerRadius;
    var size = configuration.size!;
    var pressed = isPressed || !isEnable;
    var b = pressed ? strokeSize : 0;
    var o = _hasOutline ? outlineSize : 0;

    var br = RRect.fromLTRBXY(offset.dx, offset.dy + b, offset.dx + size.width,
        offset.dy + size.height, cr, cr);
    canvas.drawRRect(br, _strokePaint);

    var fr = RRect.fromLTRBXY(
        offset.dx + o,
        offset.dy + b + o,
        offset.dx + size.width - o,
        offset.dy +
            size.height -
            o -
            (pressed ? 0 : strokeSize) -
            (_hasOutline ? 0 : outlineSize),
        cr * (_hasOutline ? 0.8 : 1.0),
        cr * (_hasOutline ? 0.8 : 1.0));
    canvas.drawRRect(fr, _mainPaint);
  }
}
