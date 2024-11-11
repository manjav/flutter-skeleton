import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

enum AvatarExpression { idle, happy, greetings, point }

class Avatar extends StatefulWidget {
  final double size;
  final AvatarExpression expression;

  const Avatar({
    required this.expression,
    required this.size,
    super.key,
  });

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  SMITrigger? _trigger;
  @override
  Widget build(BuildContext context) {
    return LoaderWidget(
      AssetType.animation,
      "avatar_0",
      onRiveInit: (artboard) {
        final controller =
            StateMachineController.fromArtboard(artboard, "State Machine 1");
        _trigger =
            controller!.getTriggerInput("avatar_${widget.expression.name}");
        controller.addEventListener(_onRiveEvent);
        artboard.addController(controller);
      },
      width: widget.size * 1.5,
      height: widget.size,
    );
  }

  void _onRiveEvent(RiveEvent event) {
    if (event.name == "ready") {
      _trigger?.fire();
    }
  }
}
