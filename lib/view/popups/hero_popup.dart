import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/popups/ipopup.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/loaderwidget.dart';

class HeroPopup extends AbstractPopup {
  const HeroPopup({super.key, required super.args}) : super(Routes.popupHero);

  @override
  createState() => _HeroPopupState();
}

class _HeroPopupState extends AbstractPopupState<HeroPopup> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  late Account _account;
  late List<HeroCard> _heroes;
  late List<GlobalKey> _keys;
  final List<BaseHeroItem> _minions = [];
  final List<BaseHeroItem> _weapons = [];
  Map<String, String> benefits = {
    "blessing": "benefit_gold",
    "power": "benefit_power",
    "wisdom": "benefit_cooldown"
  };

  @override
  void initState() {
    alignment = const Alignment(0, -0.8);
    contentPadding = EdgeInsets.fromLTRB(48.d, 132.d, 48.d, 80.d);
    super.initState();
    _account = BlocProvider.of<AccountBloc>(context).account!;
    var heroes =
        _account.get<Map<int, HeroCard>>(AccountField.heroes).values.toList();
    _heroes = List.generate(heroes.length, (index) => heroes[index].clone());
    _keys = List.generate(_heroes.length, (index) => GlobalKey());
    var baseHeroItems = _account.get(AccountField.base_heroitems);
    for (var item in baseHeroItems.values) {
      if (item.category == 1) {
        _minions.add(item);
      } else {
        _weapons.add(item);
      }
    }
  }

  @override
  Widget closeButtonFactory() => const SizedBox();

  @override
  contentFactory() {
    return SizedBox(
      width: 920.d,
      height: DeviceInfo.size.height * 0.41,
      child: ValueListenableBuilder(
          valueListenable: _selectedIndex,
          builder: (context, value, child) {
            var hero = _heroes[value];
            var name = hero.card.base
                .get<FruitData>(CardFields.fruit)
                .get<String>(FriutFields.name);
            var items = List<HeroItem?>.generate(4, (i) => null);
            for (var item in hero.items) {
              if (item.base.category == 1) {
                items[item.position == 1 ? 0 : 1] = item;
              } else {
                items[item.position == 1 ? 2 : 3] = item;
              }
            }

            return Column(children: [
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
                        subFolder: "cards", width: 320.d, key: _keys[value]),
                    for (var i = 0; i < 4; i++) _itemHolder(i, items[i])
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
              SizedBox(height: 40.d),
              SizedBox(
                  height: 132.d,
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Widgets.skinnedButton(
                            label: "×",
                            width: 140.d,
                            onPressed: () => Navigator.pop(context)),
                        SizedBox(width: 12.d),
                        Widgets.skinnedButton(
                            label: "Save",
                            width: 320.d,
                            color: ButtonColor.green,
                            onPressed: _saveChanges),
                      ])),
            ]);
          }),
    );
  }

  void _setIndex(int offset) {
    _selectedIndex.value = (_selectedIndex.value + offset) % _heroes.length;
  }

  Widget _itemHolder(int index, HeroItem? item) {
    var padding = 20.d;
    return Positioned(
        left: index == 0 || index == 2 ? padding : null,
        top: index == 0 || index == 1 ? padding - 2 : null,
        right: index == 1 || index == 3 ? padding : null,
        bottom: index == 2 || index == 3 ? padding + 3 : null,
        child: Widgets.button(
            width: 144.d,
            height: 144.d,
            padding: EdgeInsets.all(12.d),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: Asset.load<Image>(
                            "rect_${item == null ? "add" : "remove"}")
                        .image)),
            child: item == null
                ? const SizedBox()
                : Asset.load<Image>("heroitem_${item.base.image}"),
            onPressed: () => showModalBottomSheet<void>(
                context: context,
                backgroundColor: TColors.transparent,
                barrierColor: TColors.transparent,
                builder: (BuildContext context) =>
                    _itemListBottomSheet(index))));
  }

  _itemListBottomSheet(int index) {
  }

  Widget _attributesBuilder(HeroCard hero) {
    var attributes = hero.getGainedAttributesByItems();
    return Widgets.rect(
        radius: 32.d,
        width: 700.d,
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
