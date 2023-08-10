import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services.dart';
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
import '../../view/widgets/skinnedtext.dart';
import '../widgets.dart';

class ShopPageItem extends AbstractPageItem {
  const ShopPageItem({super.key}) : super("cards");
  @override
  createState() => _ShopPageItemState();
}

class _ShopPageItemState extends AbstractPageItemState<AbstractPageItem> {
  late Account _account;
  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, 160.d, 0, 220.d),
        child: Column(
          children: [
            _header("shop_packs".l()),
            _grid(1),
            _header("shop_boosts".l()),
            _grid(3)
          ],
        ));
  }

  _header(String title) {
    return SizedBox(
        height: 140.d, child: SkinnedText(title, style: TStyles.large));
  }

  _grid(int itemType) {
    var items = _account.loadingData.shopItems
        .where((item) => item.type == itemType)
        .toList();
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
              if (itemType == 3) return _itemBoostBuilder(i, items[i]);
              return _itemPackBuilder(i, items[i]);
            }));
  }

  _itemPackBuilder(int index, ShopItem item) {
    var title = "shop_${item.type}_${item.id}";
    return _baseItemBilder(
        index, title, item, Expanded(child: Asset.load<Image>(title)));
  }

  _itemBoostBuilder(int index, ShopItem item) {
    var title = item.id < 22 ? "shop_xp" : "shop_power";
    return _baseItemBilder(
        index,
        title,
        item,
        Expanded(
            child: Stack(alignment: const Alignment(0, 0.44), children: [
          Asset.load<Image>(title),
          SkinnedText("${((item.boost - 1) * 100).round()}%"),
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
          Text("${title}_desc".l(),
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
      var result = await BlocProvider.of<Services>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.buyCardPack, params: params);
      result["achieveCards"] = result['cards'];
      result.remove('cards');
      _account.update(result);
    } finally {}
  }
}
