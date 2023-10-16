import 'package:flutter/material.dart';

import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/widgets.dart';
import '../../view/widgets/skinnedtext.dart';
import '../items/card_item.dart';
import '../key_provider.dart';
import '../route_provider.dart';
import 'ipopup.dart';

class CollectionPopup extends AbstractPopup {
  CollectionPopup({super.key}) : super(Routes.popupCollection, args: {});

  @override
  createState() => _CollectionPopupState();
}

class _CollectionPopupState extends AbstractPopupState<CollectionPopup>
    with KeyProvider {
  late List<FruitData> _fruits;
  late Set<int> _avaibledCards;
  late final ValueNotifier<FruitData> _selectedFruit;

  @override
  void initState() {
    var account = accountBloc.account!;
    _fruits = account.loadingData.fruits.map.values.toList();
    _avaibledCards = Set<int>.from(account.get(AccountField.collection));
    _selectedFruit = ValueNotifier(_fruits[0]);
    super.initState();
  }

  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(0.d, 142.d, 0.d, 32.d);

  @override
  Widget innerChromeFactory() {
    return Positioned(
      top: 68.d,
      left: 0,
      right: 0,
      height: 800.d,
      child: Asset.load<Image>('popup_header',
          centerSlice: ImageCenterSliceData(
            220,
            120,
            const Rect.fromLTWH(106, 110, 4, 4),
          )),
    );
  }

  @override
  List<Widget> appBarElements() => [];

  @override
  Widget contentFactory() {
    return ValueListenableBuilder<FruitData>(
        valueListenable: _selectedFruit,
        builder: (context, value, child) {
          return Stack(alignment: Alignment.center, children: [
            _cardsListBuilder(value),
            Positioned(
                top: 4.d,
                child: Widgets.rect(
                    radius: 16.d,
                    color: TColors.primary70,
                    padding: EdgeInsets.symmetric(horizontal: 30.d),
                    child: SkinnedText(
                        "${value.get<String>(FriutFields.name)}_t".l(),
                        style: TStyles.large))),
            _fruitsListBuilder(),
          ]);
        });
  }

  Widget _cardsListBuilder(FruitData fruit) {
    var gap = 12.d;
    var len = fruit.cards[0].isHero ? 1 : fruit.cards.length;
    var crossAxisCount = len < 4 ? len % 4 : 4;
    var rows = (len / crossAxisCount).ceil();
    var itemSize = len < 4 ? 330.d : 220.d;
    return Positioned(
        top: 100.d,
        height: 620.d,
        child: Center(
          child: SizedBox(
              width: itemSize * crossAxisCount + gap * crossAxisCount + 1,
              height: itemSize / CardItem.aspectRatio * rows + (rows + 1) * gap,
              child: GridView.builder(
                itemCount: len,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: CardItem.aspectRatio,
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: gap,
                    mainAxisSpacing: gap),
                itemBuilder: (c, i) =>
                    _cardItemBuilder(i, fruit.cards[i], itemSize),
              )),
        ));
  }

  Widget? _cardItemBuilder(int index, CardData card, double itemSize) {
    var id = card.get<int>(CardFields.id);
    var level = card.get<int>(CardFields.rarity);
    return Stack(alignment: Alignment.center, children: [
      CardItem.getCardBackground(
          card.fruit.get<int>(FriutFields.category), level),
      _avaibledCards.contains(id)
          ? CardItem.getCardImage(card, itemSize * 0.9,
              key: getGlobalKey(card.get(CardFields.id)))
          : Asset.load<Image>("deck_placeholder_card", width: itemSize * 0.6),
      Positioned(
          top: itemSize * 0.01,
          right: itemSize * 0.1,
          width: itemSize * 0.1,
          child: SkinnedText(level.toString(),
              style: TStyles.large.copyWith(fontSize: itemSize * 0.18)))
    ]);
  }

  Widget _fruitsListBuilder({int crossAxisCount = 5}) {
    return Positioned(
        top: 720.d,
        left: 12.d,
        right: 12.d,
        bottom: 32.d,
        child: GridView.builder(
          itemCount: _fruits.length,
          padding: EdgeInsets.only(top: 32.d),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          itemBuilder: (c, i) => _fruitItemBuilder(i, _fruits[i]),
        ));
  }

  Widget _fruitItemBuilder(int index, FruitData fruit) {
    var selected = _selectedFruit.value == fruit;

    return Widgets.button(
        margin: EdgeInsets.all(10.d),
        padding: EdgeInsets.all(16.d),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(48.d)),
            color: selected ? TColors.orange : TColors.primary90,
            border: selected
                ? Border.all(
                    color: TColors.primary30, width: 8.d, strokeAlign: 0.6)
                : null),
        child: CardItem.getCardImage(fruit.cards[0], 98.d),
        onPressed: () => _selectedFruit.value = fruit);
  }
}
