import 'dart:async';

import 'package:rive/rive.dart';

import '../../data/core/fruit.dart';
import '../../mixins/background_mixin.dart';
import '../../mixins/reward_mixin.dart';
import '../../services/localization.dart';
import '../../utils/utils.dart';
import '../../view/overlays/ioverlay.dart';

class LevelupFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const LevelupFeastOverlay({required this.args, super.onClose, super.key})
      : super(type: OverlayType.feastLevelup);

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
    _card = widget.args["gift_card"] ?? accountBloc.account!.cards.values.last;
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
    return controller;
  }

  @override
  Future<void> loadCardIcon(ImageAsset asset, String name) async =>
      super.loadCardIcon(asset, _card!.base.getName());

  @override
  Future<void> loadCardFrame(ImageAsset asset, FruitCard? card) async =>
      super.loadCardFrame(asset, _card!.base);
}
