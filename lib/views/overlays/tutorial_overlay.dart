import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class TutorialOverlay extends AbstractOverlay {
  final Alignment center;
  final VoidCallback? onTap;
  final bool showBackground;
  final bool showHand;
  final Alignment? handPosition;
  final bool showCharacter;
  final String? characterName;
  final String? newRoute;
  final String text;
  final DialogueSide dialogueSide;
  final int handQuarterTurns;
  final bool showFocus;
  final Size? characterSize;
  final double? bottom;
  final ValueNotifier<bool> ignorePointer;
  final double? radius;
  final double? dialogueHeight;

  const TutorialOverlay({
    required this.center,
    required this.ignorePointer,
    this.onTap,
    this.showBackground = true,
    this.showHand = true,
    this.handPosition,
    this.showCharacter = true,
    this.characterName,
    this.newRoute,
    this.text = "",
    this.dialogueSide = DialogueSide.left,
    this.handQuarterTurns = 0,
    this.showFocus = false,
    this.characterSize,
    this.bottom,
    this.radius,
    this.dialogueHeight,
    super.key,
  }) : super(route: newRoute ?? OverlaysName.tutorial);

  @override
  createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends AbstractOverlayState<TutorialOverlay> {
  ValueNotifier<bool> show = ValueNotifier<bool>(false);
  bool isEnded = false;

  @override
  void initState() {
    Future.delayed(300.ms, () => show.value = true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var page = Size(Get.width, Get.height);
    var offset = widget.showHand && widget.handPosition != null
        ? Offset(widget.handPosition!.alongSize(page).dx,
            widget.handPosition!.alongSize(page).dy)
        : const Offset(0, 0);
    return ValueListenableBuilder(
      valueListenable: widget.ignorePointer,
      builder: (context, value, child) => IgnorePointer(
        ignoring: value,
        child: GestureDetector(
          onTap: () async {
            if (!isEnded) return;
            show.value = false;
            await Future.delayed(700.ms);
            if (widget.onTap != null) widget.onTap!();
          },
          child: Container(
            height: Get.height,
            width: Get.width,
            color:
                widget.showBackground ? TColors.black25 : TColors.transparent,
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.showFocus
                    ? Container(
                        width: Get.width,
                        height: Get.height,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: widget.center,
                            // focalRadius: 0.1,
                            // focal: Alignment.center,
                            // transform: const GradientRotation(pi / 4),
                            radius: widget.radius ?? 0.6,
                            colors: <Color>[
                              TColors.black.withOpacity(0.0),
                              TColors.black80,
                            ],
                            stops: const <double>[0.41, 0.46],
                          ),
                        ),
                      )
                    : const SizedBox(),
                widget.showCharacter
                    ? TutorialCharacter(
                        show: show,
                        text: widget.text,
                        dialogueSide: widget.dialogueSide,
                        bottom: widget.bottom ?? 400.d,
                        characterName: widget.characterName,
                        characterSize: widget.characterSize,
                        dialogueHeight: widget.dialogueHeight,
                        onEnd: () => isEnded = true,
                      )
                    : const SizedBox(),
                widget.showHand
                    ? TutorialHand(
                        target: offset,
                        quarterTurns: widget.handQuarterTurns,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
