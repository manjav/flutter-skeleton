import 'dart:async';

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
  final bool _hackMode = true;

  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            SizedBox(width: 30.d),
            Widgets.rect(
                transform: Matrix4.rotationZ(-0.15),
                width: 170.d,
                height: 170.d,
                child: section == ShopSections.gold
                    ? Widgets.rect(
                        // height: 144.d,
                        decoration: Widgets.imageDecore("icon_star"),
                        child: SkinnedText("x${_getShopMultiplier().toInt()}"))
                    : null),
            SizedBox(width: 130.d),
            const Expanded(child: SizedBox()),
            Asset.load<Image>("icon_${section.name}", width: 64.d),
            SizedBox(width: 10.d),
            SkinnedText("shop_${section.name}".l()),
            const Expanded(child: SizedBox()),
            SizedBox(
                width: 330.d,
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
            }));
  }

  Widget _itemCardBuilder(int index, ShopItem item) {
    var title = "shop_${item.section.name}_${item.id}";
    return _baseItemBilder(
        index,
        title,
        item,
        Expanded(
            child: LoaderWidget(AssetType.image, title, subFolder: 'shop')));
  }

  Widget _itemBoostBuilder(int index, ShopItem item) {
    var title = item.id < 22 ? "shop_boost_xp" : "shop_boost_power";
    return _baseItemBilder(
        index,
        title,
        item,
        Expanded(
            child: Stack(alignment: const Alignment(0, 0.44), children: [
          LoaderWidget(AssetType.image, title, subFolder: 'shop'),
          SkinnedText("${((item.ratio - 1) * 100).round()}%"),
        ])));
  }

  Widget _baseItemBilder(int index, String title, ShopItem item, Widget child) {
    return Widgets.button(
        color: TColors.primary90,
        radius: 30.d,
        alignment: Alignment.center,
        margin: EdgeInsets.all(10.d),
        padding: EdgeInsets.fromLTRB(6.d, 12.d, 6.d, 1.d),
        child: Column(children: [
          SkinnedText(title.l([index + 1])),
          child,
          Text("${title}_desc".l([ShopData.boostDeadline.toRemainingTime()]),
              style: TStyles.small.copyWith(height: 0.9),
              textAlign: TextAlign.center),
          SizedBox(height: 21.d),
          IgnorePointer(
              ignoring: true,
              child: Widgets.skinnedButton(
                  color: ButtonColor.green,
                  padding: EdgeInsets.only(bottom: 10.d),
                  icon: "icon_${item.currency}",
                  label: _getBoostPackPrice(item.price).compact(),
                  height: 120.d))
        ]),
        onPressed: () => _onItemPressed(item));
  }

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

  Future<void> _fetchData() async {
    try {
      var result = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.getShopitems);
      print(result);
    } finally {}
  }
}
