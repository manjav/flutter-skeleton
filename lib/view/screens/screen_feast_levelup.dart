import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../data/core/fruit.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../utils/utils.dart';
import '../mixins/reward_mixin.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'iscreen.dart';

class LevelupFeastScreen extends AbstractScreen {
  LevelupFeastScreen({required super.args, super.key})
      : super(Routes.feastLevelup);

  @override
  createState() => _LevelupScreenState();
}

class _LevelupScreenState extends AbstractScreenState<LevelupFeastScreen>
    with RewardScreenMixin {
  int _gold = 0;
  AccountCard? _card;

  @override
  void initState() {
    super.initState();
    getService<Sounds>().play("levelup");
    _gold = widget.args["levelup_gold_added"] ?? 100;
    _card = widget.args["gift_card"] ?? accountBloc.account!.cards.values.last;
  }

  @override
  Widget contentFactory() {
    return Widgets.button(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: Stack(children: [
          backgrounBuilder(),
          animationBuilder("levelup", "Levelup"),
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
  onRiveInit(Artboard artboard, String stateMachineName) {
    super.onRiveInit(artboard, stateMachineName);
    updateRiveText("goldText", "$_gold");
    updateRiveText("levelText", "${widget.args["level"] ?? 123}");
    updateRiveText("cardNameText", "${_card!.base.fruit.name}_t".l());
    updateRiveText("cardLevelText", "${_card!.base.rarity}");
    updateRiveText("cardPowerText", "ˢ${_card!.power.compact()}");
    updateRiveText("commentText", "tap_close".l());
  }

  @override
  Future<void> loadCardIcon(ImageAsset asset, String name) async {
    super.loadCardIcon(asset, _card!.base.getName());
  }

  @override
  Future<void> loadCardFrame(
      ImageAsset asset, int category, String level) async {
    var category = _card!.base.fruit.category;
    super.loadCardFrame(
        asset, category, category == 0 ? "_${_card!.base.rarity}" : "");
  }
}
