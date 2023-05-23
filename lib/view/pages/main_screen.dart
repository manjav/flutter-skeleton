import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../utils/utils.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // SMIBool? _closeInput;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Stack(
        children: [
          Center(
            child: RiveAnimation.asset('anims/${Asset.prefix}map.riv',
                onInit: (Artboard artboard) {
              final controller = StateMachineController.fromArtboard(
                artboard,
                'Map',
                onStateChange: (state, animation) {
                  debugPrint("---$animation");
                },
              );
              controller!.findInput<int>('mine')?.value = 3;
              controller.findInput<int>('military')?.value = 3;

              // _closeInput = controller.findInput<bool>('close') as SMIBool;
              artboard.addController(controller);
            }, fit: BoxFit.fitWidth),
          ),
          CupertinoButton(
              child: Text("data"),
              onPressed: () {
                setState(() {});
              })
        ],
      ),
    );
  }
}
