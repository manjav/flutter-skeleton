import 'dart:async';

import 'package:rive/rive.dart';

import '../../data/core/fruit.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../utils/utils.dart';
import '../../view/widgets/card_holder.dart';
import '../mixins/reward_mixin.dart';
import '../route_provider.dart';
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
    _sacrifiedCount = (widget.args["sacrifiedCount"] ?? 6).clamp(1, 6);
    children = [backgrounBuilder(), animationBuilder("enhance")];
    _card = widget.args["card"] ?? accountBloc.account!.cards.values.first;
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    controller.findInput<double>("cards")?.value = _sacrifiedCount.toDouble();
    updateRiveText("cardNameText", "${_card.base.fruit.name}_title".l());
    updateRiveText("cardLevelText", _card.base.rarity.convert());
    updateRiveText("cardPowerText", "ˢ${_oldPower.compact()}");
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
  Future<void> loadCardFrame(ImageAsset asset, FruitCard? card) async {
    super.loadCardFrame(asset, _card.base);
  }
}
