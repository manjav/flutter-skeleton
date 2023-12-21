import 'dart:async';

import '../../mixins/background_mixin.dart';
import 'package:rive/rive.dart';

import '../../data/core/fruit.dart';
import '../../mixins/reward_mixin.dart';
import '../../services/localization.dart';
import '../../utils/utils.dart';
import '../../view/widgets/card_holder.dart';
import '../overlays/ioverlay.dart';

class EnhanceFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const EnhanceFeastOverlay({required this.args, super.key})
      : super(type: OverlayType.feastEnhance);

  @override
  createState() => _EnhanceFeastOverlayState();
}

class _EnhanceFeastOverlayState
    extends AbstractOverlayState<EnhanceFeastOverlay>
    with RewardScreenMixin, BackgroundMixin {
  late AccountCard _card;
  late SelectedCards _sacrificedCards;
  int _oldPower = 0, _sacrificeStep = 0;
  @override
  void initState() {
    super.initState();
    children = [backgroundBuilder(), animationBuilder("enhance")];
    _sacrificedCards = widget.args["sacrifiedCards"] ??
        [accountBloc.account!.cards.values.last];
    _card = widget.args["card"] ?? accountBloc.account!.cards.values.first;
    _oldPower = _card.power;
    process(() async {
      return _card =
          await accountBloc.enhance(context, _card, _sacrificedCards);
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    controller.findInput<double>("cards")?.value = _sacrificedCards.count;
    updateRiveText("cardNameText", "${_card.base.fruit.name}_title".l());
    updateRiveText("cardLevelText", _card.base.rarity.convert());
    updateRiveText("cardPowerText", "ˢ${_oldPower.compact()}");
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    var diff = _card.power - _oldPower;
    if (state == RewardAniationState.started) {
      updateRiveText("addedPowerText", "+ ˢ${diff.compact()}");
    } else if (state == RewardAniationState.shown) {
      updateRiveText("cardPowerText", "ˢ${_card.power.compact()}");
    } else if (event.name == "powerUp") {
      ++_sacrificeStep;
      var addedPower =
          (diff * (_sacrificeStep / _sacrificedCards.count)).round();
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
