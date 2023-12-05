import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/fruit.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../utils/utils.dart';
import '../mixins/reward_mixin.dart';
import '../route_provider.dart';
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

  ImageAsset? _cardIconAsset, _cardBackgroundAsset;

  @override
  void initState() {
    super.initState();
    children = [animationBuilder("merge")];
    _mergedCard = widget.args["cards"].value[0] ??
        accountBloc.account!.cards.values.first;

    process(() async {
      var card = await accountBloc.evolve(context, widget.args["cards"]);
      if (card != null) {
        return _newCard = card;
      }
      return null;
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
        _cardIconAsset = asset;
        return true;
      } else if (asset.name == "newCardFrame") {
        _cardBackgroundAsset = asset;
        return true;
      }
    }
    return super.onRiveAssetLoad(asset, embeddedBytes);
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (event.name == "started") {
      updateRiveText("cardNameText3", "${_newCard.base.fruit.name}_title".l());
      updateRiveText("cardLevelText3", _newCard.base.rarity.convert());
      updateRiveText("cardPowerText3", "ˢ${_newCard.power.compact()}");
      super.loadCardIcon(_cardIconAsset!, _newCard.base.getName());
      super.loadCardFrame(_cardBackgroundAsset!, _newCard.base);
    }
  }
}
