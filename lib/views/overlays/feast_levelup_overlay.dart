import 'dart:async';

import 'package:rive/rive.dart';
import '../../app_export.dart';

class LevelupFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const LevelupFeastOverlay({required this.args, super.onClose, super.key})
      : super(route: OverlaysName.feastLevelUp);

  @override
  createState() => _LevelupScreenState();
}

class _LevelupScreenState extends AbstractOverlayState<LevelupFeastOverlay>
    with RewardScreenMixin, BackgroundMixin {
  int _gold = 0;
  AccountCard? _card;

  @override
  void initState() {
    super.initState();
    children = [backgroundBuilder(), animationBuilder("levelup")];
    _gold = widget.args["levelup_gold_added"] ?? 100;
    _card =
        widget.args["gift_card"] ?? accountProvider.account.cards.values.last;
    process(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    updateRiveText("goldText", "$_gold");
    updateRiveText("levelText", "${widget.args["level"] ?? 123}");
    updateRiveText("cardNameText", "${_card!.base.fruit.name}_title".l());
    updateRiveText("cardLevelText", _card!.base.rarity.convert());
    updateRiveText("cardPowerText", "ˢ${_card!.power.compact()}");
    updateRiveText("text_ribbon", "level_up".l());
    updateRiveText("text_ribbon_shadow", "level_up".l());
    updateRiveText("text_ribbon_stroke", "level_up".l());
    return controller;
  }

  @override
  Future<void> loadCardIcon(ImageAsset asset, String name) async =>
      super.loadCardIcon(asset, _card!.base.getName());

  @override
  Future<void> loadCardFrame(ImageAsset asset, FruitCard? card) async =>
      super.loadCardFrame(asset, _card!.base);
}