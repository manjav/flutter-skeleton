import 'dart:convert';

import 'package:flutter/material.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/fruit.dart';
import '../../data/core/rpc.dart';
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
  HeroPopup({super.key}) : super(Routes.popupHero, args: {});

  @override
  createState() => _HeroPopupState();

  static Widget attributesBuilder(HeroCard hero, Map<String, int> attributes) {
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

  static Widget _attributeBuilder(
      HeroCard hero, MapEntry<String, int> attribute) {
    var benefits = {
      "blessing": "benefit_gold",
      "power": "benefit_power",
      "wisdom": "benefit_cooldown"
    };
    return Row(children: [
      Asset.load<Image>(benefits[attribute.key]!, width: 56.d),
      SkinnedText(" ${hero.card.base.map['${attribute.key}Attribute']}"),
      SkinnedText(" + ${attribute.value}",
          style: TStyles.medium.copyWith(color: TColors.green)),
    ]);
  }
}

class _HeroPopupState extends AbstractPopupState<HeroPopup> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  late Account _account;
  late List<HeroCard> _heroes;
  late List<GlobalKey> _keys;
  final List<BaseHeroItem> _minions = [];
  final List<BaseHeroItem> _weapons = [];

  @override
  void initState() {
    alignment = const Alignment(0, -0.8);
    super.initState();
    _account = accountBloc.account!;
    var heroes = _account.heroes.values.toList();
    _heroes = List.generate(heroes.length, (index) => heroes[index].clone());
    _keys = List.generate(_heroes.length, (index) => GlobalKey());
    for (var item in _account.loadingData.baseHeroItems.values) {
      if (item.category == 1) {
        _minions.add(item);
      } else {
        _weapons.add(item);
      }
    }
  }

  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(48.d, 132.d, 48.d, 72.d);

  @override
  Widget closeButtonFactory() => const SizedBox();

  @override
  contentFactory() {
    return SizedBox(
      width: 920.d,
      height: DeviceInfo.size.height * 0.42,
      child: ValueListenableBuilder(
          valueListenable: _selectedIndex,
          builder: (context, value, child) {
            var hero = _heroes[value];
            var name = hero.card.base
                .get<Fruit>(CardFields.fruit)
                .name;
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
              HeroPopup.attributesBuilder(
                  hero, hero.getGainedAttributesByItems()),
              SizedBox(height: 40.d),
              SizedBox(
                  height: 128.d,
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Widgets.skinnedButton(
                            label: "×",
                            width: 140.d,
                            padding: EdgeInsets.only(bottom: 12.d),
                            onPressed: () => Navigator.pop(context)),
                        SizedBox(width: 12.d),
                        Widgets.skinnedButton(
                            label: "Save",
                            width: 320.d,
                            color: ButtonColor.green,
                            padding: EdgeInsets.only(bottom: 16.d),
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
            decoration:
                Widgets.imageDecore("rect_${item == null ? "add" : "remove"}"),
            child: item == null
                ? const SizedBox()
                : Asset.load<Image>("heroitem_${item.base.image}"),
            onPressed: () {
              if (item != null) {
                _heroes[_selectedIndex.value].items.remove(item);
                setState(() {});
                return;
              }
              showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: TColors.transparent,
                  barrierColor: TColors.transparent,
                  builder: (BuildContext context) =>
                      _itemListBottomSheet(index));
            }));
  }

  _itemListBottomSheet(int index) {
    var isWeapons = index > 1;
    var items = isWeapons ? _weapons : _minions;
    return Widgets.rect(
        decoration: BoxDecoration(
          color: TColors.primary90,
          border: Border.all(color: TColors.clay, width: 8.d),
          borderRadius: BorderRadius.vertical(top: Radius.circular(80.d)),
        ),
        child: Column(
          children: [
            SizedBox(height: 20.d),
            SkinnedText(isWeapons ? "weapons_l".l() : "minions_l".l(),
                style: TStyles.large),
            Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(100.d)),
                    child: ListView.builder(
                        padding: EdgeInsets.all(12.d),
                        itemExtent: 240.d,
                        itemBuilder: (c, i) => _itemBuilder(items[i], index),
                        itemCount: items.length))),
          ],
        ));
  }

  Widget? _itemBuilder(BaseHeroItem item, int position) {
    var host = item.getHost(_heroes);
    var heroItem = item.getUsage(_account.heroitems.values.toList());
    var isActive = host == null || heroItem != null;
    return Widgets.button(
        radius: 44.d,
        color: TColors.primary80,
        margin: EdgeInsets.all(12.d),
        padding: EdgeInsets.all(12.d),
        child: Row(children: [
          Opacity(
              opacity: isActive ? 1 : 0.5,
              child: Asset.load<Image>("heroitem_${item.image}",
                  width: 180.d, height: 180.d)),
          SizedBox(width: 24.d),
          Expanded(
              child: Opacity(
                  opacity: isActive ? 1 : 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkinnedText("heroitem_${item.id}".l()),
                      Expanded(
                          child: Text("heroitem_${item.id}_description".l(),
                              style: TStyles.small.copyWith(height: 1))),
                      Row(
                        children: [
                          _itemAttributeBuilder("power", item.powerAmount),
                          _itemAttributeBuilder("cooldown", item.wisdomAmount),
                          _itemAttributeBuilder("gold", item.blessingAmount),
                        ],
                      )
                    ],
                  ))),
          SizedBox(width: 12.d),
          Widgets.rect(
              alignment: Alignment.center,
              width: 200.d,
              child: IgnorePointer(
                  ignoring: true,
                  child: _itemActionBuilder(item, heroItem != null, host))),
        ]),
        onPressed: () => _setItem(item, position, heroItem, host));
  }

  Widget _itemAttributeBuilder(String attribute, int value) {
    return Row(children: [
      Asset.load<Image>("benefit_$attribute", width: 56.d),
      Text(" +$value   "),
    ]);
  }

  _itemActionBuilder(BaseHeroItem item, bool isAvailable, HeroCard? host) {
    if (isAvailable) {
      if (host != null) {
        return _lockItem("icon_used",
            "${host.card.fruit.name}_t".l());
      }
      return Widgets.skinnedButton(
        width: 320.d,
        height: 120.d,
        label: "use_l".l(),
        color: ButtonColor.green,
        padding: EdgeInsets.only(bottom: 16.d),
      );
    }

    if (item.unlockLevel > _account.hero_max_rarity) {
      return _lockItem("icon_locked", "level_l".l([item.unlockLevel]));
    }
    return Widgets.skinnedButton(
      height: 120.d,
      icon: "icon_nectar",
      label: "${item.cost}",
      color: ButtonColor.teal,
      padding: EdgeInsets.only(right: 16.d, bottom: 16.d),
    );
  }

  Widget _lockItem(String icon, String text) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Asset.load<Image>(icon, height: 60.d),
      SizedBox(height: 12.d),
      Widgets.rect(
          padding: EdgeInsets.symmetric(horizontal: 8.d),
          radius: 12.d,
          color: TColors.primary10,
          child: Text(text, style: TStyles.smallInvert))
    ]);
  }

  _setItem(
      BaseHeroItem item, int position, HeroItem? heroItem, HeroCard? host) {
    if (heroItem == null) {
      if (item.unlockLevel > _account.hero_max_rarity) {
        toast("heroitem_locked".l([item.unlockLevel]));
      } else {
        _buyItem(item);
      }
      return;
    }

    if (host != null) {
      toast("heroitem_used"
          .l(["${host.card.fruit.name}_t".l()]));
      return;
    }

    heroItem.position = (position % 2) == 0 ? 1 : -1;
    _heroes[_selectedIndex.value].items.add(heroItem);
    setState(() {});
    Navigator.pop(context);
  }

  _saveChanges() async {
    var params = <String, dynamic>{"default_hero_id": _account.base_hero_id};
    var heroDetails = [];
    for (var hero in _heroes) {
      heroDetails.add(hero.getResult());
    }
    params["hero_details"] = jsonEncode(heroDetails);
    try {
      await _tryRPC(RpcId.equipHeroitems, params);
      for (var hero in _heroes) {
        _account.heroes[hero.card.id] = hero;
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {}
  }

  _buyItem(BaseHeroItem item) async {
    try {
      var result =
          await _tryRPC(RpcId.buyHeroItem, {RpcParams.id.name: item.id});
      int id = result["heroitem_id"];
      _account.heroitems[id] = HeroItem(id, item, 0);
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {}
  }

  _tryRPC(RpcId id, Map<String, dynamic> params) async {
    try {
      var data = await rpc(id, params: params);
      _account.update(data);
      if (!mounted) return;
      accountBloc.add(SetAccount(account: _account));
      setState(() {});
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
