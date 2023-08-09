import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/key_provider_mixin.dart';
import '../../view/widgets.dart';
import '../../view/widgets/skinnedtext.dart';
import '../items/card_item_minimal.dart';
import '../route_provider.dart';
import '../widgets/loaderwidget.dart';
import 'ipopup.dart';

class CollectionPopup extends AbstractPopup {
  const CollectionPopup({super.key, required super.args})
      : super(Routes.popupCollection);

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
    var account = BlocProvider.of<AccountBloc>(context).account!;
    _fruits = account.loadingData.fruits.map.values.toList();
    _avaibledCards = Set<int>.from(account.get(AccountField.collection));
    _selectedFruit = ValueNotifier(_fruits[0]);
    contentPadding = EdgeInsets.fromLTRB(0.d, 142.d, 0.d, 32.d);
    super.initState();
  }

  @override
  Widget innerChromeFactory() {
    return Positioned(
      top: 68.d,
      left: 0,
      right: 0,
      height: 800.d,
      child: Asset.load<Image>('popup_header',
          centerSlice: ImageCenterSliceDate(
            220,
            120,
            const Rect.fromLTWH(106, 110, 4, 4),
          )),
    );
  }

  @override
  Widget contentFactory() {
    return ValueListenableBuilder<FruitData>(
        valueListenable: _selectedFruit,
        builder: (context, value, child) {
          return Stack(alignment: Alignment.center, children: [
            _cardsListBuilder(value),
            Positioned(
                top: 20.d,
                child: Widgets.rect(
                    radius: 16.d,
                    color: TColors.primary70,
                    padding: EdgeInsets.symmetric(horizontal: 30.d),
                    child: SkinnedText(
                        "${value.get<String>(FriutFields.name)}_t".l()))),
            _fruitsListBuilder(),
          ]);
        });
  }

  _cardsListBuilder(FruitData fruit) {
    var gap = 12.d;
    var width = 920.d;
    var crossAxisCount = 4;
    var itemSize = (width - gap * (crossAxisCount + 1)) / crossAxisCount;
    return Positioned(
        top: 100.d,
        width: width,
        height: 620.d,
        child: GridView.builder(
          itemCount: fruit.cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 0.74,
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: gap,
              mainAxisSpacing: gap),
          itemBuilder: (c, i) => _cardItemBuilder(i, fruit.cards[i], itemSize),
        ));
  }

  Widget? _cardItemBuilder(int index, CardData card, double itemSize) {
    return Stack(alignment: Alignment.center, children: [
      MinimalCardItem.getCardBackground(card),
      MinimalCardItem.getCardImage(card, itemSize * 0.9,
          key: getGlobalKey(card.get(CardFields.id))),
      Positioned(
          top: 1.d,
          right: 20.d,
          child: SkinnedText(card.get<int>(CardFields.rarity).toString()))
    ]);
  }

  _fruitsListBuilder({int crossAxisCount = 5}) {
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

  _fruitItemBuilder(int index, FruitData fruit) {
    var selected = _selectedFruit.value == fruit;
    var id = fruit.get<int>(FriutFields.id);
    var name = fruit.get<String>(FriutFields.name);
    if (fruit.get<int>(FriutFields.category) < 4) name += " 1";

    return Widgets.button(
        margin: EdgeInsets.all(10.d),
        padding: EdgeInsets.all(16.d),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(48.d)),
            color: selected ? TColors.orange : TColors.primary90,
            border: selected
                ? Border.all(color: TColors.black, width: 8.d, strokeAlign: 0.6)
                : null),
        child: _avaibledCards.contains(id)
            ? LoaderWidget(AssetType.image, name,
                subFolder: "cards", width: 98.d)
            : Asset.load("deck_placeholder_card"),
        onPressed: () => _selectedFruit.value = fruit);
  }
}
