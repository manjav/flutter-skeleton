import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

showOverlay(
    BuildContext context, OverlayEntry overlayEntry, SMIBool? closeInput) {
  final overlay = Overlay.of(context);

  overlayEntry =
      OverlayEntry(builder: (context) => Center(child: FlutterLogo()));

  overlay.insert(overlayEntry);

  // await Future.delayed(Duration(seconds: 2));
}
