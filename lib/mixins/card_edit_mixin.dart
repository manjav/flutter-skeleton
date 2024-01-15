import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_export.dart';

@optionalTypeArgs
mixin CardEditMixin<T extends AbstractPopup> on State<T> {
  late Account account;
  late AccountCard card;
  bool submitAvailable = false;
  List<AccountCard> cards = [];
  final Map<int, GlobalKey> _keys = {};
  final selectedCards = SelectedCards([]);

  @override
  void initState() {
    card = widget.args['card'];
    account = context.read<AccountProvider>().account;
    cards = getCards(account);
    super.initState();
  }

  Widget innerChromeFactory() {
    return Positioned(
        left: 0,
        right: 0,
        bottom: 32.d,
        top: 620.d,
        child: Asset.load<Image>("ui_popup_bottom",
            centerSlice: ImageCenterSliceData(
                200, 114, const Rect.fromLTWH(99, 4, 3, 3))));
  }

  List<AccountCard> getCards(Account account) =>
      (account.getReadyCards(removeHeroes: true)..remove(card))
          .reversed
          .toList();

  cardsListBuilder(Account account,
      {int crossAxisCount = 4, bool showCardTitle = false}) {
    var gap = 24.d;
    var itemSize =
        (DeviceInfo.size.width - gap * (crossAxisCount + 1)) / crossAxisCount;
    return Positioned(
      top: 484.d,
      bottom: 0.d,
      right: 0,
      left: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(96.d),
            bottomRight: Radius.circular(96.d)),
        child: Stack(
          children: [
            GridView.builder(
                itemCount: cards.length,
                padding: EdgeInsets.fromLTRB(28.d, 32.d, 28.d, 220.d),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: CardItem.aspectRatio,
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: gap,
                    mainAxisSpacing: gap),
                itemBuilder: (c, i) =>
                    cardItemBuilder(c, i, cards[i], itemSize, showCardTitle)),
            _bottomShade(0, 0),
          ],
        ),
      ),
    );
  }

  Widget? cardItemBuilder(BuildContext context, int index, AccountCard card,
      double itemSize, bool showCardTitle) {
    return Widgets.button(context,
        padding: EdgeInsets.zero,
        onPressed: () => onSelectCard(index, card),
        child: Stack(children: [
          CardItem(card,
              size: itemSize,
              showCooldown: false,
              showTitle: showCardTitle,
              key: getGlobalKey(card.id)),
          selectedCards.value.contains(card)
              ? Positioned(
                  top: 2.d,
                  left: 4.d,
                  bottom: 8.d,
                  right: 4.d,
                  child: selectedForeground())
              : const SizedBox()
        ]));
  }

  _bottomShade(double right, double left) {
    return Positioned(
        bottom: 0,
        left: left,
        right: right,
        height: 200.d,
        child: IgnorePointer(
            child: Asset.load<Image>("ui_shade_bottom",
                centerSlice: ImageCenterSliceData(
                    32, 32, const Rect.fromLTWH(0, 0, 32, 32)))));
  }

  selectedForeground() {
    return Widgets.rect(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20.d)),
            border: Border.all(
                color: TColors.black, width: 12.d, strokeAlign: 0.6)));
  }

  onSelectCard(int index, AccountCard card) => selectedCards.addCard(card);

  updateAccount(Map<String, dynamic> data) {
    for (var card in selectedCards.value) {
      account.cards.remove(card!.id);
    }
    context.read<AccountProvider>().update(context, data);
  }

  GlobalKey getGlobalKey(int key) =>
      _keys.containsKey(key) ? _keys[key]! : _keys[key] = GlobalKey();
}
