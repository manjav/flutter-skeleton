import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class TutorialCharacter extends StatefulWidget {
  final ValueNotifier<bool> show;
  final String text;
  final String? characterName;
  final DialogueSide dialogueSide;
  final double? bottom;
  final Size? characterSize;
  final double? dialogueHeight;
  const TutorialCharacter({
    required this.show,
    required this.text,
    this.characterName,
    this.dialogueSide = DialogueSide.left,
    this.bottom,
    this.characterSize,
    this.dialogueHeight,
    super.key,
  });

  @override
  State<TutorialCharacter> createState() => _TutorialCharecterState();
}

class _TutorialCharecterState extends State<TutorialCharacter> {
  ValueNotifier<bool> dialogueNotifier = ValueNotifier(false);

  @override
  void initState() {
    widget.show.addListener(() {
      Future.delayed(300.ms, () {
        dialogueNotifier.value = widget.show.value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.show,
      builder: (context, value, child) {
        return widget.dialogueSide == DialogueSide.right ||
                widget.dialogueSide == DialogueSide.left
            ? renderHorizontal(value)
            : renderVertical(value);
      },
    );
  }

  Widget renderHorizontal(bool show) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: 300.ms,
          bottom: widget.bottom ?? 800.d,
          left: widget.dialogueSide == DialogueSide.right
              ? show
                  ? 50.d
                  : -500.d
              : null,
          right: widget.dialogueSide == DialogueSide.left
              ? show
                  ? 50.d
                  : -500.d
              : null,
          child: LoaderWidget(
            AssetType.image,
            widget.characterName ?? "character_sarhang",
            subFolder: "tutorial",
            height: widget.characterSize?.height ?? 382.d,
            width: widget.characterSize?.width ?? 330.d,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: dialogueNotifier,
          builder: (context, value, child) {
            return AnimatedPositioned(
              duration: 400.ms,
              bottom: (widget.bottom ?? 800.d) + 50.d,
              left: widget.dialogueSide == DialogueSide.right
                  ? value
                      ? 330.d
                      : -800.d
                  : null,
              right: widget.dialogueSide == DialogueSide.left
                  ? value
                      ? 370.d
                      : -800.d
                  : null,
              width: 600.d,
              height: widget.dialogueHeight ?? 350.d,
              child: Dialogue(
                text: widget.text.l(),
                side: widget.dialogueSide,
              ),
            );
          },
        )
      ],
    );
  }

  Widget renderVertical(bool show) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: 300.ms,
          bottom: show ? (widget.bottom ?? 300.d) : -1500.d,
          left: 0,
          right: 0,
          child: LoaderWidget(
            AssetType.image,
            widget.characterName ?? "character_sarhang",
            subFolder: "tutorial",
            height: widget.characterSize?.height ?? 382.d,
            width: widget.characterSize?.width ?? 330.d,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: dialogueNotifier,
          builder: (context, value, child) {
            return AnimatedPositioned(
              duration: 400.ms,
              bottom: value
                  ? ((widget.characterSize?.height ?? 382.d) +
                      (widget.bottom ?? 300.d))
                  : -1800.d,
              left: Get.width - 850.d,
              width: 600.d,
              height: widget.dialogueHeight ?? 280.d,
              child: Dialogue(
                text: widget.text.l(),
                side: widget.dialogueSide,
              ),
            );
          },
        )
      ],
    );
  }
}
