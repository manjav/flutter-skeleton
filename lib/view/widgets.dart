import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    BoxConstraints? constraints,
    required Widget child,
  }) {
    return touchable(
        id: buttonId,
        onTap: onPressed,
        child: rect(
          width: width,
          height: height,
          constraints: constraints,
          alignment: alignment,
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

  static skinnedButton({
    String? label,
    String? icon,
    ButtonColor color = ButtonColor.yellow,
    ButtonSize size = ButtonSize.small,
    Widget? child,
    int buttonId = 30,
    double? width,
    double? height,
    bool isEnable = true,
    Alignment? alignment,
    EdgeInsets? padding,
    Function()? onPressed,
    Function()? onDisablePressed,
    BoxConstraints? constraints,
  }) {
    var slicingData = switch (size) {
      ButtonSize.small =>
        ImageCenterSliceDate(102, 106, const Rect.fromLTWH(50, 30, 2, 46)),
      _ => ImageCenterSliceDate(130, 158, const Rect.fromLTWH(64, 50, 2, 58)),
    };
    if (!isEnable) {
      color = ButtonColor.gray;
    }
    return Widgets.button(
        onPressed: isEnable ? onPressed : onDisablePressed,
        width: width,
        height: height,
        buttonId: buttonId,
        alignment: alignment ?? Alignment.center,
        constraints: constraints,
        padding: padding ?? EdgeInsets.fromLTRB(28.d, 25.d, 28.d, 40.d),
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                centerSlice: slicingData.centerSlice,
                image: Asset.load<Image>(
                  "ui_button_${size.name}_${color.name}",
                  centerSlice: slicingData,
                ).image)),
        child: Opacity(
            opacity: isEnable ? 1 : 0.7,
            child: label != null || icon != null
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    icon == null
                        ? const SizedBox()
                        : Asset.load<Image>(icon, height: 68.d),
                    SizedBox(width: (label != null && icon != null) ? 16.d : 0),
                    label == null
                        ? const SizedBox()
                        : SkinnedText(label, style: TStyles.large),
                  ])
                : child!));
  }

  static divider(
      {double? width,
      double? height,
      double margin = 0,
      Axis direction = Axis.horizontal}) {
    var v = direction == Axis.vertical;
    var slicingData = ImageCenterSliceDate(v ? 16 : 38, v ? 38 : 16);
    return rect(
        width: width ?? 16.d,
        height: height ?? 16.d,
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                centerSlice: slicingData.centerSlice,
                image: Asset.load<Image>(
                  "ui_divider_${v ? 'v' : 'h'}",
                  centerSlice: slicingData,
                ).image)));
  }

  static slider(double min, double value, double max,
      {Widget? child,
      double? width,
      double? height,
      double? border,
      Color? borderColor,
      double? padding,
      Color? backgroundColor,
      Color progressColor = TColors.green}) {
    var w = width ?? 760.d;
    var h = height ?? 104.d;
    var p = padding ?? 9.d;
    var r = 1 - value / (max - min);
    return rect(
      width: w,
      height: h,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(56.d)),
          color: backgroundColor ?? TColors.primary10),
      child: Stack(alignment: Alignment.center, children: [
        rect(
            margin: EdgeInsets.only(
                top: p, left: p, bottom: p, right: r * w + (1 - r) * p),
            gradient: LinearGradient(
              colors: [
                progressColor,
                progressColor.withAlpha(180),
                progressColor.withAlpha(220),
              ],
              stops: const [0.3, 0.85, 1],
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
            ),
            radius: 44.d),
        child ?? const SizedBox()
      ]),
    );
  }

  static Widget skinnedInput(
      {bool autofocus = false,
      String? hintText,
      Widget? suffixIcon,
      double? width,
      double? height,
      TextEditingController? controller,
      Function(String)? onChanged}) {
    return SizedBox(
        width: width ?? 720.d,
        height: height,
        child: TextField(
            autofocus: autofocus,
            controller: controller,
            textAlign: TextAlign.center,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TStyles.medium,
              contentPadding: EdgeInsets.zero,
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.d))),
            )));
  }

  static Widget clipboardGetter(String text, {double? width, double? height}) {
    return button(
        width: width ?? 720.d,
        height: height ?? 120.d,
        margin: EdgeInsets.all(8.d),
        padding: EdgeInsets.symmetric(horizontal: 30.d),
        color: TColors.primary80,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SkinnedText(text),
          SizedBox(width: 16.d),
          Asset.load<Image>("icon_copy", width: 44.d)
        ]),
        onPressed: () => Clipboard.setData(ClipboardData(text: text)));
  }
}

enum ButtonColor { gray, green, teal, yellow }

enum ButtonSize { small, medium }
