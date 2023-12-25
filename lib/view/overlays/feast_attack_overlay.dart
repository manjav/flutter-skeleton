import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_skeleton/data/core/adam.dart';
import 'package:flutter_skeleton/view/widgets/card_holder.dart';
import 'package:rive/rive.dart';

// ignore: implementation_imports
// import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/rpc.dart';
import '../../mixins/background_mixin.dart';
import '../../mixins/reward_mixin.dart';
import '../../services/localization.dart';
import '../overlays/ioverlay.dart';

class AttackFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const AttackFeastOverlay({required this.args, super.onClose, super.key})
      : super(type: OverlayType.feastAttack);

  @override
  createState() => _AttackFeastOverlayState();
}

class _AttackFeastOverlayState extends AbstractOverlayState<AttackFeastOverlay>
    with RewardScreenMixin, BackgroundMixin {
  // ImageAsset? _cardIconAsset, _cardBackgroundAsset;

  @override
  void initState() {
    super.initState();
    children = [animationBuilder("attack")];

    Opponent? opponent = widget.args["opponent"];
    SelectedCards cards = widget.args["cards"];
    var isBattle = opponent != null;
    var params = {
      "cards": cards.getIds(),
      "check": md5.convert(utf8.encode("${accountBloc.account!.q}")).toString()
    };
    if (cards.value[2] != null) {
      params[RpcParams.hero_id.name] = cards.value[2]!.id;
    }
    if (isBattle) {
      params[RpcParams.opponent_id.name] = opponent.id;
      params[RpcParams.attacks_in_today.name] = opponent.todayAttacksCount;
    }
    process(() async {
      var data =
          await rpc(isBattle ? RpcId.battle : RpcId.quest, params: params);
      return data;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    for (var i = 1; i < 3; i++) {
      // updateRiveText(
      //     "cardNameText$i", "${_mergedCard.base.fruit.name}_title".l());
      // updateRiveText("cardLevelText$i", _mergedCard.base.rarity.convert());
      // updateRiveText("cardPowerText$i", "ˢ${_mergedCard.power.compact()}");
    }
    updateRiveText("titleText", "evolve_l".l());
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == RewardAniationState.started) {
      // updateRiveText("cardNameText3", "${_newCard.base.fruit.name}_title".l());
      // updateRiveText("cardLevelText3", _newCard.base.rarity.convert());
      // updateRiveText("cardPowerText3", "ˢ${_newCard.power.compact()}");
      // super.loadCardIcon(_cardIconAsset!, _newCard.base.getName());
      // super.loadCardFrame(_cardBackgroundAsset!, _newCard.base);
    }
  }

  // @override
  // Future<void> loadCardIcon(ImageAsset asset, String name) async =>
  //     super.loadCardIcon(asset, _mergedCard.base.getName());

  // @override
  // Future<void> loadCardFrame(ImageAsset asset, FruitCard? card) async =>
  //     super.loadCardFrame(asset, _mergedCard.base);

  // @override
  // Future<bool> onRiveAssetLoad(
  //     FileAsset asset, Uint8List? embeddedBytes) async {
  //   if (asset is ImageAsset) {
  //     if (asset.name == "newCardIcon") {
  //       _cardIconAsset = asset;
  //       return true;
  //     } else if (asset.name == "newCardFrame") {
  //       _cardBackgroundAsset = asset;
  //       return true;
  //     }
  //   }
  //   return super.onRiveAssetLoad(asset, embeddedBytes);
  // }
}
