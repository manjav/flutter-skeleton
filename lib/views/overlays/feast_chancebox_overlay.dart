import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class ChanceBoxFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const ChanceBoxFeastOverlay({required this.args, super.onClose, super.key})
      : super(route: OverlaysName.feastChanceBox);

  @override
  createState() => _ChanceBoxScreenState();
}

class _ChanceBoxScreenState extends AbstractOverlayState<ChanceBoxFeastOverlay>
    with RewardScreenMixin, TickerProviderStateMixin, BackgroundMixin {
  bool _giftSelected = false;
  dynamic _prizes;
  int _wonPrizesNumber = 0;

  @override
  void initState() {
    startSFX = "open_card_pack";
    progressbarNotifier.value = false;
    _updateChildren();
    super.initState();
  }

  Future<void> getData() async {
    process(() async {
      var params = {
        "check":
            md5.convert(utf8.encode("${accountProvider.account.q}")).toString(),
        "store": FlavorConfig.instance.variables["storeId"]
      };

      var res = await rpc(RpcId.turnTheWheel, params: params, showError: false);
      _prizes = res["prizes"];
      _wonPrizesNumber = res["won_prize_number"];

      if (mounted) {
        accountProvider.update(context, res);
        
      }

      setState(() {
        _updateChildren();
      });

      updateRiveText("commentText", "select_gift".l());
      return true;
    });
  }

  void _updateChildren() {
    children = [
      animationBuilder("chancebox"),
      _prizes == null ? _buttonBuy() : const SizedBox(),
    ];
  }

  Widget _buttonBuy() {
    var requiredGold = ShopData.getMultiplier(accountProvider.account.level) *
        Constants.WheelOfFortune_GoldPriceModifier;
    return Positioned(
      bottom: 400.d,
      child: Material(
        color: TColors.transparent,
        child: SkinnedButton(
          padding: EdgeInsets.fromLTRB(15.d, 15.d, 10.d, 32.d),
          color: ButtonColor.green,
          width: 380.d,
          height: 150.d,
          onPressed: () => getData(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            textDirection: Localization.textDirection,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkinnedText(
                "open".l(),
                style: TStyles.medium,
                textDirection: Localization.textDirection,
              ),
              SizedBox(width: 15.d),
              Widgets.rect(
                padding: EdgeInsets.all(10.d),
                borderRadius: BorderRadius.all(Radius.circular(21.d)),
                color: TColors.black25,
                child: SkinnedText(requiredGold.toInt().compact(),
                    textDirection: Localization.textDirection,
                    style: TStyles.medium),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms, delay: 500.ms);
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    return controller;
  }

  @override
  void onScreenTouched() {
    if (state == RewardAnimationState.shown && !_giftSelected) {
      return;
    }
    super.onScreenTouched();
  }

  @override
  Widget closeButton() {
    if (_prizes == null) {
      return super.closeButton();
    }
    closeButtonController = null;
    return const SizedBox();
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == RewardAnimationState.started) {
      for (var i = 0; i < _wonPrizesNumber; i++) {
        updateRiveText("boxCaptionText$i",
            ("${_prizes["$i"]["gold"]?.compact()}\n${_prizes["$i"]["nectar"]?.compact()}"));
      }
    } else if (event.name.startsWith("choose")) {
      var match = RegExp(r'\d+').firstMatch(event.name);
      var index = int.parse(match!.group(0)!);
      _chooseGift(index);
    }
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is FontAsset) {
      loadFont(asset);
      return true;
    }
    return false;
  }

  Future<void> _chooseGift(int index) async {
    // var result = await accountProvider.openPack(context, _pack,
    //     selectedCardId: _cards[index].base.id);
    _giftSelected = true;
    await Future.delayed(1.seconds);
    updateRiveText("commentText", "tap_close".l());
  }
}
