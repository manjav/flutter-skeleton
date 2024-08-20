import 'package:flutter/cupertino.dart';

import '../../../app_export.dart';

enum BalloonTipPosition {
  none,
  topLeft,
  top,
  topRight,
  bottomRight,
  bottom,
  bottomLeft,
  leftTop,
  left,
  leftBottom,
  rightTop,
  right,
  rightBottom,
}

// ignore: must_be_immutable
class BalloonDecoration extends Decoration {
  final Color? mainColor;
  final Color? strokeColor;
  final double? strokeWidth;
  final double? tipSize;
  final double? cornerRadius;
  final BalloonTipPosition? tipPosition;

  const BalloonDecoration({
    this.mainColor,
    this.strokeColor,
    this.tipSize,
    this.strokeWidth,
    this.cornerRadius,
    this.tipPosition,
  }) : super();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _BollonPainter(
      mainColor ?? TColors.primary0,
      strokeColor ?? TColors.primary20,
      tipSize ?? 10.d,
      strokeWidth ?? 2.d,
      cornerRadius ?? 30.d,
      tipPosition ?? BalloonTipPosition.bottom,
    );
  }
}

class _BollonPainter extends BoxPainter {
  final Color mainColor;
  final Color strokeColor;
  final double strokeWidth;
  final double tipSize;
  final double cornerRadius;
  final BalloonTipPosition tipPosition;
  final _mainPaint = Paint()
    ..style = PaintingStyle.fill
    ..color;
  final _strokePaint = Paint()..style = PaintingStyle.stroke;

  _BollonPainter(
    this.mainColor,
    this.strokeColor,
    this.tipSize,
    this.strokeWidth,
    this.cornerRadius,
    this.tipPosition,
  ) : super() {
    _mainPaint.color = mainColor;
    _strokePaint.color = strokeColor;
    _strokePaint.strokeWidth = strokeWidth;
    _strokePaint.strokeJoin = StrokeJoin.round;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (configuration.size!.width == 0 || configuration.size!.height == 0) {
      return;
    }
    // var b = 4.0.d;
    var cr = cornerRadius;
    var r = RRect.fromLTRBXY(
        offset.dx,
        offset.dy,
        offset.dx + configuration.size!.width,
        offset.dy + configuration.size!.height,
        cr,
        cr);

    var l = _strokePaint.strokeWidth * 0.5;
    var tip = switch (tipPosition) {
      BalloonTipPosition.rightTop => Offset(r.right + l, r.top + cr + tipSize),
      BalloonTipPosition.right => Offset(r.right - l, r.center.dy + tipSize),
      BalloonTipPosition.rightBottom => Offset(r.right - l, r.bottom - cr),
      BalloonTipPosition.leftTop => Offset(r.left + l, r.top + cr + tipSize),
      BalloonTipPosition.left => Offset(r.left + l, r.center.dy + tipSize),
      BalloonTipPosition.leftBottom => Offset(r.left, r.bottom),
      BalloonTipPosition.bottomLeft => Offset(r.left + cr, r.bottom - l),
      BalloonTipPosition.bottomRight =>
        Offset(r.right - cr - tipSize, r.bottom - l),
      _ => Offset(r.center.dx - tipSize, r.bottom - l)
    };
    var path = switch (tipPosition) {
      BalloonTipPosition.rightTop ||
      BalloonTipPosition.right ||
      BalloonTipPosition.rightBottom =>
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx + tipSize, tip.dy - tipSize * 0.1)
          ..quadraticBezierTo(tip.dx + tipSize * 1.2, tip.dy - tipSize * 0.3,
              tip.dx + tipSize, tip.dy - tipSize * 0.6)
          ..lineTo(tip.dx, tip.dy - tipSize * 2),
      BalloonTipPosition.leftTop ||
      BalloonTipPosition.left ||
      BalloonTipPosition.leftBottom =>
        Path()
          ..moveTo(tip.dx + cr, tip.dy)
          ..lineTo(tip.dx - tipSize, tip.dy)
          ..quadraticBezierTo(tip.dx - tipSize * 1.5, tip.dy - tipSize * 0.5,
              tip.dx - tipSize, tip.dy - tipSize)
          ..quadraticBezierTo(
              tip.dx, tip.dy - tipSize * 1.8, tip.dx, tip.dy - tipSize * 3.6),
      _ => Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx + tipSize * 0.9, tip.dy + tipSize)
        ..quadraticBezierTo(tip.dx + tipSize * 1.2, tip.dy + tipSize * 1.4,
            tip.dx + tipSize * 1.4, tip.dy + tipSize)
        ..lineTo(tip.dx + tipSize * 1.5, tip.dy),
    };

    canvas.drawRRect(r, _mainPaint);
    // canvas.drawRRect(r, _strokePaint);
    if (tipPosition != BalloonTipPosition.none) {
      canvas.drawPath(path, _mainPaint);
      // canvas.drawPath(path, _strokePaint);
    }
  }
}
