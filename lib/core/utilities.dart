import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

showOverlay(
    BuildContext context, OverlayEntry overlayEntry, SMIBool? closeInput) {
  final overlay = Overlay.of(context);

  overlayEntry =
      OverlayEntry(builder: (context) => const Center(child: FlutterLogo()));

  overlay.insert(overlayEntry);

  // await Future.delayed(Duration(seconds: 2));
}
