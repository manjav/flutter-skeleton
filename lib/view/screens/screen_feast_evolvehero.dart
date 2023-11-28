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

class EvolveHeroFeastScreen extends AbstractScreen {
  EvolveHeroFeastScreen({required super.args, super.key})
      : super(Routes.feastLevelup);

  @override
  createState() => _EvolveHeroFeastScreenState();
}

class _EvolveHeroFeastScreenState
    extends AbstractScreenState<EvolveHeroFeastScreen> with RewardScreenMixin {
  int _oldPower = 0, _evolveStep = 0;
  final _evolveStepsCount = 3;
  late AccountCard _card;

  @override
  void initState() {
    super.initState();
    getService<Sounds>().play("levelup");
    _oldPower = widget.args["oldPower"] ?? 10;
    _card = widget.args["card"] ?? accountBloc.account!.cards.values.first;
  }

  @override
  Widget contentFactory() {
    return Widgets.button(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: Stack(children: [
          backgrounBuilder(),
          animationBuilder("evolvehero"),
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
    updateRiveText("cardNameText", "${_card.base.fruit.name}_title".l());
    updateRiveText("cardLevelText", (_card.base.rarity - 1).convert());
    updateRiveText("cardPowerText", "ˢ${_oldPower.compact()}");
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (event.name == "ready") {
      updateRiveText("cardLevelText", _card.base.rarity.convert());
      updateRiveText(
          "addedPowerText", "+ ˢ${(_card.power - _oldPower).compact()}");
      updateRiveText("cardPowerText", "ˢ${(_card.power).compact()}");
    } else if (event.name == "powerUp") {
      ++_evolveStep;
      var diff = _card.power - _oldPower;
      var addedPower = (diff * (_evolveStep / _evolveStepsCount)).round();
      updateRiveText("addedPowerText", "+ ˢ${addedPower.compact()}");
    }
  }

  @override
  Future<void> loadCardIcon(ImageAsset asset, String name) async {
    super.loadCardIcon(asset, _card.base.getName());
  }

  @override
  Future<void> loadCardFrame(ImageAsset asset, FruitCard? card) async {
    super.loadCardFrame(asset, _card.base);
  }
}
