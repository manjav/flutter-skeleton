import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class BundleFeastOverlay extends AbstractOverlay {
  const BundleFeastOverlay({super.onClose, super.key})
      : super(route: OverlaysName.feastBundle);

  @override
  createState() => _BundleFeastOverlayState();
}

class _BundleFeastOverlayState extends AbstractOverlayState<BundleFeastOverlay>
    with RewardScreenMixin, TickerProviderStateMixin {
  late AnimationController _opacityAnimationController;

  @override
  void initState() {
    _opacityAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    startSFX = "prize";
    children = [
      animationBuilder("bundle"),
      _buttonBuy(),
    ];
    // todo: cooment for now because we dont have any data of bundle in response
    // var account = accountProvider.account;

    process(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      _opacityAnimationController.forward();
      return true;
    });

    super.initState();
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    updateRiveText("titleText", "wonderful_bundle".l());
    updateRiveText("titleText_stroke", "wonderful_bundle".l());
    updateRiveText("titleText_shadow", "wonderful_bundle".l());
    updateRiveText("timerText", "timer");
    updateRiveText("card0Text", "card0");
    updateRiveText("card1Text", "card1");
    updateRiveText("card2Text", "card2");
    updateRiveText("card3Text", "card3");

    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == RewardAnimationState.closing) {
      _opacityAnimationController.animateBack(0,
          duration: const Duration(milliseconds: 500));
    }
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (["cardIcon0", "cardIcon1", "cardIcon2", "cardIcon3"]
          .contains(asset.name)) {
        _loadItemIcon(asset);
        return true;
      }
    }
    return super.onRiveAssetLoad(asset, embeddedBytes);
  }

  Future<void> _loadItemIcon(ImageAsset asset) async =>
      asset.image = await loadImage(
        "shop_nectar_1",
        subFolder: "shop",
      );

  Widget _buttonBuy() {
    return Positioned(
      bottom: 400.d,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
            animation: _opacityAnimationController,
            builder: (ctx, child) {
              return Opacity(
                opacity: _opacityAnimationController.value,
                child: SkinnedButton(
                  height: 200.d,
                  width: 450.d,
                  // padding: EdgeInsets.symmetric(horizontal: 120.d,vertical: 23.d),
                  color: ButtonColor.green,
                  child: Column(
                    children: [
                      Align(
                          alignment: const Alignment(0, 0.52),
                          child: Stack(alignment: Alignment.center, children: [
                            SkinnedText("\$20.00", style: TStyles.medium),
                            Asset.load<Image>("text_line", width: 160.d)
                          ])),
                      SkinnedText(
                        "\$20.00",
                        style: TStyles.large,
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  @override
  void dispose() {
    _opacityAnimationController.dispose();
    super.dispose();
  }
}
