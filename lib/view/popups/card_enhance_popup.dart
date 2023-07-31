import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/card_edit_mixin.dart';
import '../../view/items/card_item_minimal.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'ipopup.dart';

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
  void initState() {
    contentPadding = EdgeInsets.fromLTRB(0.d, 142.d, 0.d, 32.d);
    super.initState();
  }

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
    var account = BlocProvider.of<AccountBloc>(context).account!;
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: selectedCards,
        builder: (context, value, child) {
          return SizedBox(
              width: 980.d,
              height: DeviceInfo.size.height - 450.d,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Widgets.rect(
                    width: 340.d,
                    child: MinimalCardItem(card,
                        size: 340.d, extraPower: _getSacrificesPower()),
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
                            card.isHero || card.isMonster
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
    var bgCenterSlice = ImageCenterSliceDate(42, 42);
    return Widgets.skinnedButton(
        width: 460.d,
        color: color,
        isEnable: isEnable,
        padding: EdgeInsets.fromLTRB(30.d, 16.d, 14.d, 29.d),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          SkinnedText(text,
              style: TStyles.medium.copyWith(fontSize: 46.d, height: 3.d)),
          SizedBox(width: 12.d),
          Widgets.rect(
              padding: EdgeInsets.all(12.d),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      centerSlice: bgCenterSlice.centerSlice,
                      image: Asset.load<Image>('ui_frame_inside',
                              centerSlice: bgCenterSlice)
                          .image)),
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
    var params = {
      RpcParams.card_id.name: card.id,
      RpcParams.sacrifices.name: selectedCards.getIds()
    };
    try {
      var result = await BlocProvider.of<Services>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.enhanceCard, params: params);
      updateAccount(result);
      if (mounted) Navigator.pop(context);
    } finally {}
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
      var power = card!.base.get<int>(CardFields.power);
      var verteranLevel = card.base.get<int>(CardFields.veteran_level);
      if (verteranLevel > 0) {
        cardPowers += power * veteranSacrificePowerModifier * verteranLevel;
      } else {
        cardPowers += power;
      }
    }

    var rarity = card.base.get(CardFields.virtualRarity).toDouble();
    var verteranLevel = card.base.get<int>(CardFields.veteran_level);
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
        card.power + calculatePower <=
            card.base.get<int>(CardFields.powerLimit);
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

    var enhancementPower = card.base.get(CardFields.powerLimit) - card.power;
    var cardPower = (enhancementPower /
            (enhancementModifier *
                math.pow(card.base.get(CardFields.virtualRarity).toDouble(),
                    enhanceRarityModifier)))
        .floor();
    var totalCardPrice = (cardPower *
        enhanceNectarModifier *
        (priceModifier / maxEnhanceModifier));
    var enhancementCost =
        totalCardPrice * enhancementCostModifier + totalCardPrice;
    return minimumNectarCostForEnhancement.min(
        (enhancementCost / account.get<int>(AccountField.nectar_price))
            .floor());
  }

  _enhanceMax() async {
    try {
      var result = await BlocProvider.of<Services>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.enhanceMax,
              params: {RpcParams.card_id.name: card.id});
      updateAccount(result);
      if (mounted) Navigator.pop(context);
    } finally {}
  }
}
