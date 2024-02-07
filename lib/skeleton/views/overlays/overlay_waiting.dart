import 'package:flutter/material.dart';

import '../../../app_export.dart';

class WaitingOverlay extends AbstractOverlay {
  final String message;
  const WaitingOverlay(this.message, {super.key})
      : super(route: OverlaysName.waiting);

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
