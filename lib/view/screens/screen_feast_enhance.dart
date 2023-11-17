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

class EnhanceFeastScreen extends AbstractScreen {
  EnhanceFeastScreen({required super.args, super.key})
      : super(Routes.feastLevelup);

  @override
  createState() => _EnhanceFeastScreenState();
}

class _EnhanceFeastScreenState extends AbstractScreenState<EnhanceFeastScreen>
    with RewardScreenMixin {
  int _oldPower = 0, _sacrifiedCount = 2, _sacrificeStep = 0;
  late AccountCard _card;

  @override
  void initState() {
    super.initState();
    getService<Sounds>().play("levelup");
    _oldPower = widget.args["oldPower"] ?? 90;
    _sacrifiedCount = widget.args["sacrifiedCount"] ?? 4;
    _card = widget.args["card"] ?? accountBloc.account!.cards.values.first;
  }

  @override
  Widget contentFactory() {
    return Widgets.button(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: Stack(children: [
          backgrounBuilder(),
          animationBuilder("enhance"),
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
    controller.findInput("cards")?.value = _sacrifiedCount.toDouble();
    updateRiveText("cardNameText", "${_card.base.fruit.name}_t".l());
    updateRiveText("cardLevelText", "${_card.base.rarity}");
    updateRiveText("cardPowerText", "ˢ${_oldPower.compact()}");
    updateRiveText("commentText", "tap_close".l());
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (event.name == "ready") {
      updateRiveText(
          "addedPowerText", "+ ˢ${(_card.power - _oldPower).compact()}");
      updateRiveText("cardPowerText", "ˢ${(_card.power).compact()}");
    } else if (event.name == "powerUp") {
      ++_sacrificeStep;
      var diff = _card.power - _oldPower;
      var addedPower = (diff * (_sacrificeStep / _sacrifiedCount)).round();
      updateRiveText("addedPowerText", "+ ˢ${addedPower.compact()}");
    }
  }

  @override
  Future<void> loadCardIcon(ImageAsset asset, String name) async {
    super.loadCardIcon(asset, _card.base.getName());
  }

  @override
  Future<void> loadCardFrame(
      ImageAsset asset, int category, String level) async {
    var category = _card.base.fruit.category;
    super.loadCardFrame(
        asset, category, category == 0 ? "_${_card.base.rarity}" : "");
  }
}
