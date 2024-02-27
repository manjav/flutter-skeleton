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
    var secondsOffset = 24 * 3600 - DateTime.now().secondsSinceEpoch;
    var tabsName = _tabs.keys.toList();
    return Column(children: [
      SizedBox(height: 168.d),
      Widgets.rect(
          radius: 32.d,
          width: DeviceInfo.size.width * 0.96,
          height: 156.d,
          color: TColors.black80,
          child: Row(children: [
            for (var i = 0; i < tabsName.length; i++)
              Expanded(
                  flex: i == 1 ? 5 : 4, child: _tabItemRenderer(i, tabsName[i]))
          ])),
      SizedBox(height: 32.d),
      Expanded(
          child: GridView.builder(
              itemCount: _cards.length,
              padding: EdgeInsets.only(bottom: 200.d, right: 15.d, left: 15.d),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 1.2),
              itemBuilder: (c, i) =>
                  _cardItemBuilder(_cards[i], secondsOffset)))
    ]);
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
      _cards =
          AuctionCard.getList(accountProvider.account, data).values.toList();
      setState(() {});
    } finally {}
  }

  Widget _cardItemBuilder(AuctionCard card, int secondsOffset) {
    var account = accountProvider.account;
    var cardSize = 240.d;
    var radius = Radius.circular(36.d);
    var bidable = card.activityStatus > 0 &&
        (card.ownerId != account.id) &&
        card.maxBidderId != account.id;
    var time = card.activityStatus > 0
        ? (card.createdAt + secondsOffset).toRemainingTime()
        : "closed_l".l();
    var imMaxBidder = card.maxBidderId == account.id;
    return Widgets.button(context,
        radius: radius.x,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.all(8.d),
        color: imMaxBidder ? TColors.green40 : TColors.cream15,
        child: Row(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.ltr,
                  children: [
                    Asset.load<Image>("icon_gold", width: 60.d),
                    SizedBox(width: 8.d),
                    SkinnedText(card.maxBid.compact(), style: TStyles.large)
                  ]),
              Widgets.rect(
                  width: cardSize + 16.d,
                  padding: EdgeInsets.all(8.d),
                  child: CardItem(card,
                      size: cardSize,
                      showCooldown: false,
                      key: getGlobalKey(_selectedTab * 10000 + card.id),
                      heroTag: "hero_${_selectedTab}_${card.id}")),
            ],
          ),
          Expanded(
              child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                  top: 0,
                  right: 0,
                  width: 200.d,
                  height: 70.d,
                  child: Widgets.rect(
                      borderRadius: BorderRadius.only(
                          topRight: radius, bottomLeft: radius),
                      color: TColors.black25,
                      child: SkinnedText("ˣ$time"))),
              Positioned(
                left: 0,
                right: 8.d,
                bottom: 12.d,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.d),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkinnedText("auction_owner".l(),
                          style: TStyles.small, textAlign: TextAlign.start),
                      SizedBox(
                        height: 4.d,
                      ),
                      Widgets.rect(
                        height: 50.d,
                        width: cardSize,
                        padding: EdgeInsets.symmetric(horizontal: 15.d),
                        borderRadius: BorderRadius.all(radius),
                        color: TColors.black25,
                        child: Row(
                          children: [
                            SkinnedText(
                              card.maxBidderName,
                              style: TStyles.tiny,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 7.d,
                      ),
                      SkinnedText("auction_bid".l(),
                          style: TStyles.small, textAlign: TextAlign.start),
                      SizedBox(
                        height: 4.d,
                      ),
                      Widgets.rect(
                        height: 50.d,
                        width: cardSize,
                        padding: EdgeInsets.symmetric(horizontal: 15.d),
                        borderRadius: BorderRadius.all(radius),
                        color: TColors.black25,
                        child: Row(
                          children: [
                            SkinnedText(card.maxBidderName, style: TStyles.tiny)
                          ],
                        ),
                      ),
                      SizedBox(height: 17.d),
                      bidable
                          ? _getBidButton(card, account, imMaxBidder)
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          )),
        ]));
  }

  _getBidButton(AuctionCard card, Account account, bool imMaxBidder) {
    if (imMaxBidder) {
      return SkinnedButton(
        padding: EdgeInsets.fromLTRB(21.d, 15.d, 12.d, 32.d),
        color: ButtonColor.teal,
        width: 240.d,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Asset.load<Image>("checkbox_on", width: 53.d),
              SizedBox(width: 12.d),
              SkinnedText(
                "auction_bid_leader".l(),
                style: TStyles.small,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
      );
    }
    return SkinnedButton(
        padding: EdgeInsets.fromLTRB(21.d, 15.d, 12.d, 32.d),
        color: ButtonColor.teal,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkinnedText(
                "Bid".l(),
                style: TStyles.medium,
              ),
              SizedBox(width: 12.d),
              Expanded(
                child: Widgets.rect(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.all(Radius.circular(21.d)),
                  color: TColors.black25,
                  child: SkinnedText("+${card.bidStep.compact()}",
                      style: TStyles.medium),
                ),
              ),
            ]),
        onPressed: () => _bid(card));
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
        accountProvider.update(context, data);
      }
      toast("auction_added".l());
    } finally {}
  }
}
