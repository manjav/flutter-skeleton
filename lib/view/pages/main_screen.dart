import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../utils/utils.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: Center(
          child: RiveAnimation.asset('anims/${Asset.prefix}map.riv',
              onInit: (Artboard artboard) {
            final controller = StateMachineController.fromArtboard(
              artboard,
              'Map',
              onStateChange: (state, animation) {
                print("---$animation");
              },
            );
            controller!.findInput<bool>('shop-press') as SMIBool;
            // _closeInput = controller.findInput<bool>('close') as SMIBool;
            artboard.addController(controller);
          }, fit: BoxFit.fitWidth),
        ),
      ),
    );
  }
}
