import 'package:flutter/material.dart';

import '../../app_export.dart';

enum DialogueSide { left, top, right, bottom }

class Dialogue extends StatelessWidget {
  final String text;
  final double? width;
  final double? height;
  final DialogueSide? side;
  const Dialogue({
    required this.text,
    this.width,
    this.height,
    this.side = DialogueSide.top,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double left = side == DialogueSide.right ? 20.d : 0;
    double right = side == DialogueSide.left ? 20.d : 0;
    double top = side == DialogueSide.top ? 20.d : 0;
    double bottom = side == DialogueSide.bottom ? 20.d : 0;
    return Stack(
      children: [
        Positioned(
          left: left,
          right: right,
          top: top,
          bottom: bottom,
          child: Widgets.rect(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.d),
              color: TColors.primary,
              border: Border.all(
                color: TColors.primary10,
                width: 6.d,
              ),
            ),
            width: width ?? 600.d,
            height: height ?? 236.d,
            padding: EdgeInsets.all(45.d),
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                text,
                style: TStyles.large
                    .autoSize(
                      text.length,
                      100,
                      38.d,
                    )
                    .copyWith(color: TColors.primary20),
              ),
            ),
          ),
        ),
        Align(
          alignment: side.toAlignment(),
          child: RotatedBox(
            quarterTurns: side.quarterTurns(),
            child: Asset.load<Image>(
              "dialogue_arrow_left",
              height: 30.d,
              width: 30.d,
            ),
          ),
        ),
      ],
    );
  }
}

extension DialogueExtension on DialogueSide? {
  Alignment toAlignment() {
    switch (this) {
      case DialogueSide.right:
        return const Alignment(-1, -0.35);
      case DialogueSide.top:
        return const Alignment(0, -1);
      case DialogueSide.left:
        return const Alignment(1, -0.35);
      case DialogueSide.bottom:
        return const Alignment(0, 1);
      default:
        return Alignment.centerLeft;
    }
  }

  int quarterTurns() {
    switch (this) {
      case DialogueSide.right:
        return 0;
      case DialogueSide.top:
        return 1;
      case DialogueSide.left:
        return 2;
      case DialogueSide.bottom:
        return 3;
      default:
        return 0;
    }
  }
}
