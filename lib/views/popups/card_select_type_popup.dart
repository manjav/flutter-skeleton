import 'package:flutter/material.dart';

import '../../app_export.dart';

class SelectCardTypePopup extends AbstractPopup {
  SelectCardTypePopup({super.key})
      : super(Routes.popupCardSelectType, args: {});

  @override
  createState() => _SelectTypePopupState();
}

class _SelectTypePopupState extends AbstractPopupState<SelectCardTypePopup>
    with KeyProvider {
  late Account _account;
  int _selectedCardIndex = 0;
  int _selectedLevelIndex = 0;
  List<Fruit> _fruits = [];

  @override
  void initState() {
    super.initState();
    _account = accountProvider.account;
    _fruits = _account.loadingData.fruits.values
        .where((f) => f.category < 3)
        .toList();
  }

  @override
  List<Widget> appBarElements() => [Indicator(widget.name, Values.gold)];

  @override
  Widget innerChromeFactory() {
    return Positioned(
      top: 68.d,
      left: 0,
      right: 0,
      bottom: 464.d,
      child: Asset.load<Image>('popup_header',
          centerSlice: ImageCenterSliceData(
              220, 120, const Rect.fromLTWH(106, 110, 4, 4))),
    );
  }

  @override
  contentFactory() {
    var fruit = _fruits[_selectedCardIndex];
    return SizedBox(
        height: DeviceInfo.size.height * 0.7,
        child: Column(children: [
          SizedBox(height: 20.d),
          Expanded(
              child: SingleChildScrollView(
                  child: Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: 16.d,
                      spacing: 16.d,
                      children: [
                for (var i = 0; i < _fruits.length; i++)
                  _cardItemBuilder(i, _fruits[i])
              ]))),
          SizedBox(height: 48.d),
          Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < fruit.cards.length; i++)
              _levelItemBuilder(i, fruit)
          ]),
          SizedBox(height: 48.d),
          Widgets.skinnedButton(context,
              label: "search_l".l(),
              width: 340.d,
              onPressed: () =>
                  Navigator.pop(context, fruit.cards[_selectedLevelIndex].id)),
        ]));
  }

  Widget _cardItemBuilder(int index, Fruit fruit) {
    var selected = _selectedCardIndex == index;
    return Widgets.button(context,
        height: 100.d,
        margin: EdgeInsets.all(10.d),
        padding: EdgeInsets.only(right: 24.d, left: 8.d),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(32.d)),
            color: selected ? TColors.orange : TColors.primary80,
            border: selected
                ? Border.all(
                    color: TColors.primary10, width: 10.d, strokeAlign: 0.6)
                : null),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardItem.getCardImage(fruit.cards[0], 76.d),
            SizedBox(width: 12.d),
            SkinnedText("${fruit.name}_t".l())
          ],
        ),
        onPressed: () => setState(() => _selectedCardIndex = index));
  }

  Widget _levelItemBuilder(int index, Fruit fruit) {
    var selected = _selectedLevelIndex == index;
    return Widgets.button(context,
        padding: EdgeInsets.all(8.d),
        decoration:
            selected ? Widgets.imageDecorator("level_badge_border") : null,
        child: Asset.load<Image>("level_badge_${fruit.cards[index].rarity}",
            width: 100.d),
        onPressed: () => setState(() => _selectedLevelIndex = index));
  }
}
