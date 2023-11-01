import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../data/core/account.dart';
import '../../data/core/rpc.dart';
import '../../data/core/store.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets/loaderwidget.dart';
import '../../view/widgets/skinnedtext.dart';
import '../overlays/ioverlay.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'page_item.dart';

class ShopPageItem extends AbstractPageItem {
  const ShopPageItem({super.key}) : super("cards");
  @override
  createState() => _ShopPageItemState();
}

class _ShopPageItemState extends AbstractPageItemState<AbstractPageItem> {
  late Account _account;
  final Map<ShopSections, List<ShopItemVM>> _items = {};
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final bool _hackMode = false;

  final Map<String, ProductDetails> _productDetails = {};

  @override
  void initState() {
    _account = accountBloc.account!;
    _fetchData();
    super.initState();
  }

  _fetchData() async {
    // if (_account.loadingData.shopProceedItems != null) {
    //   _items = _account.loadingData.shopProceedItems!;
    //   setState(() {});
    //   return;
    // }
    Set<String> skus = {};
    try {
      var result = await rpc(RpcId.getShopitems);
      for (var entry in _account.loadingData.shopItems.entries) {
        var section = entry.key;
        var items = entry.value;
        _items[section] = [];
        for (var i = 0; i < items.length; i++) {
          if (section == ShopSections.gold &&
              !result.containsKey(items[i].id.toString())) continue;
          _items[section]!.add(ShopItemVM(
            items[i],
            0,
            i > _items.length - 2 && section == ShopSections.nectar ? 10 : 8,
            section == ShopSections.nectar ? 11 : 12,
          ));

          if (section.inStore) {
            skus.add("${section.name}_${items[i].id}");
          }
        }
        if (section == ShopSections.nectar) {
          _items[section]!
              .add(ShopItemVM(ShopItem(ShopSections.none, {}), 0, 2, 10));
        }
        if (section.inStore) {
          _items[section]!.reverseRange(0, _items[section]!.length);
        }
        _account.loadingData.shopProceedItems = _items;
      }
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          InAppPurchase.instance.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () => _subscription.cancel());
      final bool available = await InAppPurchase.instance.isAvailable();
      if (available) {
        var response = await InAppPurchase.instance.queryProductDetails(skus);
        for (var details in response.productDetails) {
          _productDetails[details.id] = details;
        }
      }
      setState(() {});
    } finally {}
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (var details in purchaseDetailsList) {
      if (details.status != PurchaseStatus.pending) {
        if (details.status == PurchaseStatus.error ||
            details.status == PurchaseStatus.canceled) {
          Overlays.remove(OverlayType.waiting);
          Overlays.insert(context, OverlayType.waiting,
              args: details.error!.message.l());
        } else if (details.status == PurchaseStatus.purchased ||
            details.status == PurchaseStatus.restored) {
          Overlays.remove(OverlayType.waiting);
          if (details.productID.startsWith("gold_")) {
            _deliverProduct(ShopSections.gold, details);
          } else {
            _deliverProduct(ShopSections.nectar, details);
          }
        }
        if (details.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(details);
        }
      }
    }
  }

  _deliverProduct(ShopSections section, PurchaseDetails details) async {
    for (var item in _items[section]!) {
      if (item.base.productID == details.productID) {
        var data = jsonDecode(details.verificationData.localVerificationData);
        if (details.status != PurchaseStatus.purchased ||
            data["purchaseState"] != 0) {
          return;
        }
        var params = {
          "type": item.base.id,
          "receipt": data["purchaseToken"],
          "token": details.purchaseID,
          "store": "2"
        };

        var result = await rpc(RpcId.buyGoldPack, params: params);
        // accountBloc.account!.update({section.name: item.base.value});
        // accountBloc.add(SetAccount(account: accountBloc.account!));
        return;
      }
    }
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
            ImageCenterSliceData(415, 188, const Rect.fromLTWH(42, 57, 2, 2))),
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
    var items = _items[section]!;
    return StaggeredGrid.count(crossAxisCount: 24, children: [
      for (var i = 0; i < items.length; i++)
        StaggeredGridTile.count(
            crossAxisCellCount: items[i].mainCells,
            mainAxisCellCount: items[i].crossCells,
            child: switch (items[i].base.section) {
              ShopSections.gold => _itemGoldBuilder(i, items[i]),
              ShopSections.nectar => _itemNectarBuilder(i, items[i]),
              ShopSections.card => _itemCardBuilder(i, items[i]),
              ShopSections.boost => _itemBoostBuilder(i, items[i]),
              _ => const SizedBox(),
            })
    ]);
  }

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
                  icon: item.inStore ? null : "icon_${item.base.currency}",
                  label: _getItemPrice(item),
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
    return switch (_account.level) {
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
      < 300 =>
        30.0 + (((_account.level - 90) / 10).floor() * goldMultiplier).floor(),
      _ => 93.0 +
          (((_account.level - 300) / veteranGoldDivider).floor() *
                  veteranGoldMultiplier)
              .floor(),
    };
  }

  String _getItemPrice(ShopItemVM item) {
    var price = item.base.value;
    if (item.inStore && _productDetails.containsKey(item.base.productID)) {
      return _productDetails[item.base.productID]!.price;
    }
    if (item.base.section == ShopSections.boost) {
      // Converts gold multiplier to nectar for boost packs
      var boostNectarMultiplier = _getShopMultiplier() / _account.nectarPrice;
      return switch (price) {
        10 => (30000 * boostNectarMultiplier).round(),
        20 => (90000 * boostNectarMultiplier).round(),
        50 => (300000 * boostNectarMultiplier).round(),
        100 => (1000000 * boostNectarMultiplier).round(),
        _ => price,
      }
          .compact();
    }
    return price.compact();
  }

  _onItemPressed(ShopItem item) async {
    if (item.inStore) {
      InAppPurchase.instance.buyConsumable(
          purchaseParam:
              PurchaseParam(productDetails: _productDetails[item.productID]!));
      return;
    }

    var params = {RpcParams.type.name: item.id};
    try {
      var result = await rpc(RpcId.buyCardPack, params: params);
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

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
