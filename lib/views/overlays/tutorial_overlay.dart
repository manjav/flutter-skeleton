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

  const TutorialOverlay({
    required this.center,
    this.onTap,
    this.showBackground = true,
    this.showHand = true,
    this.handPosition,
    this.showCharacter = true,
    this.characterName,
    this.newRoute,
    this.text = "",
    this.dialogueSide = DialogueSide.left,
    super.key,
  }) : super(route: newRoute ?? OverlaysName.tutorial);

  @override
  createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends AbstractOverlayState<TutorialOverlay> {
  ValueNotifier<bool> show = ValueNotifier<bool>(false);

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
    return GestureDetector(
      onTap: () async {
        show.value = false;
        await Future.delayed(700.ms);
        if (widget.onTap != null) widget.onTap!();
      },
      child: Container(
        height: Get.height,
        width: Get.width,
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.showBackground
                ? Container(
                    width: Get.width,
                    height: Get.height,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: widget.center,
                        radius: 0.3,
                        colors: <Color>[
                          Colors.white.withOpacity(0.0),
                          Colors.black54,
                        ],
                        stops: const <double>[0.4, 1.0],
                      ),
                    ),
                  )
                : const SizedBox(),
            widget.showCharacter
                ? TutorialCharecter(
                    show: show,
                    text: widget.text,
                    dialogueSide: widget.dialogueSide,
                    bottom: 400.d,
                    charecterName: widget.characterName,
                  )
                : const SizedBox(),
            widget.showHand
                ? TutorialHand(
                    target: offset,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
