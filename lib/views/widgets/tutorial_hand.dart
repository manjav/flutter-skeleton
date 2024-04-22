import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app_export.dart';

class TutorialHand extends StatefulWidget {
  final Offset target;
  final int quarterTurns;
  const TutorialHand({
    required this.target,
    this.quarterTurns = 0,
    super.key,
  });

  @override
  State<TutorialHand> createState() => _TutorialHandState();
}

class _TutorialHandState extends State<TutorialHand> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: 300.ms,
      left: widget.target.dx,
      top: widget.target.dy,
      child: RotatedBox(
        quarterTurns: widget.quarterTurns,
        child: LoaderWidget(
          AssetType.image,
          "pointer_hand",
          subFolder: "tutorial",
          height: 230.d,
          width: 195.d,
        ),
      ),
    );
  }
}
