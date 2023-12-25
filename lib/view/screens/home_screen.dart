import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/adam.dart';
import '../../data/core/fruit.dart';
import '../../data/core/infra.dart';
import '../../data/core/rpc.dart';
import '../../mixins/background_mixin.dart';
import '../../mixins/key_provider.dart';
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
    var bloc = BlocProvider.of<ServicesBloc>(context);
    bloc.add(ServicesEvent(ServicesInitState.complete, null));
    bloc.get<NoobSocket>().onReceive.add(_onNoobReceive);
    if (accountBloc.account!.dailyReward.containsKey("next_reward_at")) {
      Navigator.pushNamed(context, Routes.popupDailyGift.routeName);
    }
    getService<Sounds>().playMusic();
  }

  @override
  List<Widget> appBarElementsLeft() {
    if (_selectedTab.value != 2) return [];
    return [
      SizedBox(
        width: 196.d,
        height: 200.d,
        child: LevelIndicator(
            onPressed: () =>
                Navigator.pushNamed(context, Routes.popupProfile.routeName)),
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
          ..add(Widgets.button(
              width: 110.d,
              height: 110.d,
              padding: EdgeInsets.all(16.d),
              child: Asset.load<Image>("ui_settings"),
              onPressed: () => Navigator.pushNamed(
                  context, Routes.popupSettings.routeName))),
      ];
    }
    return super.appBarElementsRight();
  }

  @override
  Widget contentFactory() {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
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
          BlocConsumer<ServicesBloc, ServicesState>(
              builder: (context, state) => const SizedBox(),
              listener: (context, state) {
                if (state.initState == ServicesInitState.changeTab) {
                  _selectTap(state.data as int);
                } else if (state.initState == ServicesInitState.punch) {
                  _punchIndex.value = state.data as int;
                  Timer(
                      const Duration(seconds: 1), () => _punchIndex.value = -1);
                }
              })
        ],
      );
    });
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
    var account = accountBloc.account!;
    if (message.type == Noobs.help &&
        ModalRoute.of(context)!.settings.name == Routes.home.routeName) {
      var help = message as NoobHelpMessage;
      if (help.ownerTribeId == account.tribeId && help.ownerId != account.id) {
        Overlays.insert(context, OverlayType.confirm, args: {
          "message": "tribe_help".l([help.attackerName, help.defenderName]),
          "onAccept": () => _onAcceptHelp(help, account)
        });
      }
      return;
    }
    if (message.type == Noobs.battleRequest) {
      var request = message as NoobRequestBattleMessage;
      Overlays.insert(context, OverlayType.confirm, args: {
        "message": "battle_request".l([request.attackerName]),
        "onAccept": () async {
          try {
            var result = await rpc(RpcId.battleDefense, params: {
              "battle_id": request.id,
              "already_in_game": 0,
              "mainEnemy": request.attackerId
            });
            _joinBattle(
                request.id,
                account,
                Opponent.create(
                    request.attackerId, request.attackerName, account.id));
          } finally {}
        }
      });
      return;
    }
    var bloc = accountBloc;
    if (message.type == Noobs.auctionBid) {
      var bid = message as NoobAuctionMessage;
      var bloc = accountBloc;
      if (bid.card.ownerIsMe && bid.card.loserIsMe) {
        var text = bid.card.ownerIsMe ? "auction_bid_sell" : "auction_bid_deal";
        bloc.account!.gold = bid.card.lastBidderGold;
        bloc.add(SetAccount(account: bloc.account!));
        Overlays.insert(context, OverlayType.confirm, args: {
          "message": text.l([bid.card.maxBidderName]),
          "acceptLabel": "go_l".l(),
          "onAccept": () => _selectTap(4)
        });
      }
    } else if (message.type == Noobs.auctionSold) {
      var bid = message as NoobAuctionMessage;
      if (bid.card.loserIsMe) {
        bloc.account!.gold = bid.card.lastBidderGold;
      } else if (bid.card.winnerIsMe) {
        var card = AccountCard(bloc.account!, bid.card.map);
        card.id = bid.card.cardId;
        bloc.account!.cards[card.id] = card;
      }
      bloc.add(SetAccount(account: bloc.account!));
    }
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
    _joinBattle(help.id, getFriend(), getOpposite(), 0);
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
      var messae = NoobCardMessage(account, element);
      getService<NoobSocket>().dispatchMessage(messae);
    }
  }

  void _joinBattle(int id, Opponent friendsHead, Opponent oppositesHead,
      [int helpCost = -1]) {
    var args = {
      "battle_id": id,
      "friendsHead": friendsHead,
      "oppositesHead": oppositesHead
    };
    if (helpCost > -1) {
      args["helpCost"] = helpCost;
    }
    Navigator.pushNamed(context, Routes.livebattle.routeName, arguments: args);
  }
}
