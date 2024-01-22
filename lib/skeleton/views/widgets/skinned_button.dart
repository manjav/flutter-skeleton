import 'package:flutter/widgets.dart';

import '../../export.dart';

enum ButtonColor { cream, gray, green, violet, teal, wooden, yellow }

enum ButtonSize { small, medium }

class SkinnedButton extends StatefulWidget {
  final String? label;
  final String? icon;
  final ButtonColor color;
  final ButtonSize size;
  final Widget? child;
  final int buttonId;
  final double? width;
  final double? height;
  final bool isEnable;
  final Alignment? alignment;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Function()? onPressed;
  final Function()? onDisablePressed;
  final BoxConstraints? constraints;
  const SkinnedButton({
    this.label,
    this.icon,
    this.color = ButtonColor.yellow,
    this.size = ButtonSize.small,
    this.child,
    this.buttonId = 30,
    this.width,
    this.height,
    this.isEnable = true,
    this.alignment,
    this.margin,
    this.padding,
    this.onPressed,
    this.onDisablePressed,
    this.constraints,
    super.key,
  });

  @override
  State<SkinnedButton> createState() => _SkinnedButtonState();

  static buttonDecorator(ButtonColor color,
      [bool isPressed = false, ButtonSize size = ButtonSize.small]) {
    var slicingData = switch (size) {
      ButtonSize.small =>
        ImageCenterSliceData(102, 106, const Rect.fromLTWH(50, 30, 4, 20)),
      _ => ImageCenterSliceData(130, 158),
    };
    var assetName = "button_${size.name}_${color.name}";
    if (isPressed) {
      assetName += "_down";
    }
    return Widgets.imageDecorator(assetName, slicingData);
  }
}

class _SkinnedButtonState extends State<SkinnedButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    var color = !widget.isEnable ? ButtonColor.gray : widget.color;
    return Widgets.button(
      context,
      onTapUp: (details) {
        setState(() => _isPressed = false);
        (widget.isEnable ? widget.onPressed : widget.onDisablePressed)?.call();
      },
      onTapDown: (details) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      width: widget.width,
      height: widget.height,
      buttonId: widget.buttonId,
      alignment: widget.alignment ?? Alignment.center,
      constraints: widget.constraints,
      margin: widget.margin,
      padding: widget.padding ??
          EdgeInsets.fromLTRB(28.d, 25.d, 28.d, _isPressed ? 40.d : 44.d),
      decoration: SkinnedButton.buttonDecorator(color, _isPressed, widget.size),
      child: Opacity(
          opacity: widget.isEnable ? 1 : 0.7,
          child: widget.label != null || widget.icon != null
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  widget.icon == null
                      ? const SizedBox()
                      : Asset.load<Image>(widget.icon!, height: 68.d),
                  SizedBox(
                      width: (widget.label != null && widget.icon != null)
                          ? 16.d
                          : 0),
                  widget.label == null
                      ? const SizedBox()
                      : SkinnedText(widget.label!,
                          style: TStyles.large,
                          shadowScale: _isPressed ? 1.2 : 1),
                ])
              : widget.child!),
    );
  }
}
