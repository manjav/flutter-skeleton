import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_export.dart';

class Widgets {
  static GestureDetector touchable(
    BuildContext context, {
    String? sfx,
    int id = 30,
    Function()? onTap,
    Function(TapUpDetails details)? onTapUp,
    Function(dynamic details)? onTapDown,
    Function()? onTapCancel,
    Function()? onLongPress,
    Widget? child,
  }) {
    return GestureDetector(
        onTap: () {
          if (_isActive(id)) onTap?.call();
        },
        onTapUp: _isActive(id)
            ? (details) {
                serviceLocator<Sounds>().play(sfx ?? "mouse_up");
                onTapUp?.call(details);
              }
            : null,
        onTapDown: _isActive(id)
            ? (details) {
                if (sfx == null) {
                  serviceLocator<Sounds>().play("mouse_down");
                }
                onTapDown?.call(details);
              }
            : null,
        onTapCancel: () {
          if (_isActive(id)) {
            serviceLocator<Sounds>().play(sfx ?? "mouse_up");
            onTapCancel?.call();
          }
        },
        onLongPress: _isActive(id) ? onLongPress?.call() : null,
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

  static Widget button(
    BuildContext context, {
    Function()? onPressed,
    Function(dynamic details)? onTapDown,
    Function(TapUpDetails)? onTapUp,
    Function()? onTapCancel,
    Function()? onLongPress,
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
    return touchable(context,
        id: buttonId,
        onTap: onPressed,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        onLongPress: onLongPress,
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

  static BoxDecoration imageDecorator(String path,
      [ImageCenterSliceData? sliceData]) {
    return BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.fill,
            image: Asset.load<Image>(path, centerSlice: sliceData).image,
            centerSlice: sliceData?.centerSlice));
  }

  static divider(
      {double? width,
      double? height,
      double margin = 0,
      Axis direction = Axis.horizontal,
      BoxDecoration? decoration}) {
    var v = direction == Axis.vertical;
    return rect(
        width: width ?? 16.d,
        height: height ?? 16.d,
        margin: EdgeInsets.all(margin),
        decoration: decoration ??
            imageDecorator("ui_divider_${v ? 'v' : 'h'}",
                ImageCenterSliceData(v ? 16 : 38, v ? 38 : 16)));
  }

  static slider(double min, double value, double max,
      {Widget? child,
      double? width,
      double? height,
      double? border,
      Color? borderColor,
      double? padding,
      double? radius,
      Color? backgroundColor,
      Color progressColor = TColors.green}) {
    var w = width ?? 760.d;
    var h = height ?? 104.d;
    var p = padding ?? 9.d;
    var r = (1 - value / (max - min)).clamp(0, 1);
    return rect(
      width: w,
      height: h,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 24.d)),
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
            radius: radius != null ? radius - 8.d : 16.d),
        child ?? const SizedBox()
      ]),
    );
  }

  static Widget skinnedInput({
    bool autofocus = false,
    String? hintText,
    Widget? suffixIcon,
    double? width,
    int? maxLength,
    int? maxLines,
    double radius = 8,
    TextEditingController? controller,
    Function(String)? onChange,
    Function(String)? onSubmit,
    Color? borderColor,
  }) {
    var style = TStyles.medium.copyWith(height: 1.5);
    return rect(
        radius: radius,
        color: TColors.primary,
        width: width ?? 720.d,
        child: TextField(
            style: style,
            maxLines: maxLines,
            autofocus: autofocus,
            maxLength: maxLength == 1 ? null : maxLength,
            controller: controller,
            textAlign: TextAlign.center,
            onChanged: onChange,
            onSubmitted: onSubmit,
            onTapOutside: (p) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              hintStyle: style,
              hintText: hintText,
              contentPadding: EdgeInsets.all(16.d),
              suffixIcon: suffixIcon,
              border: _getBorder(radius, borderColor: borderColor),
              enabledBorder: _getBorder(radius, borderColor: borderColor),
              focusedBorder: _getBorder(radius, borderColor: borderColor),
              errorBorder: _getBorder(radius, borderColor: borderColor),
              disabledBorder: _getBorder(radius, borderColor: borderColor),
            )));
  }

  static OutlineInputBorder _getBorder(double radius, {Color? borderColor}) =>
      OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          borderSide:
              BorderSide(color: borderColor ?? TColors.primary80, width: 2));

  static Widget clipboardGetter(BuildContext context, String text,
      {double? width, double? height,VoidCallback? onCopy}) {
    return button(context,
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
        onPressed: () {
          onCopy?.call();
          return Clipboard.setData(ClipboardData(text: text));
        });
  }

  static checkbox(BuildContext context, String label, bool isSelected,
      {Function()? onSelect}) {
    return button(context,
        onPressed: onSelect,
        child: Row(children: [
          SkinnedText(label),
          SizedBox(width: 12.d),
          Asset.load<Image>("checkbox_${isSelected ? "on" : "off"}",
              width: 64.d)
        ]));
  }
}
