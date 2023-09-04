import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
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
import '../../view/widgets/skinnedtext.dart';
import '../items/card_item.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'ipopup.dart';

class CardMergePopup extends AbstractPopup {
  const CardMergePopup({super.key, required super.args})
      : super(Routes.popupCardMerge);

  @override
  createState() => _CardMergePopupState();
}

class _CardMergePopupState extends AbstractPopupState<CardMergePopup>
    with CardEditMixin {
  @override
  void initState() {
    selectedCards.addCard(widget.args['card']);
    contentPadding = EdgeInsets.fromLTRB(0.d, 142.d, 0.d, 32.d);
    super.initState();
  }

  List<AccountCard> get allReadyCards => BlocProvider.of<AccountBloc>(context)
      .account!
      .getReadyCards(removeMaxLevels: true);
  @override
  getCards(Account account) {
    var all = allReadyCards;
    if (selectedCards.value.isNotEmpty) {
      return all.where((c) => c.base == selectedCards.value[0]!.base).toList();
    }
    return all
        .where(
            (c) => all.where((c1) => c.base == c1.base && c != c1).isNotEmpty)
        .toList();
  }

  @override
  Widget contentFactory() {
    var account = BlocProvider.of<AccountBloc>(context).account!;
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: selectedCards,
        builder: (context, value, child) {
          cards = getCards(account);
          return SizedBox(
              width: 980.d,
              height: DeviceInfo.size.height - 550.d,
              child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Widgets.rect(
                        height: 440.d,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _cardHolder(0, 200.d),
                            const SkinnedText(" + "),
                            _cardHolder(1, 200.d),
                            const SkinnedText(" = "),
                            _cardHolder(-1, 270.d)
                          ],
                        )),
                    cardsListBuilder(account),
                    _submitButton(),
                  ]));
        });
  }

  // Only 2 cards can be selected
  @override
  onSelectCard(int index, AccountCard card) {
    if (selectedCards.value.length >= 2 &&
        !selectedCards.value.contains(card)) {
      selectedCards.value.removeLast();
    }
    selectedCards.addCard(card);
  }

  _cardHolder(int index, double size) {
    if (index == -1) {
      if (selectedCards.value.length >= 2) {
        var card = selectedCards.value[0]!;
        var nextBaseCard = card.findNextLevel();
        var nextCard = AccountCard(account, {
          "power": card.getNextLevelPower(selectedCards.value[1]),
          "base_card_id": nextBaseCard!.get(CardFields.id)
        });
        return _getCardView(nextCard, size);
      }
      return Asset.load<Image>("card_placeholder", width: size);
    }

    if (index >= selectedCards.value.length) {
      return Asset.load<Image>("card_placeholder", width: size);
    }
    return Widgets.touchable(
      child: _getCardView(selectedCards.value[index]!, size),
      onTap: () => selectedCards.remove(selectedCards.value[index]!),
    );
  }

  _getCardView(AccountCard card, double size) {
    card = account.getCards()[card.id] ?? card;
    return SizedBox(
        width: size,
        child: CardItem(card,
            size: size, showCooldown: false, heroTag: "hero_${card.id}"));
  }

  _submitButton() {
    var bgCenterSlice = ImageCenterSliceDate(42, 42);
    return Positioned(
      bottom: 40.d,
      height: 170.d,
      child: Widgets.skinnedButton(
          isEnable: selectedCards.value.length >= 2,
          padding: EdgeInsets.fromLTRB(36.d, 16.d, 20.d, 29.d),
          child: Row(children: [
            SkinnedText("popupcardmerge".l(),
                style: TStyles.large.copyWith(height: 3.d)),
            SizedBox(width: 24.d),
            Widgets.rect(
              padding: EdgeInsets.only(right: 12.d),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      centerSlice: bgCenterSlice.centerSlice,
                      image: Asset.load<Image>('ui_frame_inside',
                              centerSlice: bgCenterSlice)
                          .image)),
              child: Row(children: [
                Asset.load<Image>("icon_gold", height: 76.d),
                SkinnedText(_getMergeCost().compact(), style: TStyles.large),
              ]),
            )
          ]),
          onPressed: _merge),
    );
  }

  int _getMergeCost() {
    const evolveCostModifier = 1;
    const vetEvolveCostModifier = 2;
    const evolveCostCorrectionModifier = -2;
    const monsterEvolveMinRarity = 5;
    const monsterEvolveMinCost = 400000000;

    if (selectedCards.value.length < 2) return 0;
    var first = selectedCards.value.first!;
    var goldPrice = 0;
    for (var card in selectedCards.value) {
      goldPrice += card!.base.cost;
    }
    var nextCardPrice = first.findNextLevel()!.cost;
    var veteranLevel = first.base.get<int>(CardFields.veteran_level);
    if (veteranLevel == 0) {
      goldPrice = ((nextCardPrice - goldPrice) * evolveCostModifier).floor();
      if (goldPrice < 0) {
        goldPrice *= evolveCostCorrectionModifier;
      }

      // Soften Monster's evolve cost after adding 6th level of monsters
      var level = first.base.get<int>(CardFields.rarity);
      if (first.isMonster && level >= monsterEvolveMinRarity) {
        goldPrice =
            monsterEvolveMinCost * (level - (monsterEvolveMinRarity - 1));
      }
    } else {
      goldPrice =
          ((nextCardPrice - goldPrice) * vetEvolveCostModifier * veteranLevel)
              .floor();
    }
    return goldPrice;
  }

  _merge() async {
    if (selectedCards.value.length < 2) return;
    var params = {RpcParams.sacrifices.name: selectedCards.getIds()};
    try {
      var result = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.evolveCard, params: params);
      updateAccount(result);
    } finally {}
    cards = getCards(account);
    if (cards.length < 2) {
      // Show other mergable cards
      selectedCards.clear();
      await Future.delayed(const Duration(milliseconds: 50));
      // Close if mergable cards not available
      if (mounted && cards.length < 2) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else {
      // Add onother same-type mergable card
      selectedCards.value.clear();
      selectedCards.addCard(cards[0]);
    }
  }
}
