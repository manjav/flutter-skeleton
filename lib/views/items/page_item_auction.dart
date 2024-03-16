import 'package:flutter/material.dart';

import '../../app_export.dart';

class AuctionPageItem extends AbstractPageItem {
  const AuctionPageItem({super.key}) : super("cards");
  @override
  createState() => _AuctionPageItemState();
}

class _AuctionPageItemState extends AbstractPageItemState<AbstractPageItem>
    with KeyProvider, ServiceFinderWidgetMixin, ClassFinderWidgetMixin {
  List<AuctionCard> _cards = [];
  int _selectedTab = -1;
  final Map<String, int> _tabs = {
    "sells": 0,
    "deals": 0,
    "power": 1,
    "time": 3,
    "fruit": 2,
    "price": 6
  };

  @override
  void initState() {
    _selectTab("power", 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var tabsName = _tabs.keys.toList();
    return Column(
      children: [
        SizedBox(height: 168.d),
        Widgets.rect(
            radius: 32.d,
            width: DeviceInfo.size.width * 0.96,
            height: 156.d,
            color: TColors.black80,
            child: Row(children: [
              for (var i = 0; i < tabsName.length; i++)
                Expanded(
                    flex: i == 1 ? 5 : 4,
                    child: _tabItemRenderer(i, tabsName[i]))
            ])),
        SizedBox(height: 32.d),
        Expanded(
          child: GridView.builder(
            itemCount: _cards.length,
            padding: EdgeInsets.only(bottom: 200.d, right: 15.d, left: 15.d),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.2),
            itemBuilder: (c, i) => AuctionItem(
              card: _cards[i],
              selectedTab: _selectedTab,
              onBid: () => _bid(_cards[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabItemRenderer(int index, String tabName) {
    var isSelected = index == _selectedTab;
    var title = "auction_$tabName";
    return Widgets.button(context,
        radius: 20.d,
        alignment: Alignment.center,
        margin: EdgeInsets.all(8.d),
        padding: EdgeInsets.zero,
        color: isSelected ? TColors.accent : TColors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Asset.load<Image>(title, height: isSelected ? 76.d : 56.d),
            Text(title.l(), style: TStyles.mediumInvert.copyWith(height: 1.2)),
          ],
        ),
        onPressed: () => _selectTab(tabName, index));
  }

  _selectTab(String tabName, int index) async {
    var rpcId = switch (tabName) {
      "sells" => RpcId.auctionSells,
      "deals" => RpcId.auctionDeals,
      _ => RpcId.auctionSearch,
    };
    var params = {};
    if (tabName == "fruit" || tabName == "price") {
      var route = serviceLocator<RouteService>();
      dynamic result = await (tabName == "fruit"
          ? route.to(Routes.popupCardSelectType)
          : route.to(Routes.popupCardSelectCategory));
      if (result == null) return;
      if (tabName == "price") {
        params.addAll(result);
      } else {
        params["base_card_id"] = result;
      }
    }
    if (!mounted) return;
    if (_tabs[tabName]! > 0) params["query_type"] = _tabs[tabName];
    try {
      var data = await rpc(rpcId, params: params);
      _selectedTab = index;
      setState(() {
        _cards =
            AuctionCard.getList(accountProvider.account, data).values.toList();
      });
    } finally {}
  }

  _bid(AuctionCard card) async {
    try {
      var data = await rpc(RpcId.auctionBid, params: {"auction_id": card.id});
      var auction = AuctionCard(accountProvider.account, data["auction"]);
      var index = _cards.indexWhere((c) => c.id == auction.id);
      if (index > -1) {
        setState(() => _cards[index] = auction);
      }
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        accountProvider.update(context, data);
      }
      toast("auction_added".l());
    } finally {}
  }

  @override
  bool get wantKeepAlive => false;
}
