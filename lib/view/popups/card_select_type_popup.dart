import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/key_provider.dart';
import '../../view/popups/ipopup.dart';
import '../../view/widgets/skinnedtext.dart';
import '../items/card_item.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/indicator.dart';

class SelectTypePopup extends AbstractPopup {
  SelectTypePopup({super.key}) : super(Routes.popupSelectType, args: {});

  @override
  createState() => _SelectTypePopupState();
}

class _SelectTypePopupState extends AbstractPopupState<SelectTypePopup>
    with KeyProvider {
  late Account _account;
  int _selectedCardIndex = 0;
  int _selectedLevelIndex = 0;
  List<FruitData> _fruits = [];

  @override
  void initState() {
    super.initState();
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _fruits = _account.loadingData.fruits.map.values
        .where((f) => f.get<int>(FriutFields.category) < 3)
        .toList();
  }

  @override
  List<Widget> appBarElements() =>
      [Indicator(widget.type.name, AccountField.gold)];

  @override
  contentFactory() {
    var fruit = _fruits[_selectedCardIndex];
    return SizedBox(
        height: DeviceInfo.size.height * 0.7,
        child: Column(children: [
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
          Widgets.skinnedButton(
              label: "search_l".l(),
              width: 340.d,
              onPressed: () => Navigator.pop(context,
                  fruit.cards[_selectedLevelIndex].get(CardFields.id))),
        ]));
  }

  Widget _cardItemBuilder(int index, FruitData fruit) {
    var selected = _selectedCardIndex == index;
    return Widgets.button(
        height: 100.d,
        margin: EdgeInsets.all(10.d),
        padding: EdgeInsets.only(right: 24.d, left: 8.d),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(32.d)),
            color: selected ? TColors.orange : TColors.primary90,
            border: selected
                ? Border.all(
                    color: TColors.primary10, width: 10.d, strokeAlign: 0.6)
                : null),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardItem.getCardImage(fruit.cards[0], 76.d),
            SizedBox(width: 12.d),
            SkinnedText("${fruit.get(FriutFields.name)}_t".l())
          ],
        ),
        onPressed: () => setState(() => _selectedCardIndex = index));
  }

  Widget _levelItemBuilder(int index, FruitData fruit) {
    var selected = _selectedLevelIndex == index;
    return Widgets.button(
        padding: EdgeInsets.all(8.d),
        decoration: selected ? Widgets.imageDecore("level_badge_border") : null,
        child: Asset.load<Image>(
            "level_badge_${fruit.cards[index].get(CardFields.rarity)}",
            width: 100.d),
        onPressed: () => setState(() => _selectedLevelIndex = index));
  }
}
