import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fruitcraft/app_export.dart';
import 'package:get/get.dart';

class IntroScreen extends AbstractScreen {
  IntroScreen({super.key}) : super(Routes.intro);

  @override
  createState() => _IntroScreenState();
}

class _IntroScreenState extends AbstractScreenState<IntroScreen> {
  @override
  appBarElementsLeft() => [];

  @override
  appBarElementsRight() => [];

  @override
  void onTutorialFinish(data) {
    Get.toNamed(Routes.deck);
    super.onTutorialFinish(data);
  }

  @override
  Widget contentFactory() {
    return Stack(
      children: [
        LoaderWidget(
          AssetType.image,
          "background_dust",
          subFolder: "backgrounds",
          height: Get.height,
          width: Get.width,
        ),
        Positioned(
          top: 82.d,
          left: 59.d,
          child: SkinnedButton(
            label: "tribe_new".l(),
            width: 380.d,
            onPressed: () async {},
            color: ButtonColor.violet,
          ),
        ),
      ],
    );
  }
}
