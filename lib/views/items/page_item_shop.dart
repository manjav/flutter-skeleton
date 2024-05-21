import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../app_export.dart';

class ShopPageItem extends AbstractPageItem {
  final ShopSections? shopSections;
  const ShopPageItem({this.shopSections, super.key})
      : super(Routes.pageItemShop);

  @override
  createState() => _ShopPageItemState();
}

class _ShopPageItemState extends AbstractPageItemState<ShopPageItem> {
  late Account _account;
  final Map<ShopSections, List<ShopItemVM>> _items = {};
  // late StreamSubscription<List<PurchaseDetails>> _subscription;
  final Map<String, SkuDetails> _productDetails = {};
  final RxBool _reloadBoosPacks = false.obs;
  final ValueNotifier<bool> _reloadCardPacks = ValueNotifier(false);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _account = accountProvider.account;
    _fetchData();
    super.initState();
  }

  @override
  void onTutorialFinish(data) {
    if (data["id"] == 23) {
      var item = _items[ShopSections.card]
          ?.firstWhereOrNull((element) => element.base.id == 2);
      if (item != null) _onItemPressed(item);
    }
    super.onTutorialFinish(data);
  }

  @override
  bool get wantKeepAlive => false;

  _fetchData() async {
    Set<String> skus = {};
    try {
      var result = await rpc(RpcId.getShopitems);
      for (var entry in _account.loadingData.shopItems.entries) {
        var section = entry.key;
        var items = entry.value;
        _items[section] = [];
        for (var i = 0; i < items.length; i++) {
          var item = items[i];
          if (section == ShopSections.gold &&
              !result.containsKey(item.id.toString())) continue;
          var price = 0;
          if (item.inStore) {
            var storeId = FlavorConfig.instance.variables["storeId"];
            price =
                int.parse(result[item.id.toString()]["price"][storeId] ?? 0);
          }
          _items[section]!.add(ShopItemVM(
            item,
            price,
            8,
            section == ShopSections.nectar ? 11 : 12,
          ));

          if (section.inStore) {
            skus.add("${section.name}_${item.id}");
          }
        }
        var len = _items[section]!.length;
        if (len % 3 == 2) {
          for (var i = 0; i < len; i++) {
            if (i > len - 3) {
              _items[section]![i].mainCells = 10;
            }
          }
          _items[section]!.insert(
              len - 2, ShopItemVM(ShopItem(ShopSections.none, {}), 0, 2, 10));
        }
        _account.loadingData.shopProceedItems = _items;
      }
      var inAppPurchaseService = serviceLocator<Payment>();

      final bool available = inAppPurchaseService.isAvailable;
      if (available) {
        var response = await inAppPurchaseService.queryInventory(
            skus: skus.toList(), querySkuDetails: true);
        var inventory = response[inAppPurchaseService.INVENTORY] as Inventory;
        var products = inventory.mSkuMap.values.toList();
        for (var product in products) {
          _productDetails[product.mSku!] = product;
        }
      }
    } finally {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && widget.shopSections != null) {
          Scrollable.ensureVisible(
            GlobalObjectKey(widget.shopSections!.index).currentContext!,
            alignment: 0.1,
          );
        }
      });
    }
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (var details in purchaseDetailsList) {
      if (details.status != PurchaseStatus.pending) {
        if (details.status == PurchaseStatus.error ||
            details.status == PurchaseStatus.canceled) {
          Overlays.remove(OverlaysName.waiting);
          Overlays.insert(
            context,
            WaitingOverlay(details.error!.message.l()),
          );
        } else if (details.status == PurchaseStatus.purchased ||
            details.status == PurchaseStatus.restored) {
          Overlays.remove(OverlaysName.waiting);
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

        await rpc(RpcId.buyGoldPack, params: params);
        var account = serviceLocator<AccountProvider>();
        if (mounted) {
          account.update(context, {section.name: item.base.value});

          Overlays.insert(
            context,
            PurchaseFeastOverlay(
              args: {"item": item},
            ),
          );
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_items.isEmpty) {
      return Center(child: SkinnedText("waiting_l".l()));
    }
    return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, 160.d, 0, 220.d),
        controller: _scrollController,
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
        key: GlobalObjectKey(section.index),
        clipBehavior: Clip.none,
        decoration: Widgets.imageDecorator("shop_header_${section.name}",
            ImageCenterSliceData(415, 188, const Rect.fromLTWH(42, 58, 2, 2))),
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
                        decoration: Widgets.imageDecorator("icon_star"),
                        child: Center(
                          child: SkinnedText(
                              "x${ShopData.getMultiplier(_account.level).round()}"),
                        ))
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
    return StaggeredGrid.count(
      crossAxisCount: 24,
      children: [
        for (var i = 0; i < items.length; i++)
          StaggeredGridTile.count(
              crossAxisCellCount: items[i].mainCells,
              mainAxisCellCount: items[i].crossCells,
              child: switch (items[i].base.section) {
                ShopSections.gold => _itemGoldBuilder(i, items[i]),
                ShopSections.nectar => _itemNectarBuilder(i, items[i]),
                ShopSections.card => ValueListenableBuilder(
                    valueListenable: _reloadCardPacks,
                    builder: (context, value, child) =>
                        _itemCardBuilder(i, items[i]),
                  ),
                ShopSections.boost => StreamBuilder<bool>(
                    stream: _reloadBoosPacks.stream,
                    builder: (context, snapshot) {
                      return _itemBoostBuilder(i, items[i]);
                    }),
                _ => const SizedBox(),
              })
      ],
    );
  }

  Widget _itemGoldBuilder(int index, ShopItemVM item) {
    var title = item.getTitle();
    return _baseItemBuilder(
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
                    (item.base.value * ShopData.getMultiplier(_account.level))
                        .round()
                        .compact(),
                    style: TStyles.large.copyWith(color: TColors.orange))
              ])),
          _percentageBadge(item.base.ratio),
          _rewardBadge(item.base.reward),
        ]));
  }

  Widget _itemNectarBuilder(int index, ShopItemVM item) {
    var title = item.getTitle();
    return _baseItemBuilder(
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
    var title = item.getTitle();
    return _baseItemBuilder(index, title, title, item,
        LoaderWidget(AssetType.image, title, subFolder: 'shop'));
  }

  Widget _itemBoostBuilder(int index, ShopItemVM item) {
    var title = item.base.id < 22 ? "shop_boost_xp" : "shop_boost_power";
    return _baseItemBuilder(
        index,
        title,
        title,
        item,
        Stack(alignment: const Alignment(0, 0.44), children: [
          LoaderWidget(AssetType.image, title, subFolder: 'shop'),
          SkinnedText("${((item.base.ratio - 1) * 100).round()}%"),
        ]));
  }

  Widget _baseItemBuilder(int index, String title, String description,
      ShopItemVM item, Widget child) {
    return Widgets.button(context,
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
              child: SkinnedButton(
                  color: ButtonColor.green,
                  padding: EdgeInsets.only(bottom: 10.d),
                  icon: item.inStore ? null : "icon_${item.base.currency}",
                  label:
                      ShopData.calculatePrice(_account, _productDetails, item),
                  height: 120.d))
        ]),
        onPressed: () => _onItemPressed(item));
  }

  Widget _percentageBadge(double ratio) {
    if (ratio == 0) return const SizedBox();
    return Align(
        alignment: const Alignment(0.9, 0.2),
        child: Widgets.rect(
          width: 100.d,
          height: 100.d,
          transform: Matrix4.rotationZ(-0.15),
          decoration: Widgets.imageDecorator("badge_ribbon"),
          child: Center(
              child: SkinnedText("+${(ratio * 100).round()}%",
                  style: TStyles.tiny)),
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

  _onItemPressed(ShopItemVM item) async {
    if (item.inStore) {
      // if (kDebugMode) {
      //   _deliverProduct(
      //       item.base.section,
      //       PurchaseDetails(
      //           purchaseID: "",
      //           productID: item.base.productID,
      //           status: PurchaseStatus.purchased,
      //           verificationData: PurchaseVerificationData(
      //               localVerificationData: '{"purchaseState":0}',
      //               serverVerificationData: "{}",
      //               source: ""),
      //           transactionDate: ""));
      // } else {
      // InAppPurchase.instance.buyConsumable(
      //     purchaseParam: PurchaseParam(
      //         productDetails: _productDetails[item.base.productID]!));
      // }
      var payment = serviceLocator<Payment>();

      var res = await payment.launchPurchaseFlow(sku: item.base.productID);

      IabResult? purchaseResult = res[payment.RESULT];
      Purchase? purchase = res[payment.PURCHASE];

      if (true == purchaseResult?.isFailure()) {
        return;
      }

      _purchaseUpdated(purchase!, item);
      return;
      // }
    }

    //check for enught gold or nectar to buy
    var count = accountProvider.account
        .getValue(Values.values.byName(item.base.currency));
    var price = ShopData.getPrice(accountProvider.account, item);
    if (count < price) {
      toast("not_enough_${item.base.currency}".l());
      return;
    }

    if (item.base.section == ShopSections.boost) {
      Overlays.insert(
          context,
          PurchaseFeastOverlay(
            args: {"item": item},
            onClose: (data) {
              if (data == null || data is! Map<String, dynamic>) return;
              for (var row in data.entries) {
                var x = _account.loadingData.shopItems[item.base.section]!
                    .firstWhereOrNull(
                        (element) => element.id == int.parse(row.key));
                x?.value = row.value;
              }
              _reloadBoosPacks.value = !_reloadBoosPacks.value;
            },
          ));
    } else {
      Overlays.insert(
        context,
        OpenPackFeastOverlay(
          args: {"pack": item.base},
          onClose: (d) async {
            _reloadCardPacks.value = !_reloadCardPacks.value;
            services.changeState(ServiceStatus.punch, data: 1);
            if (isTutorial) {
              await Future.delayed(300.ms);
              services.changeState(ServiceStatus.changeTab, data: {"index": 2});
            }
          },
        ),
      );
    }
  }

  void _purchaseUpdated(Purchase purchaseDetail, ShopItemVM item) async {
    Overlays.remove(OverlaysName.waiting);
    if (purchaseDetail.mSku.startsWith("gold_")) {
      _deliver(ShopSections.gold, purchaseDetail, item);
    } else {
      _deliver(ShopSections.nectar, purchaseDetail, item);
    }
  }

  _deliver(ShopSections section, Purchase details, ShopItemVM item) async {
    var account = serviceLocator<AccountProvider>();
    // -- StoreID_AppStore = "1"
    // -- StoreID_Sibche = "2"
    // -- StoreID_GooglePlay = "3"
    // -- StoreID_Bazar = "4"
    // -- StoreID_Cando = "5"
    // -- StoreID_Fourtune = "6"
    // -- StoreID_Samsung = "7"
    // -- StoreID_Myket = "8"
    // -- StoreID_Tod = "9"
    // -- StoreID_IraqApps = "10"
    // -- StoreID_charkhone = "11"
    // -- StoreID_parsian = "12"
    // -- StoreID_Zarinpal = "13"
    var params = {
      "type": item.base.id,
      "receipt": details.mToken,
      "signature": details.mSignature,
      "store": FlavorConfig.instance.variables["storeId"]
    };

    await rpc(RpcId.buyGoldPack, params: params);

    await serviceLocator<Payment>().consume(purchase: details);

    if (mounted) {
      account.update(context, {section.name: item.base.value});
      Overlays.insert(
        context,
        PurchaseFeastOverlay(
          args: {"item": item},
        ),
      );
    }
    return;
  }

  @override
  void dispose() {
    // _subscription.cancel();
    super.dispose();
  }
}
