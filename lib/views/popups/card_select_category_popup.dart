import 'package:flutter/material.dart';

import '../../app_export.dart';

class SelectCardCategoryPopup extends AbstractPopup {
  SelectCardCategoryPopup({super.key})
      : super(Routes.popupCardSelectCategory, args: {});

  @override
  createState() => _SelectTypePopupState();
}

class _SelectTypePopupState extends AbstractPopupState<SelectCardCategoryPopup>
    with KeyProvider {
  late Account _account;
  int _selectedCategory = 0;
  int _selectedLevelIndex = 0;
  int _cheapestMode = 0;
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
    var fruit = _fruits.firstWhere((f) => f.category == _selectedCategory);
    return SizedBox(
        // height: DeviceInfo.size.height * 0.5,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(height: 20.d),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _categoryItemBuilder(0),
        _categoryItemBuilder(1),
        _categoryItemBuilder(2),
      ]),
      SizedBox(height: 48.d),
      Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < fruit.cards.length; i++) _levelItemBuilder(i, fruit)
      ]),
      SizedBox(height: 48.d),
      Row(
          mainAxisSize: MainAxisSize.min,
          children: [_checkbox("asc", 0), _checkbox("desc", 1)]),
      SizedBox(height: 48.d),
      Widgets.skinnedButton(context,
          width: 340.d,
          label: "search_l".l(),
          onPressed: () => Navigator.pop(context, {
                "category": _selectedCategory,
                "cheapest": _cheapestMode,
                "rarity": _selectedLevelIndex + 1
              })),
    ]));
  }

  Widget _categoryItemBuilder(int category) {
    var selected = _selectedCategory == category;
    return Widgets.button(context,
        margin: EdgeInsets.all(8.d),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: CardItem.getCardBackground(category,
                        _selectedCategory == 0 ? _selectedLevelIndex + 1 : 1)
                    .image),
            borderRadius: BorderRadius.all(Radius.circular(32.d)),
            border: Border.all(
                color: selected ? TColors.blue : TColors.transparent,
                width: 16.d,
                strokeAlign: -2.d)),
        width: 260.d,
        height: 260.d / CardItem.aspectRatio,
        child: SkinnedText(
          "card_category_$category".l(),
          textAlign: TextAlign.center,
        ),
        onPressed: () => setState(() => _selectedCategory = category));
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

  Widget _checkbox(String label, int mode) {
    return Widgets.checkbox(
        context, "auction_price_$label".l(), _cheapestMode == mode,
        onSelect: () => setState(() => _cheapestMode = mode));
  }
}
