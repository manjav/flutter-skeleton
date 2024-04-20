import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app_export.dart';

class TutorialCharecter extends StatefulWidget {
  final ValueNotifier<bool> show;
  final String text;
  final String? charecterName;
  final DialogueSide dialogueSide;
  final double? bottom;
  const TutorialCharecter({
    required this.show,
    required this.text,
    this.charecterName,
    this.dialogueSide = DialogueSide.left,
    this.bottom,
    super.key,
  });

  @override
  State<TutorialCharecter> createState() => _TutorialCharecterState();
}

class _TutorialCharecterState extends State<TutorialCharecter> {
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
        return Stack(
          children: [
            AnimatedPositioned(
              duration: 300.ms,
              bottom: widget.bottom ?? 800.d,
              left: widget.dialogueSide == DialogueSide.right
                  ? value
                      ? 50.d
                      : -500.d
                  : null,
              right: widget.dialogueSide == DialogueSide.left
                  ? value
                      ? 50.d
                      : -500.d
                  : null,
              child: LoaderWidget(
                AssetType.image,
                widget.charecterName ?? "character_sarhang",
                subFolder: "tutorial",
                height: 382.d,
                width: 330.d,
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
                  height: 280.d,
                  child: Dialogue(
                    text: widget.text.l(),
                    side: widget.dialogueSide,
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}
