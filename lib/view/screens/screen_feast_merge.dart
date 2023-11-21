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

class MergeFeastScreen extends AbstractScreen {
  MergeFeastScreen({required super.args, super.key})
      : super(Routes.feastLevelup);

  @override
  createState() => _MergeFeastScreenState();
}

class _MergeFeastScreenState extends AbstractScreenState<MergeFeastScreen>
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
      updateRiveText("cardNameText$i", "${_mergedCard.base.fruit.name}_t".l());
      updateRiveText("cardLevelText$i", "${_mergedCard.base.rarity}");
      updateRiveText("cardPowerText$i", "ˢ${_mergedCard.power.compact()}");
    }
    updateRiveText("cardNameText3", "${_newCard.base.fruit.name}_t".l());
    updateRiveText("cardLevelText3", "${_newCard.base.rarity}");
    updateRiveText("cardPowerText3", "ˢ${_newCard.power.compact()}");
    updateRiveText("titleText", "popupcardmerge".l());
    updateRiveText("commentText", "tap_close".l());
    return controller;
  }

  // @override
  // void onRiveEvent(RiveEvent event) {
  //   super.onRiveEvent(event);
  //   if (event.name == "merge") {
  //     var category = _newCard.base.fruit.category;
  //     super.loadCardFrame(_frameImageAsset!, category,
  //         category == 0 ? "_${_newCard.base.rarity}" : "");
  //     super.loadCardIcon(_iconImageAsset!, _newCard.base.getName());
  //     //   updateRiveText(
  //     //       "addedPowerText", "+ ˢ${(_newCard - _card!.power).compact()}");
  //     //   updateRiveText("cardPowerText", "ˢ${(_newCard).compact()}");
  //     // } else if (event.name == "powerUp") {
  //     //   ++_sacrificeStep;
  //     //   var diff = _newCard - _card!.power;
  //     //   var addedPower = (diff * (_sacrificeStep / _sacrifiedCount)).round();
  //     //   updateRiveText("addedPowerText", "+ ˢ${addedPower.compact()}");
  //   }
  // }

  // ImageAsset? _frameImageAsset, _iconImageAsset;

  @override
  Future<void> loadCardIcon(ImageAsset asset, String name) async {
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
