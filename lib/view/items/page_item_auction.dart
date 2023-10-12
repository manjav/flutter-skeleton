import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets.dart';
import '../../view/widgets/skinnedtext.dart';
import '../key_provider.dart';
import '../route_provider.dart';
import 'card_item.dart';
import 'page_item.dart';

class AuctionPageItem extends AbstractPageItem {
  const AuctionPageItem({super.key}) : super("cards");
  @override
  createState() => _AuctionPageItemState();
}

class _AuctionPageItemState extends AbstractPageItemState<AbstractPageItem>
    with KeyProvider {
  late Account _account;
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
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _selectMainTab(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var secondsOffset = 24 * 3600 - DateTime.now().secondsSinceEpoch;
    var tabsName = _tabs.keys.toList();
    return Column(children: [
      SizedBox(
          height: 180.d,
          child: Row(children: [
            _mainTabItemRenderer(0, "search"),
            _mainTabItemRenderer(1, "deals"),
            _mainTabItemRenderer(2, "sells"),
          ])),
      _selectedMainTab == 0
          ? Widgets.rect(
              radius: 132.d,
              height: 110.d,
              color: TColors.black80,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < tabsName.length; i++)
                      _tabItemRenderer(i, tabsName[i])
                  ]))
          : const SizedBox(),
      SizedBox(height: 32.d),
      Expanded(
          child: GridView.builder(
              padding: EdgeInsets.only(bottom: 200.d),
              itemCount: _cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 1.52),
              itemBuilder: (c, i) =>
                  _cardItemBuilder(_cards[i], secondsOffset)))
    ]);
  }

  Widget _mainTabItemRenderer(int index, String name) {
    return Widgets.button(
        child: Asset.load<Image>("auction_$name"),
        onPressed: () => _selectMainTab(index));
  }

  _selectMainTab(int index) async {
    if (_selectedMainTab == index) return;
    _selectedMainTab = index;
    if (index == 0) {
      _selectTab(1, "power");
    } else {
      try {
        var data = await BlocProvider.of<ServicesBloc>(context)
            .get<HttpConnection>()
            .tryRpc(
                context, index == 1 ? RpcId.auctionDeals : RpcId.auctionSells);
        _cards = AuctionCard.getList(_account, data).values.toList();
        setState(() {});
      } finally {}
    }
  }

  Widget _tabItemRenderer(int index, String tabName) {
    var isSelected = index == _selectedTab;
    var title = "auction_$tabName".l();
    return Widgets.button(
        radius: 132.d,
        alignment: Alignment.center,
        margin: EdgeInsets.all(12.d),
        padding: EdgeInsets.symmetric(horizontal: 50.d),
        color: isSelected ? TColors.accent : TColors.transparent,
        onPressed: () => _selectTab(tabName, index));
  }

  _selectTab(String tabName, int index) async {
    var rpc = switch (tabName) {
      "sells" => RpcId.auctionSells,
      "deals" => RpcId.auctionDeals,
      _ => RpcId.auctionSearch,
    };
    var params = {};
    if (tabName == "fruit" || tabName == "price") {
      dynamic result = await Navigator.pushNamed(
          context,
          (tabName == "fruit"
                  ? Routes.popupCardSelectType
                  : Routes.popupCardSelectCategory)
              .routeName);
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
      var data = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, rpc, params: params);
      _selectedTab = index;
      _cards = AuctionCard.getList(_account, data).values.toList();
      setState(() {});
    } finally {}
  }

  Widget _cardItemBuilder(AuctionCard card, int secondsOffset) {
    var cardSize = 230.d;
    var radius = Radius.circular(36.d);
    var bidable = card.activityStatus > 0 &&
        (card.ownerId != _account.get(AccountField.id) &&
            card.maxBidderId != _account.get(AccountField.id));
    var time = card.activityStatus > 0
        ? (card.createdAt + secondsOffset).toRemainingTime()
        : "closed_l".l();
    var bidderName = "auction_bid".l();
    if (!bidable) {
      bidderName +=
          "\n${card.maxBidderId == _account.get(AccountField.id) ? "you_l".l() : card.maxBidderName}\n";
    }
    return Widgets.button(
        radius: radius.x,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.all(8.d),
        color: TColors.primary90,
        child: Row(children: [
          Widgets.rect(
              width: cardSize + 16.d,
              padding: EdgeInsets.all(8.d),
              child: CardItem(card,
                  size: cardSize,
                  showCooldown: false,
                  key: getGlobalKey(_selectedMainTab * 10000 + card.id),
                  heroTag: "hero_${_selectedMainTab}_${card.id}")),
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
                      color: TColors.primary70,
                      child: SkinnedText("ˣ$time"))),
              Positioned(
                  left: 0,
                  right: 8.d,
                  bottom: 8.d,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(bidderName, style: TStyles.medium.copyWith(height: 1)),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Asset.load<Image>("icon_gold", width: 60.d),
                      SizedBox(width: 8.d),
                      SkinnedText(card.maxBid.compact(), style: TStyles.large)
                    ]),
                    SizedBox(height: 8.d),
                    bidable
                        ? Widgets.skinnedButton(
                            padding: EdgeInsets.fromLTRB(0, 12.d, 8.d, 32.d),
                            color: ButtonColor.green,
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Asset.load<Image>("icon_gold", width: 60.d),
                              SizedBox(width: 4.d),
                              SkinnedText("+${card.bidStep.compact()}",
                                  style: TStyles.large)
                            ]),
                            onPressed: () => _bid(card))
                        : const SizedBox(),
                  ])),
            ],
          )),
        ]));
  }

  _bid(AuctionCard card) async {
    try {
      var data = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.auctionBid, params: {"auction_id": card.id});
      _account.update(data);
    } finally {}
  }
}
