import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../utils/assets.dart';

mixin BackgroundMixin<S extends StatefulWidget> on State<S> {
  SMINumber? _colorInput;
  Widget backgroundBuilder({int color = 0, bool animated = true}) {
    return Asset.load<RiveAnimation>("background_pattern", fit: BoxFit.fitWidth,
        onRiveInit: (Artboard artboard) {
      var controller =
          StateMachineController.fromArtboard(artboard, "State Machine 1");
      controller?.findInput<bool>("move")?.value = animated;
      _colorInput = controller?.findInput<double>("color") as SMINumber;
      changeBackgroundColor(color);
      artboard.addController(controller!);
    });
  }

  void changeBackgroundColor(int color) =>
      _colorInput?.value = color.toDouble();
}
