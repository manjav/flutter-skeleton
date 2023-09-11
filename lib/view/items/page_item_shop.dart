import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/rpc.dart';
import '../../data/core/rpc_data.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/items/page_item.dart';
import '../../view/widgets/loaderwidget.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';

class ShopPageItem extends AbstractPageItem {
  const ShopPageItem({super.key}) : super("cards");
  @override
  createState() => _ShopPageItemState();
}

class _ShopPageItemState extends AbstractPageItemState<AbstractPageItem> {
  late Account _account;
  Map<ShopSections, List<ShopItemVM>> _items = {};
  final bool _hackMode = false;

  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _fetchData();
    super.initState();
  }

  _fetchData() async {
    if (_account.loadingData.shopProceedItems != null) {
      _items = _account.loadingData.shopProceedItems!;
      setState(() {});
      return;
    }
    try {
      var result = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.getShopitems);
      for (var entry in _account.loadingData.shopItems.entries) {
        var section = entry.key;
        _items[section] = [];
        for (var i = 0; i < entry.value.length; i++) {
          if (section == ShopSections.gold &&
              !result.containsKey(entry.value[i].id.toString())) continue;
          _items[section]!.add(ShopItemVM(
            entry.value[i],
            0,
            i > _items.length - 2 && section == ShopSections.nectar ? 10 : 8,
            section == ShopSections.nectar ? 11 : 12,
          ));
        }
        if (section == ShopSections.nectar) {
          _items[section]!
              .add(ShopItemVM(ShopItem(ShopSections.none, {}), 0, 2, 10));
        }
        if (section == ShopSections.gold || section == ShopSections.nectar) {
          _items[section]!.reverseRange(0, _items[section]!.length);
        }
        _account.loadingData.shopProceedItems = _items;
        setState(() {});
      }
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return SkinnedText("waiting_l".l());
    }
    return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, 160.d, 0, 220.d),
        child: Column(
          children: [
            _header(ShopSections.gold),
            _grid(ShopSections.gold),
            _header(ShopSections.nectar),
            _grid(ShopSections.nectar),
            _header(ShopSections.card),
            _grid(ShopSections.card),
            _header(ShopSections.boost),
            _grid(ShopSections.boost)
          ],
        ));
  }

  Widget _header(ShopSections section) {
    return Container(
        clipBehavior: Clip.none,
        decoration: Widgets.imageDecore("shop_header_${section.name}",
            ImageCenterSliceData(415, 188, const Rect.fromLTWH(42, 56, 2, 2))),
        width: 1000.d,
        height: 188.d,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20.d),
            Widgets.rect(
                transform: Matrix4.rotationZ(-0.15),
                width: 170.d,
                height: 170.d,
                child: section == ShopSections.gold
                    ? Widgets.rect(
                        decoration: Widgets.imageDecore("icon_star"),
                        child: SkinnedText("x${_getShopMultiplier().toInt()}"))
                    : null),
            SizedBox(width: 130.d),
            const Expanded(child: SizedBox()),
            Asset.load<Image>("icon_${section.name}", width: 64.d),
            SizedBox(width: 10.d),
            SkinnedText("shop_${section.name}".l(), style: TStyles.large),
            const Expanded(child: SizedBox()),
            SizedBox(
                width: 320.d,
                child: section == ShopSections.gold
                    ? SkinnedText("ˣ${81231.toRemainingTime(complete: true)}")
                    : null),
          ],
        ));
  }

  Widget _grid(ShopSections section) {
    var items = _account.loadingData.shopItems[section]!;
    var crossAxisCount = 3;
    var ratio = 0.65;
    return SizedBox(
        height: (items.length / crossAxisCount).ceil() *
            DeviceInfo.size.width /
            ratio /
            crossAxisCount,
        child: GridView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: ratio, crossAxisCount: crossAxisCount),
            itemBuilder: (c, i) {
              return switch (section) {
                ShopSections.card => _itemCardBuilder(i, items[i]),
                ShopSections.boost => _itemBoostBuilder(i, items[i]),
                _ => const SizedBox()
              };
  Widget _itemGoldBuilder(int index, ShopItemVM item) {
    var title = _getTitle(item.base);
    return _baseItemBilder(
        index,
        title,
        "",
        item,
        Stack(alignment: Alignment.center, children: [
          LoaderWidget(AssetType.image, title, subFolder: 'shop'),
          Align(
              alignment: const Alignment(0, 0.52),
              child: Stack(alignment: Alignment.center, children: [
                SkinnedText(item.base.value.compact(), style: TStyles.medium),
                Asset.load<Image>("text_line", width: 160.d)
              ])),
          Align(
              alignment: const Alignment(0, 1),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Asset.load<Image>("icon_gold", width: 76.d),
                SkinnedText(
                    (item.base.value * _getShopMultiplier()).round().compact(),
                    style: TStyles.large.copyWith(color: TColors.orange))
              ])),
          _percentageBadge(item.base.ratio),
          _rewardBadge(item.base.reward),
        ]));
  }

  Widget _itemNectarBuilder(int index, ShopItemVM item) {
    var title = _getTitle(item.base);
    return _baseItemBilder(
        index,
        title,
        "",
        item,
        Stack(alignment: Alignment.center, children: [
          LoaderWidget(AssetType.image, title, subFolder: 'shop'),
          Align(
              alignment: const Alignment(0, 1),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Asset.load<Image>("icon_nectar", width: 76.d),
                SkinnedText(item.base.value.compact(), style: TStyles.large)
              ])),
          _percentageBadge(item.base.ratio),
          _rewardBadge(item.base.reward),
        ]));
  }

  Widget _itemCardBuilder(int index, ShopItemVM item) {
    var title = _getTitle(item.base);
    return _baseItemBilder(index, title, title, item,
        LoaderWidget(AssetType.image, title, subFolder: 'shop'));
  }

  Widget _itemBoostBuilder(int index, ShopItemVM item) {
    var title = item.base.id < 22 ? "shop_boost_xp" : "shop_boost_power";
    return _baseItemBilder(
        index,
        title,
        title,
        item,
        Stack(alignment: const Alignment(0, 0.44), children: [
          LoaderWidget(AssetType.image, title, subFolder: 'shop'),
          SkinnedText("${((item.base.ratio - 1) * 100).round()}%"),
        ]));
  }

  Widget _baseItemBilder(int index, String title, String description,
      ShopItemVM item, Widget child) {
    return Widgets.button(
        color: TColors.primary90,
        radius: 30.d,
        alignment: Alignment.center,
        margin: EdgeInsets.all(10.d),
        padding: EdgeInsets.fromLTRB(6.d, 12.d, 6.d, 1.d),
        child: Column(children: [
          SkinnedText(title.l([index + 1])),
          Expanded(child: child),
          description.isEmpty
              ? const SizedBox()
              : Text(
                  "${description}_desc"
                      .l([ShopData.boostDeadline.toRemainingTime()]),
              style: TStyles.small.copyWith(height: 0.9),
              textAlign: TextAlign.center),
          SizedBox(height: description.isEmpty ? 0 : 20.d),
          IgnorePointer(
              ignoring: true,
              child: Widgets.skinnedButton(
                  color: ButtonColor.green,
                  padding: EdgeInsets.only(bottom: 10.d),
                  icon: item.base.currency == "real"
                      ? null
                      : "icon_${item.base.currency}",
                  label: _getBoostPackPrice(item.base.value).compact(),
                  height: 120.d))
        ]),
        onPressed: () => _onItemPressed(item.base));
  }

  Widget _percentageBadge(double ratio) {
    if (ratio == 0) return const SizedBox();
    return Align(
        alignment: const Alignment(0.9, 0.2),
        child: Widgets.rect(
          width: 100.d,
          height: 100.d,
          transform: Matrix4.rotationZ(-0.15),
          decoration: Widgets.imageDecore("badge_ribbon"),
          child: SkinnedText("+${(ratio * 100).round()}%", style: TStyles.tiny),
        ));
  }

  Widget _rewardBadge(String reward) {
    if (reward.isEmpty) return const SizedBox();
    return Align(
        alignment: const Alignment(-0.9, -0.95),
        child: Transform.rotate(
            angle: -0.15,
            child: Asset.load<Image>("reward_$reward", width: 76.d)));
  }

  String _getTitle(ShopItem item) => "shop_${item.section.name}_${item.id}";

  double _getShopMultiplier() {
    const goldMultiplier = 3;
    const veteranGoldDivider = 20;
    const veteranGoldMultiplier = 80;
    var level = _account.get<int>(AccountField.level);
    return switch (level) {
      < 10 => 1.0,
      < 20 => 2.5,
      < 30 => 4.5,
      < 40 => 7.0,
      < 50 => 10.0,
      < 60 => 12.5,
      < 70 => 16.0,
      < 80 => 20.0,
      < 90 => 25.0,
      < 100 => 30.0,
      < 300 => 30.0 + (((level - 90) / 10).floor() * goldMultiplier).floor(),
      _ => 93.0 +
          (((level - 300) / veteranGoldDivider).floor() * veteranGoldMultiplier)
              .floor(),
    };
  }

  int _getBoostPackPrice(int price) {
    // Converts gold multiplier to nectar for boost packs
    var boostNectarMultiplier =
        _getShopMultiplier() / _account.get<int>(AccountField.nectar_price);
    if (price == 10) {
      return (30000 * boostNectarMultiplier).round();
    }
    if (price == 20) {
      return (90000 * boostNectarMultiplier).round();
    }
    if (price == 50) {
      return (300000 * boostNectarMultiplier).round();
    }
    if (price == 100) {
      return (1000000 * boostNectarMultiplier).round();
    }
    return price;
  }

  _onItemPressed(ShopItem item) async {
    var params = {RpcParams.type.name: item.id};
    try {
      var result = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.buyCardPack, params: params);
      result["achieveCards"] = result['cards'];
      result.remove('cards');
      _account.update(result);
      if (mounted) {
        if (_hackMode) {
          await Future.delayed(const Duration(milliseconds: 1750));
          if (mounted) _onItemPressed(item);
        } else {
          Navigator.pushNamed(context, Routes.openPack.routeName,
              arguments: result);
        }
      }
    } finally {}
  }
}
