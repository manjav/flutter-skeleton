import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

enum AvatarExpression { idle, happy, greetings, point }

class Avatar extends StatelessWidget {
  final double size;
  final AvatarExpression expression;
  const Avatar({
    required this.expression,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LoaderWidget(
      AssetType.animation,
      "avatar_0",
      onRiveInit: (artboard) {
        final controller =
            StateMachineController.fromArtboard(artboard, "State Machine 1");
        controller!
            .getNumberInput("state")
            ?.change(expression.index.toDouble());
        artboard.addController(controller);
      },
      width: size,
      height: size,
    );
  }
}
