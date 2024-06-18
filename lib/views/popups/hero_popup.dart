import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../app_export.dart';

class HeroPopup extends AbstractPopup {
  const HeroPopup({super.key}) : super(Routes.popupHero);

  int get selectedHero => args["card"];

  @override
  createState() => _HeroPopupState();

  static Widget attributesBuilder(
      HeroCard hero, Map<HeroAttribute, int> attributes) {
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
      HeroCard hero, MapEntry<HeroAttribute, int> attribute) {
    return Row(children: [
      Asset.load<Image>("benefit_${attribute.key.benefit}", width: 56.d),
      SkinnedText(" ${hero.card.base.attributes[attribute.key]} "),
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
  final ValueNotifier<bool> onBuy = ValueNotifier(false);

  @override
  void initState() {
    alignment = const Alignment(0, -0.8);
    super.initState();
    _account = accountProvider.account;
    var heroes = _account.heroes.values.toList();
    _heroes = List.generate(heroes.length, (index) => heroes[index].clone());
    _keys = List.generate(_heroes.length, (index) => GlobalKey());
    int index =
        _heroes.indexWhere((h) => h.card.fruit.id == widget.selectedHero);
    _selectedIndex.value = index == -1 && _heroes.isNotEmpty ? 0 : index;
    for (var item in _account.loadingData.baseHeroItems.values) {
      if (item.category == 1) {
        _minions.add(item);
      } else {
        _weapons.add(item);
      }
    }
  }

  @override
  void onTutorialStep(data) {
    if (data["id"] == 406) {
      _itemHolderPress(0, null);
    } else if (data["id"] == 407) {
      _setItem(_minions[1], 0, null, null);
    } else if (data["id"] == 501) {
      var item = _minions[1];
      var host = item.getHost(_heroes);
      var heroItem = item.getUsage(_account.heroItems.values.toList());
      _setItem(_minions[1], 0, heroItem, host);
    }
    super.onTutorialStep(data);
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
            var name = hero.card.base.fruit.name;
            var items = List<HeroItem?>.generate(4, (i) => null);
            for (var item in hero.items) {
              if (item.base.category == 1) {
                items[item.position == 1 ? 0 : 1] = item;
              } else {
                items[item.position == 1 ? 2 : 3] = item;
              }
            }

            return Column(children: [
              SkinnedText("${name}_title".l()),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _heroes.length > 1
                      ? Widgets.button(context,
                          padding: EdgeInsets.all(22.d),
                          width: 120.d,
                          height: 120.d,
                          onPressed: () => _setIndex(-1),
                          child: Asset.load<Image>('arrow_left'))
                      : const SizedBox(),
                  Stack(alignment: Alignment.center, children: [
                    Asset.load<Image>("card_frame_hero_edit", width: 420.d),
                    LoaderWidget(AssetType.image, name,
                        subFolder: "cards", width: 320.d, key: _keys[value]),
                    for (var i = 0; i < 4; i++) _itemHolder(i, items[i])
                  ]),
                  _heroes.length > 1
                      ? Widgets.button(context,
                          padding: EdgeInsets.all(22.d),
                          width: 120.d,
                          height: 120.d,
                          onPressed: () => _setIndex(1),
                          child: Asset.load<Image>('arrow_right'))
                      : const SizedBox(),
                ],
              ),
              SizedBox(height: 24.d),
              HeroPopup.attributesBuilder(
                  hero, hero.getGainedAttributesByItems()),
              SizedBox(height: 40.d),
              SizedBox(
                  height: 160.d,
                  child: Row(
                      textDirection: TextDirection.ltr,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SkinnedButton(
                            color: ButtonColor.cream,
                            label: "cancel_l".l(),
                            width: 340.d,
                            padding: EdgeInsets.only(bottom: 12.d),
                            onPressed: () => Navigator.pop(context)),
                        SizedBox(width: 12.d),
                        SkinnedButton(
                            label: "save_l".l(),
                            width: 340.d,
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
        context,
        width: 144.d,
        height: 144.d,
        padding: EdgeInsets.all(12.d),
        decoration:
            Widgets.imageDecorator("rect_${item == null ? "add" : "remove"}"),
        child: item == null
            ? const SizedBox()
            : Asset.load<Image>("heroitem_${item.base.image}"),
        onPressed: () => _itemHolderPress(index, item),
      ),
    );
  }

  _itemHolderPress(int index, HeroItem? item) {
    if (item != null) {
      _heroes[_selectedIndex.value].items.remove(item);
      setState(() {});
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: TColors.transparent,
      barrierColor: TColors.transparent,
      builder: (BuildContext context) => _itemListBottomSheet(index),
    );
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
              child: ValueListenableBuilder(
                valueListenable: onBuy,
                builder: (context, value, child) {
                  return ListView.builder(
                    padding: EdgeInsets.all(12.d),
                    itemExtent: 240.d,
                    itemBuilder: (c, i) => _itemBuilder(items[i], index),
                    itemCount: items.length,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _itemBuilder(BaseHeroItem item, int position) {
    var host = item.getHost(_heroes);
    var heroItem = item.getUsage(_account.heroItems.values.toList());
    bool haveItem = _account.heroItems.values
            .firstWhereOrNull((element) => element.base.id == item.id) !=
        null;
    var isActive = host == null || heroItem != null;
    return Widgets.button(context,
        radius: 44.d,
        color: TColors.primary80,
        margin: EdgeInsets.all(12.d),
        padding: EdgeInsets.all(12.d),
        child: Row(
          children: [
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
                      child: SkinnedText(
                        "heroitem_${item.id}_description".l(),
                        style: TStyles.small.copyWith(height: 1),
                        hideStroke: true,
                      ),
                    ),
                    Row(children: [
                      _itemAttributeBuilder(item, HeroAttribute.blessing),
                      _itemAttributeBuilder(item, HeroAttribute.power),
                      _itemAttributeBuilder(item, HeroAttribute.wisdom),
                    ])
                  ]),
            )),
            SizedBox(width: 12.d),
            Widgets.rect(
              alignment: Alignment.center,
              width: 200.d,
              child: IgnorePointer(
                child: _itemActionBuilder(item, haveItem, host),
              ),
            ),
          ],
        ),
        onPressed: () => _setItem(item, position, heroItem, host));
  }

  Widget _itemAttributeBuilder(BaseHeroItem item, HeroAttribute attribute) {
    return Row(children: [
      Asset.load<Image>("benefit_${attribute.benefit}", width: 56.d),
      SkinnedText(" +${item.attributes[attribute]}   ", hideStroke: true),
    ]);
  }

  _itemActionBuilder(BaseHeroItem item, bool isAvailable, HeroCard? host) {
    if (isAvailable) {
      if (host != null) {
        return _lockItem("icon_used", "${host.card.fruit.name}_title".l());
      }
      return SkinnedButton(
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
    return SkinnedButton(
      height: 120.d,
      icon: "icon_nectar",
      label: "${item.cost}",
      color: ButtonColor.teal,
      padding: EdgeInsets.only(right: 16.d, bottom: 16.d),
    );
  }

  Widget _lockItem(String icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Asset.load<Image>(icon, height: 60.d),
        SizedBox(height: 12.d),
        Widgets.rect(
          padding: EdgeInsets.symmetric(horizontal: 8.d),
          radius: 12.d,
          color: TColors.primary10,
          child: SkinnedText(
            text,
            style: TStyles.smallInvert,
            hideStroke: true,
          ),
        ),
      ],
    );
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
      toast("heroitem_used".l(["${host.card.fruit.name}_title".l()]));
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
      _account.heroItems[id] = HeroItem(id, item, 0);
      onBuy.value = true;
    } finally {}
  }

  _tryRPC(RpcId id, Map<String, dynamic> params) async {
    try {
      var data =
          await rpc(id, params: params, showError: isTutorial ? false : true);
      if (!mounted) return;
      accountProvider.update(context, data);
      setState(() {});
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
