import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/core/account.dart';
import '../../data/core/adam.dart';
import '../../data/core/infra.dart';
import '../../data/core/rpc.dart';
import '../../mixins/background_mixin.dart';
import '../../mixins/key_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/services_provider.dart';
import '../../services/connection/noob_socket.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../utils/assets.dart';
import '../../view/items/page_item_auction.dart';
import '../../view/items/page_item_tribe.dart';
import '../../view/widgets/tab_navigator.dart';
import '../items/page_item_cards.dart';
import '../items/page_item_map.dart';
import '../items/page_item_shop.dart';
import '../overlays/overlay.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/indicator.dart';
import '../widgets/indicator_level.dart';
import 'screen.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home, args: {});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen>
    with BackgroundMixin, KeyProvider {
  final int _tabsCont = 5;
  late PageController _pageController;
  final ValueNotifier<int> _selectedTab = ValueNotifier(2);
  final ValueNotifier<int> _punchIndex = ValueNotifier(-1);

  @override
  void initState() {
    _pageController = PageController(initialPage: _selectedTab.value);
    super.initState();
  }

  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.changeState(ServiceStatus.complete);
    getService<NoobSocket>().onReceive.add(_onNoobReceive);
    if (accountProvider.account.dailyReward.containsKey("day_index")) {
      Routes.popupDailyGift.navigate(context);
    }
    getService<Sounds>().playMusic();
    context.read<ServicesProvider>().addListener(() async {
      var state = services.state;
      if (state.status == ServiceStatus.changeTab) {
        _selectTap(state.data as int);
      } else if (state.status == ServiceStatus.punch) {
        _punchIndex.value = state.data as int;
        Timer(const Duration(seconds: 1), () => _punchIndex.value = -1);
      }
    });
  }

  @override
  List<Widget> appBarElementsLeft() {
    if (_selectedTab.value != 2) return [];
    return [
      SizedBox(
        width: 196.d,
        height: 200.d,
        child: LevelIndicator(
            onPressed: () => Routes.popupProfile.navigate(context)),
      )
    ];
  }

  @override
  List<Widget> appBarElementsRight() {
    if (_selectedTab.value == 3) {
      return [];
    }
    if (_selectedTab.value == 4) {
      return [Indicator(widget.type.name, Values.gold)];
    }
    if (_selectedTab.value == 2) {
      return <Widget>[
        ...super.appBarElementsRight()
          ..add(Widgets.button(context,
              width: 110.d,
              height: 110.d,
              padding: EdgeInsets.all(16.d),
              child: Asset.load<Image>("ui_settings"),
              onPressed: () => Routes.popupSettings.navigate(context))),
      ];
    }
    return super.appBarElementsRight();
  }

  @override
  Widget contentFactory() {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          if (Platform.isAndroid) {
            var result = await Routes.popupMessage.navigate(context, args: {
              "title": "quit_title".l(),
              "message": "quit_message".l(),
              "isConfirm": () {}
            });
            if (result != null) {
              SystemNavigator.pop();
            }
          }
        }
      },
      child: Consumer<AccountProvider>(builder: (_, state, child) {
        return Stack(alignment: Alignment.bottomCenter, children: [
          backgroundBuilder(color: 2, animated: false),
          PageView.builder(
            controller: _pageController,
            itemCount: _tabsCont,
            itemBuilder: _pageItemBuilder,
            onPageChanged: (value) => _selectTap(value, pageChange: false),
          ),
          TabNavigator(
              tabsCount: _tabsCont,
              selectedIndex: _selectedTab,
              punchIndex: _punchIndex,
              onChange: (i) => _selectTap(i, tabsChange: false)),
        ]);
      }),
    );
  }

  Widget? _pageItemBuilder(BuildContext context, int index) {
    var key = getGlobalKey(index);
    return switch (index) {
      0 => ShopPageItem(key: key),
      1 => CardsPageItem(key: key),
      2 => MainMapPageItem(key: key),
      3 => TribePageItem(key: key),
      _ => AuctionPageItem(key: key)
    };
  }

  _selectTap(int index, {bool tabsChange = true, bool pageChange = true}) {
    changeBackgroundColor(index + 1);

    if (tabsChange) {
      setState(() => _selectedTab.value = index);
    }
    if (pageChange) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 700), curve: Curves.ease);
    }
  }

  void _onNoobReceive(NoobMessage message) {
    var account = accountProvider.account;
    if (message.type == Noobs.help &&
        ModalRoute.of(context)!.settings.name == Routes.home.routeName) {
      var help = message as NoobHelpMessage;
      if (help.ownerTribeId == account.tribeId && help.ownerId != account.id) {
        _showConfirmOverlay(
            "tribe_help".l([help.attackerName, help.defenderName]),
            () => _onAcceptHelp(help, account));
      }
      return;
    }
    if (message.type == Noobs.battleRequest) {
      var request = message as NoobRequestBattleMessage;
      _showConfirmOverlay("battle_request".l([request.attackerName]),
          () => _onAcceptAttack(request, account));
      return;
    }
    if (message.type == Noobs.auctionBid) {
      var bid = message as NoobAuctionMessage;
      if (bid.card.ownerIsMe && bid.card.loserIsMe) {
        var text = bid.card.ownerIsMe ? "auction_bid_sell" : "auction_bid_deal";
        accountProvider.update(context, {"gold": bid.card.lastBidderGold});
        _showConfirmOverlay(
            text.l([bid.card.maxBidderName]), () => _selectTap(4));
      }
    } else if (message.type == Noobs.auctionSold) {
      var bid = message as NoobAuctionMessage;
      if (bid.card.loserIsMe) {
        accountProvider.update(context, {"gold": bid.card.lastBidderGold});
      } else if (bid.card.winnerIsMe) {
        accountProvider.update(context, {"card": bid.card.map});
      }
    }
  }

  _onAcceptAttack(NoobRequestBattleMessage request, Account account) async {
    try {
      var result = await rpc(RpcId.battleDefense,
          params: {"battle_id": request.id, "choice": 1});
      _joinBattle(
          request.id,
          account,
          Opponent.create(request.attackerId, request.attackerName, account.id),
          result["help_cost"],
          result["created_at"]);
    } finally {}
  }

  _onAcceptHelp(NoobHelpMessage help, Account account) async {
    var attacker =
        Opponent.create(help.attackerId, help.attackerName, account.id);
    var defender =
        Opponent.create(help.defenderId, help.defenderName, account.id);
    getFriend() => help.isAttacker ? attacker : defender;
    getOpposite() => help.isAttacker ? defender : attacker;
    var result = await rpc(RpcId.battleJoin,
        params: {"battle_id": help.id, "mainEnemy": getOpposite().id});
    if (!mounted) return;
    _joinBattle(help.id, getFriend(), getOpposite(), 0, result["created_at"]);
    _addBattleCard(account, result, help.attackerId, "attacker_cards_set");
    _addBattleCard(account, result, help.defenderId, "defender_cards_set");
  }

  @override
  void dispose() {
    getService<NoobSocket>().onReceive.remove(_onNoobReceive);
    super.dispose();
  }

  _addBattleCard(Account account, result, int attackerId, String side) async {
    await Future.delayed(const Duration(milliseconds: 10));
    for (var element in result[side]) {
      element["owner_team_id"] = attackerId;
      var message = NoobCardMessage(account, element);
      getService<NoobSocket>().dispatchMessage(message);
    }
  }

  void _showConfirmOverlay(String message, Function() onAccept) {
    Overlays.insert(context, OverlayType.confirm, args: {
      "barrierDismissible": false,
      "message": message,
      "onAccept": onAccept
    });
    Timer(const Duration(seconds: 10),
        () => Overlays.remove(OverlayType.confirm));
  }

  void _joinBattle(int id, Opponent friendsHead, Opponent oppositesHead,
      [int helpCost = -1, int createAt = 0]) {
    var args = {
      "battle_id": id,
      "friendsHead": friendsHead,
      "oppositesHead": oppositesHead
    };
    if (helpCost > -1) {
      args["help_cost"] = helpCost;
    }
    if (createAt > 0) {
      args["created_at"] = createAt;
    }
    Routes.livebattle.navigate(context, args: args);
  }
}
