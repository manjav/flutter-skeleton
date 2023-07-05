import 'package:flutter/material.dart';

import '../services/deviceinfo.dart';
import '../services/theme.dart';

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
          constraints: BoxConstraints.tight(Size(400.d, 156.d)),
          width: width,
          height: height,
          alignment: alignment ?? Alignment.center,
          transform: transform,
          transformAlignment: transformAlignment,
          padding: padding,
          margin: margin,
          decoration: decoration,
          foregroundDecoration: foregroundDecoration,
          radius: radius ?? 16.d,
          borderRadius: borderRadius,
          color: color ?? TColors.transparent,
          child: child,
        ));
  }
}
