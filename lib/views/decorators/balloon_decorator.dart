import 'package:flutter/cupertino.dart';

import '../../app_export.dart';

class Balloon extends StatefulWidget {
  final Alignment? alignment;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Matrix4? transform;
  final Alignment? transformAlignment;
  final Decoration? foregroundDecoration;
  final BalloonDecorationData? decorationData;
  final Widget? child;

  final double? tipSize;
  final BalloonTipPosition? tipPosition;

  const Balloon({
    super.key,
    this.tipSize,
    this.tipPosition,
    this.alignment,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.transform,
    this.transformAlignment,
    this.decorationData,
    this.foregroundDecoration,
    required this.child,
  });
  @override
  createState() => _BalloonState();
}

enum BalloonTipPosition {
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
  rightBottom
}

class _BalloonState extends State<Balloon> {
  @override
  Widget build(BuildContext context) {
    var padding = widget.padding ?? EdgeInsets.fromLTRB(10.d, 6.d, 10.d, 6.d);
    return Widgets.rect(
        child: Widgets.rect(
            alignment: widget.alignment ?? Alignment.center,
            padding: padding,
            decoration: BalloonDecoration(
                widget.decorationData,
                widget.tipSize ?? 10,
                widget.tipPosition ?? BalloonTipPosition.bottom),
            foregroundDecoration: widget.foregroundDecoration,
            margin: widget.margin,
            transform: widget.transform,
            transformAlignment: widget.transformAlignment,
            width: widget.width,
            height: widget.height ?? 56.d,
            child: widget.child));
  }
}

// ignore: must_be_immutable
class BalloonDecoration extends Decoration {
  final double tipSize;
  final BalloonTipPosition tipPosition;
  final BalloonDecorationData? data;

  late BalloonDecorationData dataFallback;
  BalloonDecoration(
    this.data,
    this.tipSize,
    this.tipPosition,
  ) : super() {
    if (data == null) {
      dataFallback = BalloonDecorationData(
        mainColor: TColors.primary10, //0
        borderColor: TColors.primary10,
        cornerRadius: 32.d,
        border: 4.d,
      );
    } else {
      dataFallback = BalloonDecorationData(
        mainColor: data!.mainColor,
        borderColor: data!.borderColor,
        cornerRadius: data!.cornerRadius ?? 32,
        border: data!.border ?? 12,
      );
    }
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ButtonPainter(dataFallback, tipSize, tipPosition);
  }
}

class _ButtonPainter extends BoxPainter {
  final double tipSize;
  final BalloonTipPosition tipPosition;
  final _mainPaint = Paint()
    ..style = PaintingStyle.fill
    ..color;
  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final BalloonDecorationData data;
  _ButtonPainter(
    this.data,
    this.tipSize,
    this.tipPosition,
  ) : super() {
    _mainPaint.color = data.mainColor!;
    _borderPaint.color = data.borderColor!;
    _borderPaint.strokeJoin = StrokeJoin.round;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (configuration.size!.width == 0 || configuration.size!.height == 0) {
      return;
    }
    // var b = 4.0.d;
    var cr = data.cornerRadius!;
    var r = RRect.fromLTRBXY(
        offset.dx,
        offset.dy,
        offset.dx + configuration.size!.width,
        offset.dy + configuration.size!.height,
        cr,
        cr);

    var l = _borderPaint.strokeWidth * 0.5;
    var tip = switch (tipPosition) {
      BalloonTipPosition.rightTop => Offset(r.right + l, r.top + cr + tipSize),
      BalloonTipPosition.right => Offset(r.right - l, r.center.dy + tipSize),
      BalloonTipPosition.rightBottom => Offset(r.right - l, r.bottom - cr),
      BalloonTipPosition.leftTop => Offset(r.left + l, r.top + cr + tipSize),
      BalloonTipPosition.left => Offset(r.left + l, r.center.dy + tipSize),
      BalloonTipPosition.leftBottom => Offset(r.left + l, r.bottom - cr),
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
          ..lineTo(tip.dx, tip.dy - tipSize * 1.4),
      BalloonTipPosition.leftTop ||
      BalloonTipPosition.left ||
      BalloonTipPosition.leftBottom =>
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx - tipSize, tip.dy - tipSize * 0.89)
          ..quadraticBezierTo(tip.dx - tipSize * 1.2, tip.dy - tipSize,
              tip.dx - tipSize, tip.dy - tipSize * 1.3)
          ..lineTo(tip.dx, tip.dy - tipSize * 1.4),
      _ => Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx + tipSize * 0.9, tip.dy + tipSize)
        ..quadraticBezierTo(tip.dx + tipSize * 1.2, tip.dy + tipSize * 1.4,
            tip.dx + tipSize * 1.4, tip.dy + tipSize)
        ..lineTo(tip.dx + tipSize * 1.5, tip.dy),
    };

    canvas.drawRRect(r, _mainPaint);
    canvas.drawRRect(r, _borderPaint);
    canvas.drawPath(path, _mainPaint);
    canvas.drawPath(path, _borderPaint);
  }
}

class BalloonDecorationData {
  final Color? mainColor;
  final Color? borderColor;
  final double? cornerRadius;
  final double? border;

  BalloonDecorationData({
    this.mainColor,
    this.borderColor,
    this.cornerRadius,
    this.border,
  });
}
