import 'package:flutter/material.dart';

import '../../view/widgets/skinnedtext.dart';
import '../services/deviceinfo.dart';
import '../services/theme.dart';
import '../utils/assets.dart';

class Widgets {
  static GestureDetector touchable({
    String? sfx,
    int id = 30,
    Function()? onTap,
    Function(TapUpDetails details)? onTapUp,
    Function(dynamic details)? onTapDown,
    Function()? onTapCancel,
    Function()? onLongPress,
    Function(DragStartDetails details)? onVerticalDragStart,
    Function(DragUpdateDetails details)? onVerticalDragUpdate,
    Function(DragEndDetails details)? onVerticalDragEnd,
    Widget? child,
  }) {
    return GestureDetector(
        onVerticalDragStart: onVerticalDragStart == null
            ? null
            : (details) {
                if (_isActive(id)) {
                  onVerticalDragStart(details);
                }
              },
        onVerticalDragUpdate: onVerticalDragUpdate == null
            ? null
            : (details) {
                if (_isActive(id)) {
                  onVerticalDragUpdate(details);
                }
              },
        onVerticalDragEnd: onVerticalDragEnd == null
            ? null
            : (details) {
                if (_isActive(id)) {
                  onVerticalDragEnd(details);
                }
              },
        onTap: () {
          if (_isActive(id)) {
            // services.get<Sounds>().play(sfx ?? "click");
            onTap?.call();
          }
        },
        onTapUp: (details) {
          if (_isActive(id)) {
            if (sfx == null) {
              // services.get<Sounds>().play("button-up");
            }
            onTapUp?.call(details);
          }
        },
        onTapDown: (details) {
          if (_isActive(id)) {
            if (sfx == null) {
              // services.get<Sounds>().play("button-down");
            }
            onTapDown?.call(details);
          }
        },
        onTapCancel: () {
          if (_isActive(id)) {
            onTapCancel?.call();
          }
        },
        onLongPress: () {
          if (_isActive(id)) {
            onLongPress?.call();
          }
        },
        child: child);
  }

  static bool _isActive(int id) {
    return true; //id == -1 || Prefs.tutorStep == id;
  }

  static Widget rect({
    Color? color,
    Alignment? alignment,
    BorderRadiusGeometry? borderRadius,
    double? radius,
    EdgeInsetsGeometry? padding,
    EdgeInsets? margin,
    Gradient? gradient,
    double? width,
    double? height,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    Matrix4? transform,
    Alignment? transformAlignment,
    BoxConstraints? constraints,
    Widget? child,
  }) {
    return Container(
      constraints: constraints,
      width: width,
      height: height,
      alignment: alignment,
      transform: transform,
      transformAlignment: transformAlignment,
      padding: padding,
      margin: margin,
      foregroundDecoration: foregroundDecoration,
      decoration: decoration ??
          BoxDecoration(
              gradient: gradient,
              borderRadius: borderRadius ??
                  BorderRadius.all(Radius.circular(radius ?? 0)),
              color: color),
      child: child,
    );
  }

  static Widget button({
    Function()? onPressed,
    int buttonId = 30,
    Color? color,
    Alignment? alignment,
    BorderRadiusGeometry? borderRadius,
    double? radius,
    EdgeInsetsGeometry? padding,
    EdgeInsets? margin,
    Gradient? gradient,
    double? width,
    double? height,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    Matrix4? transform,
    Alignment? transformAlignment,
    required Widget child,
  }) {
    return touchable(
        id: buttonId,
        onTap: onPressed,
        child: rect(
          width: width,
          height: height,
          alignment: alignment ?? Alignment.center,
          transform: transform,
          transformAlignment: transformAlignment,
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 32.d, vertical: 48.d),
          margin: margin,
          decoration: decoration,
          foregroundDecoration: foregroundDecoration,
          radius: radius ?? 16.d,
          borderRadius: borderRadius,
          color: color ?? TColors.transparent,
          child: child,
        ));
  }

  static labeledButton({
    String? label,
    String color = "yellow",
    String size = "small",
    Widget? child,
    int buttonId = 30,
    double? width,
    double? height,
    Alignment? alignment,
    Function()? onPressed,
  }) {
    if (size != "small") {
      size = "medium";
    }
    var slicingData = switch (size) {
      "small" =>
        ImageCenterSliceDate(102, 106, const Rect.fromLTWH(50, 30, 2, 46)),
      _ => ImageCenterSliceDate(130, 158, const Rect.fromLTWH(64, 50, 2, 58)),
    };
    return Widgets.button(
        onPressed: onPressed,
        width: width,
        height: height,
        buttonId: buttonId,
        alignment: alignment,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                centerSlice: slicingData.centerSlice,
                image: Asset.load<Image>(
                  "ui_button_${size}_$color",
                  centerSlice: slicingData,
                ).image)),
        child: label != null
            ? SkinnedText(label, style: TStyles.large.copyWith(height: 0.1))
            : child!);
  }

  static verticalDivider({double? height, double margin = 0}) {
    var slicingData = ImageCenterSliceDate(16, 38);
    return rect(
        width: 16.d,
        height: height,
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                centerSlice: slicingData.centerSlice,
                image: Asset.load<Image>(
                  "ui_divider_v",
                  centerSlice: slicingData,
                ).image)));
  }
}
