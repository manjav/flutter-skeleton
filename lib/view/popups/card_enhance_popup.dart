import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/core/fruit.dart';
import '../../mixins/card_edit_mixin.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../overlays/overlay.dart';
import '../widgets/skinned_text.dart';
import '../items/card_item.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'popup.dart';

class CardEnhancePopup extends AbstractPopup {
  const CardEnhancePopup({super.key, required super.args})
      : super(Routes.popupCardEnhance);

  @override
  createState() => _CardEnhancePopupState();
}

class _CardEnhancePopupState extends AbstractPopupState<CardEnhancePopup>
    with CardEditMixin {
  bool _isSacrificeAvailable = false;

  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(0.d, 142.d, 0.d, 32.d);

  @override
  String titleBuilder() => "enhance_l".l();

  @override
  selectedForeground() {
    return Widgets.rect(
        radius: 18.d,
        padding: EdgeInsets.all(32.d),
        color: TColors.primary10.withOpacity(0.5),
        child: Asset.load<Image>('icon_sacrifice'));
  }

  @override
  Widget contentFactory() {
    var account = accountBloc.account!;
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: selectedCards,
        builder: (context, value, child) {
          return SizedBox(
              width: 980.d,
              height: DeviceInfo.size.height - 550.d,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Widgets.rect(
                    width: 340.d,
                    child: CardItem(card,
                        size: 340.d,
                        showCooldown: false,
                        extraPower: _getSacrificesPower(),
                        heroTag: "hero_${card.id}"),
                  ),
                  cardsListBuilder(account, crossAxisCount: 5),
                  _isSacrificeAvailable || selectedCards.value.isEmpty
                      ? const SizedBox()
                      : Positioned(
                          bottom: 230.d,
                          child: SkinnedText("card_max_power".l(),
                              style: TStyles.large
                                  .copyWith(color: TColors.accent))),
                  Positioned(
                      left: 16.d,
                      right: 16.d,
                      height: 210.d,
                      bottom: 32.d,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            card.base.isHero || card.isMonster
                                ? _enhanceButton(
                                    ButtonColor.teal,
                                    "card_enhance_max".l(),
                                    [
                                      Row(children: [
                                        Asset.load<Image>("icon_nectar",
                                            height: 76.d),
                                        SkinnedText(
                                            _getMaxEnhanceCost().compact()),
                                      ]),
                                    ],
                                    true,
                                    _enhanceMax)
                                : const SizedBox(),
                            _enhanceButton(
                                ButtonColor.yellow,
                                "card_sacrifice".l(),
                                [
                                  Row(children: [
                                    Asset.load<Image>("card_sacrifice",
                                        height: 60.d),
                                    SkinnedText(
                                        " x${selectedCards.value.length}"),
                                  ]),
                                  Row(children: [
                                    Asset.load<Image>("icon_gold",
                                        height: 64.d),
                                    SkinnedText(_getSacrificeCost().compact()),
                                  ]),
                                ],
                                _isSacrificeAvailable,
                                _sacrifice),
                          ]))
                ],
              ));
        });
  }

  Widget _enhanceButton(ButtonColor color, String text, List<Widget> children,
      bool isEnable, Function() onTap) {
    return Widgets.skinnedButton(
        width: 460.d,
        height: 200.d,
        color: color,
        isEnable: isEnable,
        padding: EdgeInsets.fromLTRB(30.d, 16.d, 14.d, 29.d),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          SkinnedText(text,
              style: TStyles.medium.copyWith(fontSize: 46.d, height: 3.d)),
          SizedBox(width: 12.d),
          Widgets.rect(
              padding: EdgeInsets.all(12.d),
              decoration: Widgets.imageDecorator(
                  "frame_hatch_button", ImageCenterSliceData(42)),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children))
        ]),
        onDisablePressed: () => toast("card_enhance_min".l()),
        onPressed: onTap);
  }

  _sacrifice() async {
    if (!_isSacrificeAvailable) return;
    Overlays.insert(context, OverlayType.feastEnhance,
        args: {"card": card, "sacrificedCards": selectedCards});
    if (mounted) {
      Navigator.pop(context);
    }
  }

  int _getSacrificesPower() {
    const enhancementModifier = 0.2;
    const enhanceRarityModifier = 0.7;
    const veteranEnhancementModifier = 0.02;
    const veteranSacrificePowerModifier = 1.5;
    const veteranEnhanceRarityModifier = 0.4;

    var cardPowers = 0.0;
    for (var card in selectedCards.value) {
      // if there is active power boost, we use non-boost power as power in formula.
      // var power = card.powerBeforeBoost or element.power
      var veteranLevel = card!.base.veteranLevel;
      if (veteranLevel > 0) {
        cardPowers +=
            card.base.power * veteranSacrificePowerModifier * veteranLevel;
      } else {
        cardPowers += card.base.power;
      }
    }

    var rarity = card.base.virtualRarity.toDouble();
    var verteranLevel = card.base.veteranLevel;
    var calculatePower = 0;
    if (verteranLevel == 0) {
      calculatePower = (cardPowers *
              enhancementModifier *
              math.pow(rarity, enhanceRarityModifier))
          .floor();
    } else {
      calculatePower = (cardPowers *
              veteranEnhancementModifier *
              math.pow(rarity / verteranLevel, veteranEnhanceRarityModifier))
          .floor();
    }
    _isSacrificeAvailable = calculatePower > 0 &&
        card.power + calculatePower <= card.base.powerLimit;
    return calculatePower.round();
  }

  int _getSacrificeCost() {
    const enhancementCostModifier = 0.1;
    var cardPrices = 0;
    for (var card in selectedCards.value) {
      cardPrices += card!.base.cost;
    }
    return (cardPrices * enhancementCostModifier).round();
  }

  int _getMaxEnhanceCost() {
    const enhancementCostModifier = 0.1;
    const enhancementModifier = 0.2;
    const maxEnhanceModifier = 45;
    const enhanceRarityModifier = 0.7;
    const enhanceNectarModifier = 1;
    const minimumNectarCostForEnhancement = 100;
    const priceModifier = 100;

    var enhancementPower = card.base.powerLimit - card.power;
    var cardPower = (enhancementPower /
            (enhancementModifier *
                math.pow(
                    card.base.virtualRarity.toDouble(), enhanceRarityModifier)))
        .floor();
    var totalCardPrice = (cardPower *
        enhanceNectarModifier *
        (priceModifier / maxEnhanceModifier));
    var enhancementCost =
        totalCardPrice * enhancementCostModifier + totalCardPrice;
    return minimumNectarCostForEnhancement
        .min((enhancementCost / account.nectarPrice).round())
        .floor();
  }

  _enhanceMax() async {
    Overlays.insert(context, OverlayType.feastUpgradeCard,
        args: {"card": account.cards[card.id]}, onClose: (d) {
      if (mounted) Navigator.pop(context);
    });
  }
}
