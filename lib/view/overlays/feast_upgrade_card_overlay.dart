import 'dart:async';

import 'package:rive/rive.dart';

import '../../data/core/fruit.dart';
import '../../mixins/background_mixin.dart';
import '../../mixins/reward_mixin.dart';
import '../../services/localization.dart';
import '../../utils/utils.dart';
import 'overlay.dart';

class UpgradeCardFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const UpgradeCardFeastOverlay({required this.args, super.onClose, super.key})
      : super(type: OverlayType.feastUpgradeCard);

  @override
  createState() => _UpgradeCardFeastOverlayState();
}

class _UpgradeCardFeastOverlayState
    extends AbstractOverlayState<UpgradeCardFeastOverlay>
    with RewardScreenMixin, BackgroundMixin {
  int _evolveStep = 0, _oldPower = 0;
  final _evolveStepsCount = 3;
  bool _isHero = false;
  late AccountCard _oldCard, _newCard;

  @override
  void initState() {
    super.initState();
    children = [backgroundBuilder(), animationBuilder("evolvehero")];
    _isHero = widget.args["isHero"] ?? false;
    _oldCard =
        widget.args["card"] ?? accountProvider.account.cards.values.first;
    _oldPower = _oldPower;
    process(() async {
      if (_isHero) {
        return _newCard = await accountProvider.evolveHero(context, _oldCard);
      }
      return _newCard = await accountProvider.enhanceMax(context, _oldCard);
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    controller.findInput<bool>("withPotion")?.value = _isHero;
    controller.findInput<bool>("withNectar")?.value = !_isHero;
    updateRiveText("cardNameText", "${_oldCard.base.fruit.name}_title".l());
    updateRiveText("cardLevelText", (_oldCard.base.rarity - 1).convert());
    updateRiveText("cardPowerText", "ˢ${_oldPower.compact()}");
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    var diff = _newCard.power - _oldPower;
    if (state == RewardAnimationState.started) {
      updateRiveText("cardLevelText", _newCard.base.rarity.convert());
      updateRiveText("cardPowerText", "ˢ${(_newCard.power).compact()}");
    } else if (state == RewardAnimationState.shown) {
      updateRiveText("addedPowerText", "+ ˢ${diff.compact()}");
    } else if (event.name == "powerUp") {
      ++_evolveStep;
      var addedPower = (diff * (_evolveStep / _evolveStepsCount)).round();
      updateRiveText("addedPowerText", "+ ˢ${addedPower.compact()}");
    }
  }

  @override
  Future<void> loadCardIcon(ImageAsset asset, String name) async {
    super.loadCardIcon(asset, _oldCard.base.getName());
  }

  @override
  Future<void> loadCardFrame(ImageAsset asset, FruitCard? card) async {
    super.loadCardFrame(asset, _oldCard.base);
  }
}
