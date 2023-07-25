import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services.dart';
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
  titleBuilder() => "card_enhance".l();

  @override
  Widget contentFactory() {
    var account = BlocProvider.of<AccountBloc>(context).account!;
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: selectedCards,
        builder: (context, value, child) {
          return SizedBox(
              width: 980.d,
              height: 1280.d,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Widgets.rect(
                    width: 300.d,
                    child: MinimalCardItem(card,
                        size: 300.d, extraPower: _getSacrificesPower()),
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
                      bottom: 20.d,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _scarificeButton(),
                          ]))
                ],
              ));
        });
  }

  _scarificeButton() {
    var bgCenterSlice = ImageCenterSliceDate(42, 42);
    return Widgets.labeledButton(
        isEnable: _isSacrificeAvailable,
        padding: EdgeInsets.fromLTRB(36.d, 16.d, 20.d, 29.d),
        child: Row(children: [
          SkinnedText("card_sacrifice".l(),
              style: TStyles.large.copyWith(height: 3.d)),
          SizedBox(width: 24.d),
          Widgets.rect(
            padding: EdgeInsets.symmetric(horizontal: 12.d),
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    centerSlice: bgCenterSlice.centerSlice,
                    image: Asset.load<Image>('ui_frame_inside',
                            centerSlice: bgCenterSlice)
                        .image)),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(children: [
                Asset.load<Image>("card_sacrifice", height: 64.d),
                SkinnedText(" x${selectedCards.value.length}"),
              ]),
              Row(children: [
                Asset.load<Image>("ui_gold", height: 76.d),
                SkinnedText(_getSacrificeCost().compact(),
                    style: TStyles.large),
              ]),
            ]),
          )
        ]),
        onPressed: _sacrifice);
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
      cards = getCards(account);
      if (mounted) Navigator.pop(context);
    } finally {}
  }

  int _getSacrificesPower() {
    const enhancementModifier = 0.2;
    const enhanceRarityModifier = 0.7;
    const veteranEnhancementModifier = 0.02;
    const veteranSacrificePowerModifier = 1.5;
    const veteranEnhanceRarityModifier = 0.4;
    // const enhanceMaximumCardPower = 1450000000;
    // final enhanceNectarModifier = 1;
    // final minimumNectarCostForEnhancement = 100;

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

    var rarity = card.base.get<double>(CardFields.virtualRarity);
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

  @override
  selectedForeground() {
    return Widgets.rect(
        radius: 18.d,
        padding: EdgeInsets.all(32.d),
        color: TColors.primary10.withOpacity(0.5),
        child: Asset.load<Image>('icon_sacrifice'));
  }
}
