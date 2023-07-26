import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/widgets.dart';
import '../../view/widgets/skinnedtext.dart';
import 'ioverlay.dart';

class ToastOverlay extends AbstractOverlay {
  final String message;
  const ToastOverlay(this.message, {super.key})
      : super(type: OverlayType.toast);

  @override
  createState() => _ToastOverlayState();
}

class _ToastOverlayState extends AbstractOverlayState<ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  var position = DeviceInfo.size.center(Offset.zero);
  var duration = const Duration(seconds: 3);

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: duration);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        close();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(onRender);
    super.initState();
  }

  @protected
  void onRender(Duration timeStamp) {
    animationController.animateTo(animationController.upperBound,
        curve: Curves.easeOutExpo, duration: duration);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: true,
        child: Scaffold(
            backgroundColor: TColors.transparent,
            body: Stack(alignment: Alignment.center, children: [
              AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    double opacity =
                        (1.0 - animationController.value).clamp(0, 1 / 80) * 80;
                    return Positioned(
                        top: position.dy -
                            animationController.value * 32.d -
                            300.d,
                        child: Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                              scaleX:
                                  animationController.value.clamp(0, 1 / 4) * 4,
                              scaleY:
                                  animationController.value.clamp(0, 1 / 3) * 3,
                              child: Widgets.rect(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 40.d),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: Asset.load<Image>('ui_shadow')
                                              .image)),
                                  child: SkinnedText(widget.message,
                                      style: TStyles.large))),
                        ));
                  })
            ])));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}