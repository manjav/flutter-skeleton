import 'package:flutter/widgets.dart';

import '../../../app_export.dart';

class SkinnedButton extends StatelessWidget {
  final int buttonId;
  final Color? color;
  final String? label;
  final String? icon;
  final Widget? child;
  final bool isEnable;
  final double? width;
  final double? height;
  final double? cornerRadius;
  final Alignment? alignment;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Function()? onPressed;
  final Function()? onDisablePressed;
  final BoxConstraints? constraints;
  SkinnedButton({
    this.buttonId = 30,
    this.color,
    this.label,
    this.icon,
    this.child,
    this.width,
    this.height,
    this.cornerRadius,
    this.isEnable = true,
    this.alignment,
    this.margin,
    this.padding,
    this.onPressed,
    this.onDisablePressed,
    this.constraints,
    super.key,
  });

  final ValueNotifier<bool> _isPressed = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    var strokeSize = 3.d;
    return Widgets.touchable(
      context,
      id: buttonId,
      onTapUp: (details) {
        _isPressed.value = false;
        (isEnable ? onPressed : onDisablePressed)?.call();
      },
      onTapDown: (details) => _isPressed.value = true,
      onTapCancel: () => _isPressed.value = false,
      child: ValueListenableBuilder(
        valueListenable: _isPressed,
        builder: (context, value, childs) {
          return Widgets.rect(
            width: width,
            height: height,
            alignment: alignment ?? Alignment.center,
            constraints: constraints,
            margin: margin ?? EdgeInsets.zero,
            padding: padding ??
                EdgeInsets.fromLTRB(
                    16.d,
                    8.d + (_isPressed.value ? strokeSize : 0),
                    16.d,
                    8.d - (_isPressed.value ? strokeSize : 0)),
            decoration: BattonDecoration(
                mainColor: color,
                isPressed: _isPressed.value,
                strokeSize: strokeSize),
            child: Opacity(
                opacity: isEnable ? 1 : 0.7,
                child: label != null || icon != null
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        icon == null
                            ? const SizedBox()
                            : Asset.load<Image>(icon!, height: 68.d),
                        SizedBox(
                            width: (label != null && icon != null) ? 16.d : 0),
                        label == null
                            ? const SizedBox()
                            : Text(label!, style: TStyles.largeInvert),
                      ])
                    : child!),
          );
        },
      ),
    );
  }
}
