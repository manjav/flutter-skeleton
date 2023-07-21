import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/data/core/rpc.dart';
import 'package:flutter_skeleton/services/connection/http_connection.dart';
import 'package:flutter_skeleton/utils/utils.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services.dart';
import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/items/card_item_minimal.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/card_holder.dart';
import 'ipopup.dart';

class CardEnhancePopup extends AbstractPopup {
  const CardEnhancePopup({super.key, required super.args})
      : super(Routes.popupCardEnhance);

  @override
  createState() => _CardEnhancePopupState();
}

class _CardEnhancePopupState extends AbstractPopupState<CardEnhancePopup> {
  final _selectedCards = SelectedCards([]);
  late AccountCard _card;

  bool _isSacrificeAvailable = false;

  @override
  void initState() {
    _card = widget.args['card'];
    contentPadding = EdgeInsets.fromLTRB(24.d, 142.d, 24.d, 32.d);
    super.initState();
  }

  @override
  titleBuilder() => "card_enhance".l();

  @override
  Widget contentFactory() {
    var gap = 10.d;
    var crossAxisCount = 5;
    var itemSize =
        (DeviceInfo.size.width - gap * (crossAxisCount + 1)) / crossAxisCount;
    var cards = BlocProvider.of<AccountBloc>(context).account!.getReadyCards()
      ..remove(_card);
    cards.reverseRange(0, cards.length);
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: _selectedCards,
        builder: (context, value, child) {
          return SizedBox(
              width: 980.d,
              height: 1280.d,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                      bottom: 0,
                      right: -contentPadding.right,
                      left: -contentPadding.left,
                      height: 846.d,
                      child: Asset.load<Image>("ui_popup_bottom",
                          centerSlice: ImageCenterSliceDate(
                              200, 114, const Rect.fromLTWH(99, 4, 3, 3)))),
                  Positioned(
                      height: 838.d,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(64.d),
                              bottomRight: Radius.circular(64.d)),
                          child: GridView.builder(
                              itemCount: cards.length,
                              padding: EdgeInsets.fromLTRB(0, 32.d, 0, 220.d),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 0.74,
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: gap,
                                      mainAxisSpacing: gap),
                              itemBuilder: (c, i) =>
                                  _cardItemBuilder(c, i, cards[i], itemSize)))),
                  SizedBox(
                      width: 300.d,
                      child: MinimalCardItem(_card,
                          size: 300.d, extraPower: _getSacrificesPower())),
                  Positioned(
                      bottom: 0,
                      right: -contentPadding.right,
                      left: -contentPadding.left,
                      height: 200.d,
                      child: IgnorePointer(
                          ignoring: true,
                          child: Asset.load<Image>("ui_shade_bottom",
                              centerSlice: ImageCenterSliceDate(200, 165,
                                  const Rect.fromLTWH(98, 1, 3, 160))))),
                  _isSacrificeAvailable || _selectedCards.value.isEmpty
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

  Widget? _cardItemBuilder(
      BuildContext context, int index, AccountCard card, double itemSize) {
    return Widgets.button(
        padding: EdgeInsets.zero,
        onPressed: () => _selectedCards.addCard(card),
        child: Stack(
          children: [
            MinimalCardItem(card, size: itemSize),
            _selectedCards.value.contains(card)
                ? Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Widgets.rect(
                        radius: 16.d,
                        padding: EdgeInsets.all(32.d),
                        color: TColors.primary10.withOpacity(0.4),
                        child: Asset.load<Image>('icon_sacrifice')))
                : const SizedBox()
          ],
        ));
  }

  _scarificeButton() {
    var bgCenterSlice = ImageCenterSliceDate(42, 42);
    return Opacity(
        opacity: _isSacrificeAvailable ? 1 : 0.8,
        child: Widgets.labeledButton(
            padding: EdgeInsets.fromLTRB(36.d, 16.d, 20.d, 29.d),
            child: Row(
              children: [
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Asset.load<Image>("card_sacrifice", height: 64.d),
                          SkinnedText(" x${_selectedCards.value.length}"),
                        ]),
                        Row(children: [
                          Asset.load<Image>("ui_gold", height: 76.d),
                          SkinnedText(_getSacrificeCost().compact(),
                              style: TStyles.large),
                        ]),
                      ],
                    ))
              ],
            ),
            onPressed: _sacrifice));
  }

  _sacrifice() async {
    if (!_isSacrificeAvailable) return;
    var params = {
      RpcParams.card_id.name: _card.id,
      RpcParams.sacrifices.name: _selectedCards.getIds()
    };
    try {
      var result = await BlocProvider.of<Services>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.enhanceCard, params: params);
      if (!mounted) return;
      var accountBloc = BlocProvider.of<AccountBloc>(context);
      accountBloc.account!.update(result);
      accountBloc.add(SetAccount(account: accountBloc.account!));
    } finally {}

    // {"card_id":407069,"sacrifices":"[407579]"}
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
    for (var card in _selectedCards.value) {
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

    var rarity = _card.base.get<double>(CardFields.virtualRarity);
    var verteranLevel = _card.base.get<int>(CardFields.veteran_level);
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
        _card.power + calculatePower <=
            _card.base.get<int>(CardFields.powerLimit);
    return calculatePower;
  }

  int _getSacrificeCost() {
    const enhancementCostModifier = 0.1;
    var cardPrices = 0;
    for (var card in _selectedCards.value) {
      cardPrices += card!.cost;
    }
    return (cardPrices * enhancementCostModifier).round();
  }
}
