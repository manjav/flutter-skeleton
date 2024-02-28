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
    with RewardScreenMixin, TickerProviderStateMixin, ServiceFinderWidgetMixin {
  late AnimationController _opacityAnimationController;
  late Account _account;
  late Timer _timer;
  var images = <String, dynamic>{
    "cardIcon0": "",
    "cardIcon1": "",
    "cardIcon2": "",
    "cardIcon3": "",
    "cardIcon4": "",
  };
  var texts = {
    "card0Text": "",
    "card1Text": "",
    "card2Text": "",
    "card3Text": "",
    "card4Text": "",
    "card0PowerText": "",
    "card1PowerText": "",
    "card2PowerText": "",
    "card3PowerText": "",
    "card4PowerText": "",
    "card0PercentText": "",
    "card1PercentText": "",
    "card2PercentText": "",
    "card3PercentText": "",
    "card4PercentText": "",
    "card0LevelText": "",
    "card1LevelText": "",
    "card2LevelText": "",
    "card3LevelText": "",
    "card4LevelText": "",

  };

  @override
  void initState() {
    _account = accountProvider.account;
    _opacityAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    waitingSFX = "";
    startSFX = "waiting";

    var bundle = _account.bundles[0];
    var endDate = Convert.toInt(bundle["end_date"]);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      var duration =
          Duration(seconds: endDate - DateTime.now().secondsSinceEpoch);

      String time =
          "${duration.inHours.toString().padLeft(2, "0")}:${(duration.inMinutes % 60).toString().padLeft(2, "0")}:${(duration.inSeconds % 60).toString().padLeft(2, "0")}";
      updateRiveText("timerText", time);
    });
    var index = 0;
    if (bundle["gold_amount"] > 0) {
      images["cardIcon$index"] = "shop_gold_30";
      texts["card${index}Text"] = int.parse(bundle["gold_amount"].toString()).compact();
      index++;
    }
    if (bundle["nectar_amount"] > 0) {
      images["cardIcon$index"] = "shop_nectar_1";
      texts["card${index}Text"] = bundle["nectar_amount"].toString();
      index++;
    }
    if (bundle["fill_potion"] == true) {
      images["cardIcon$index"] = "shop_potion";
      texts["card${index}Text"] = "bundle_potion".l();
      index++;
    }
    if (bundle["boost_pack_type"] > 0) {
      // >= 22 power
      // <22 xp
      images["cardIcon$index"] = "shop_boost_power";
      texts["card${index}Text"] = "shop_boost".l();
      index++;
    }
    if (bundle["card_info"] != null) {
      if (bundle["card_info"]["type"] == 1) {
        for (var card in bundle["card_info"]["cards"]) {
          var c = AccountCard(_account, card);
          images["cardIcon$index"] = c;
          texts["card${index}Text"] = c.base.name;
          texts["card${index}PowerText"] = c.power.toString();
          texts["card${index}LevelText"] = c.base.rarity.toString();
          index++;
        }
      } else {
        images["cardIcon$index"] = "shop_boost_power";
        texts["card${index}Text"] = "shop_boost".l();
      }
    }

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
    controller.findInput<double>("rewardCount")?.value =
        _account.bundles[0]["rewards_count"].toDouble();
    updateRiveText("titleText", "wonderful_bundle".l());
    updateRiveText("timerText", "");
    updateRiveText("card0Text", texts["card0Text"]!);
    updateRiveText("card1Text", texts["card1Text"]!);
    updateRiveText("card2Text", texts["card2Text"]!);
    updateRiveText("card3Text", texts["card3Text"]!);
    updateRiveText("card4Text", texts["card4Text"]!);
    updateRiveText("card0PowerText", texts["card0PowerText"]!);
    updateRiveText("card1PowerText", texts["card1PowerText"]!);
    updateRiveText("card2PowerText", texts["card2PowerText"]!);
    updateRiveText("card3PowerText", texts["card3PowerText"]!);
    updateRiveText("card4PowerText", texts["card4PowerText"]!);
    updateRiveText("card0PercentText", texts["card0PercentText"]!);
    updateRiveText("card1PercentText", texts["card1PercentText"]!);
    updateRiveText("card2PercentText", texts["card2PercentText"]!);
    updateRiveText("card3PercentText", texts["card3PercentText"]!);
    updateRiveText("card4PercentText", texts["card4PercentText"]!);
    updateRiveText("card0LevelText", texts["card0LevelText"]!);
    updateRiveText("card1LevelText", texts["card1LevelText"]!);
    updateRiveText("card2LevelText", texts["card2LevelText"]!);
    updateRiveText("card3LevelText", texts["card3LevelText"]!);
    updateRiveText("card4LevelText", texts["card4LevelText"]!);

    artboard.addController(controller);
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == RewardAnimationState.closing) {
      _opacityAnimationController.animateBack(0,
          duration: const Duration(milliseconds: 500));
      _timer.cancel();
    }
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name.startsWith("cardIcon")) {
        if (images[asset.name]! is AccountCard) {
          var card = images[asset.name]! as AccountCard;
          asset.image = await loadImage(
            card.base.getName(),
            subFolder: "cards",
          );
        } else {
          asset.image = await loadImage(
            images[asset.name]!,
            subFolder: "shop",
          );
        }
        return true;
      }
    }
    return super.onRiveAssetLoad(asset, embeddedBytes);
  }

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
