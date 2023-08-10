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

  int _getBoostPackPrice(int price) {
    return price;
  }

  _onItemPressed(ShopItem item) async {
  }
}
