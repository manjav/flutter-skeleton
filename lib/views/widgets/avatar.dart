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
        print("avatar_${expression.name}");
        controller!.getTriggerInput("avatar_${expression.name}")?.change(true);
        artboard.addController(controller);
      },
      width: size,
      height: size,
    );
  }
}
