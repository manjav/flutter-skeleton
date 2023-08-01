import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/blocs/account_bloc.dart';
import 'package:flutter_skeleton/data/core/account.dart';
import 'package:flutter_skeleton/data/core/card.dart';
import 'package:flutter_skeleton/services/deviceinfo.dart';
import 'package:flutter_skeleton/services/localization.dart';
import 'package:flutter_skeleton/services/theme.dart';
import 'package:flutter_skeleton/view/widgets/skinnedtext.dart';

import '../../utils/assets.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/loaderwidget.dart';

class HeroPopup extends AbstractPopup {
  const HeroPopup({super.key, required super.args}) : super(Routes.popupHero);

  @override
  createState() => _HeroPopupState();
}

class _HeroPopupState extends AbstractPopupState<HeroPopup> {
  int _selectedIndex = 0;

  late Account _account;
  late List<HeroCard> _cards;
  late List<GlobalKey> _keys;
  List<BaseHeroItem> _minions = [];
  List<BaseHeroItem> _weapons = [];
  late Map<int, BaseHeroItem> _baseHeroItems;
  Map<String, String> benefits = {
    "blessing": "benefit_gold",
    "power": "benefit_power",
    "wisdom": "benefit_cooldown"
  };

  @override
  void initState() {
    super.initState();
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _cards =
        _account.get<Map<int, HeroCard>>(AccountField.heroes).values.toList();
    _keys = List.generate(_cards.length, (index) => GlobalKey());
    _baseHeroItems = _account.get(AccountField.base_heroitems);
    for (var item in _baseHeroItems.values) {
      if (item.category == 1) {
        _minions.add(item);
      } else {
        _weapons.add(item);
      }
    }
  }

  @override
  contentFactory() {
    var hero = _cards[_selectedIndex];
    var name = hero.card.base
        .get<FruitData>(CardFields.fruit)
        .get<String>(FriutFields.name);
    return SizedBox(
      width: 920.d,
      height: DeviceInfo.size.height * 0.6,
      child: Column(children: [
        SkinnedText("${name}_t".l()),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Widgets.button(
                padding: EdgeInsets.all(22.d),
                width: 120.d,
                height: 120.d,
                onPressed: () => _setIndex(-1),
                child: Asset.load<Image>('arrow_left')),
            Stack(alignment: Alignment.center, children: [
              Asset.load<Image>("card_frame_hero_edit", width: 420.d),
              LoaderWidget(AssetType.image, name,
                  subFolder: "cards", width: 320.d, key: _keys[_selectedIndex]),
            ]),
            Widgets.button(
                padding: EdgeInsets.all(22.d),
                width: 120.d,
                height: 120.d,
                onPressed: () => _setIndex(1),
                child: Asset.load<Image>('arrow_right')),
          ],
        ),
        SizedBox(height: 24.d),
        _attributesBuilder(hero),
        Text("minions_l".l()),
        _itemsListBuilder(_minions),
        Text("weapons_l".l()),
        _itemsListBuilder(_weapons),
      ]),
    );
  }

  void _setIndex(int offset) {
    _selectedIndex = (_selectedIndex + offset) % _cards.length;
    setState(() {});
  }

  Widget _attributesBuilder(HeroCard hero) {
    var attributes = hero.getGainedAttributesByItems();
    return Widgets.rect(
        radius: 32.d,
        width: 640.d,
        color: TColors.primary90,
        padding: EdgeInsets.all(16.d),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var attribute in attributes.entries)
                _attributeBuilder(hero, attribute)
            ]));
  }

  Widget _attributeBuilder(HeroCard hero, MapEntry<String, int> attribute) {
    return Row(children: [
      Asset.load<Image>(benefits[attribute.key]!, width: 56.d),
      SkinnedText(" ${hero.card.base.map['${attribute.key}Attribute']}"),
      SkinnedText(" + ${attribute.value}",
          style: TStyles.medium.copyWith(color: TColors.green)),
    ]);
  }

  _itemsListBuilder(List<BaseHeroItem> items) {
    return Widgets.rect(
        height: 200.d,
        width: 900.d,
        child: ListView.builder(
          itemExtent: 200.d,
          scrollDirection: Axis.horizontal,
          itemBuilder: (c, i) => _itemBuilder(i, items[i]),
          itemCount: items.length,
        ));
  }

  Widget? _itemBuilder(int index, BaseHeroItem item) {
    return Widgets.button(
        color: TColors.accent,
        margin: EdgeInsets.all(12.d),
        child: Asset.load<Image>("heroitem_${item.image}"));
  }
}
