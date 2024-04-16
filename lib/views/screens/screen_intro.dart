import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fruitcraft/app_export.dart';
import 'package:get/get.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  ValueNotifier<int> step = ValueNotifier(1);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      step.value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Widgets.touchable(
      context,
      onTapDown: (data) {
        step.value++;
        Future.delayed(Duration(milliseconds: 300), () {
          step.value++;
        });
      },
      child: Stack(
        children: [
          LoaderWidget(
            AssetType.image,
            "background_dust",
            subFolder: "backgrounds",
            height: Get.height,
            width: Get.width,
          ),
          // Positioned(
          //   top: 82.d,
          //   left: 59.d,
          //   child: SkinnedButton(
          //     label: "tribe_new".l(),
          //     width: 380.d,
          //     onPressed: () async {},
          //     color: ButtonColor.violet,
          //   ),
          // ),
          ValueListenableBuilder<int>(
            valueListenable: step,
            builder: (BuildContext context, int value, Widget? child) {
              return AnimatedPositioned(
                duration: 300.ms,
                bottom: value > 2 ? 1200.d : 800.d,
                left: value <= 4 ? 50.d : -500.d,
                child: LoaderWidget(
                  AssetType.image,
                  "character_olive",
                  subFolder: "tutorial",
                  height: 382.d,
                  width: 330.d,
                ),
              );
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: step,
            builder: (BuildContext context, int value, Widget? child) {
              return AnimatedPositioned(
                duration: 300.ms,
                bottom: value > 2 ? 1250.d : 850.d,
                left: value <= 4 ? 330.d : -800.d,
                width: 600.d,
                height: 236.d,
                child: Dialogue(
                  text: "".l(),
                  side: DialogueSide.left,
                ),
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: step,
            builder: (context, value, child) {
              return AnimatedPositioned(
                duration: 300.ms,
                bottom: value > 5 ? 200.d : -800.d,
                right: value > 4 ? 50.d : -400.d,
                child: LoaderWidget(
                  AssetType.image,
                  "character_sarhang",
                  subFolder: "tutorial",
                  height: 382.d,
                  width: 330.d,
                ),
              );
            },
          ),
          ValueListenableBuilder(
              valueListenable: step,
              builder: (context, value, child) {
                return AnimatedPositioned(
                  duration: 300.ms,
                  bottom: value > 6 ? 300.d : -900.d,
                  right: value > 5 ? 400.d : -900.d,
                  width: 600.d,
                  height: 236.d,
                  child: Dialogue(
                    text: "".l(),
                    // alignment: ,
                  ),
                );
              }),
          // Positioned(
          //   bottom: 526.d,
          //   left: 0,
          //   right: 0,
          //   child: Column(
          //     children: [
          //       Dialogue(
          //         text: "".l(),
          //       ),
          //       LoaderWidget(
          //         AssetType.image,
          //         "character_porteghula",
          //         subFolder: "tutorial",
          //         height: 859.d,
          //         width: 666.d,
          //       ),
          //     ],
          //   ),
          // ),
          // Positioned(
          //   bottom: 200.d,
          //   right: 50.d,
          //   child: LoaderWidget(
          //     AssetType.image,
          //     "character_sarhang",
          //     subFolder: "tutorial",
          //     height: 382.d,
          //     width: 330.d,
          //   ),
          // ),
          // Positioned(
          //   bottom: 300.d,
          //   right: 400.d,
          //   width: 650.d,
          //   height: 256.d,
          //   child: Dialogue(
          //     text: "".l(),
          //   ),
          // ),
        ],
      ),
    );
  }
}
