import 'package:flutter/material.dart';

import '../../../app_export.dart';

class GoldOverlay extends AbstractOverlay {
  final int count;
  final Offset? offset;
  final String route;
  const GoldOverlay(this.count, this.route, {this.offset, super.key})
      : super(route: route);

  @override
  createState() => _GoldOverlayState();
}

class _GoldOverlayState extends AbstractOverlayState<GoldOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  var position = DeviceInfo.size.center(Offset.zero);
  var duration = const Duration(milliseconds: 3000);
  int directionMultiper = 1;

  @override
  void initState() {
    //get global position of widget.target
    if (widget.offset != null) {
      position = widget.offset!;
    }
    directionMultiper = widget.count > 0 ? 1 : -1;

    animationController = AnimationController(
        vsync: this, duration: duration, upperBound: 100.d, lowerBound: 1);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        animationController.dispose;
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
    var paddingTop = MediaQuery.of(context).viewPadding.top;
    if (paddingTop <= 0) {
      paddingTop = 24.d;
    }
    return IgnorePointer(
      child: Scaffold(
        backgroundColor: TColors.transparent,
        body: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                double opacity =
                    (1.0 - (animationController.value.abs() / 100.d))
                        .clamp(0, 1);
                return Positioned(
                  top: paddingTop +
                      22.d -
                      (animationController.value * directionMultiper),
                  // top: paddingTop -
                  //     (animationController.value * directionMultiper),
                  right: 360.d + 75.d,
                  child: Opacity(
                    opacity: opacity,
                    child: SkinnedText(
                      widget.count.compact(),
                      style: TStyles.medium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
