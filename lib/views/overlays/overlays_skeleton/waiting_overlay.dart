import 'package:flutter/material.dart';

import '../../../skeleton/skeleton.dart';
import 'overlay.dart';

class WaitingOverlay extends AbstractOverlay {
  final String message;
  const WaitingOverlay(this.message, {super.key})
      : super(type: OverlayType.toast);

  @override
  createState() => _WaitingOverlayState();
}

class _WaitingOverlayState extends AbstractOverlayState<WaitingOverlay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: TColors.black80,
        body: Center(child: SkinnedText(widget.message)));
  }
}
