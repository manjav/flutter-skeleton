import 'package:flutter/material.dart';
import 'package:flutter_skeleton/views/overlays_name.dart';

import '../../../skeleton/skeleton.dart';
import 'overlay.dart';

class WaitingOverlay extends AbstractOverlay {
  final String message;
  const WaitingOverlay(this.message, {super.key})
      : super(route: OverlaysName.OVERLAY_WAITING);

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
