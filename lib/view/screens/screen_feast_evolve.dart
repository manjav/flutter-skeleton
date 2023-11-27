import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/fruit.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../utils/utils.dart';
import '../mixins/reward_mixin.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'iscreen.dart';

class EvolveFeastScreen extends AbstractScreen {
  EvolveFeastScreen({required super.args, super.key})
      : super(Routes.feastLevelup);

  @override
  createState() => _EvolveFeastScreenState();
}

class _EvolveFeastScreenState extends AbstractScreenState<EvolveFeastScreen>
    with RewardScreenMixin {
  late AccountCard _mergedCard, _newCard;

  @override
  void initState() {
    super.initState();
    getService<Sounds>().play("levelup");
    _newCard = widget.args["newCard"] ?? accountBloc.account!.cards.values.last;
    _mergedCard =
        widget.args["mergedCard"] ?? accountBloc.account!.cards.values.first;
  }

  @override
  Widget contentFactory() {
    return Widgets.button(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: Stack(children: [
          backgrounBuilder(),
          animationBuilder("merge"),
        ]),
        onPressed: () {
          if (readyToClose) {
            closeInput?.value = true;
          } else {
            skipInput?.value = true;
          }
        });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    for (var i = 1; i < 3; i++) {
      updateRiveText(
          "cardNameText$i", "${_mergedCard.base.fruit.name}_title".l());
      updateRiveText("cardLevelText$i", _mergedCard.base.rarity.convert());
      updateRiveText("cardPowerText$i", "ˢ${_mergedCard.power.compact()}");
    }
    updateRiveText("cardNameText3", "${_newCard.base.fruit.name}_title".l());
    updateRiveText("cardLevelText3", _newCard.base.rarity.convert());
    updateRiveText("cardPowerText3", "ˢ${_newCard.power.compact()}");
    updateRiveText("titleText", "evolve_l".l());
    return controller;
  }

  @override
  Future<void> loadCardIcon(ImageAsset asset, String name) async =>
      super.loadCardIcon(asset, _mergedCard.base.getName());

  @override
  Future<void> loadCardFrame(ImageAsset asset, FruitCard? card) async =>
      super.loadCardFrame(asset, _mergedCard.base);

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "newCardIcon") {
        super.loadCardIcon(asset, _newCard.base.getName());
        return true;
      } else if (asset.name == "newCardFrame") {
        super.loadCardFrame(asset, _newCard.base);
        return true;
      }
    }
    return super.onRiveAssetLoad(asset, embeddedBytes);
  }
}
