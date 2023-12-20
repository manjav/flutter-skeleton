import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/data/core/account.dart';
import 'package:flutter_skeleton/data/core/adam.dart';
import 'package:flutter_skeleton/data/core/rpc.dart';
import 'package:flutter_skeleton/view/widgets/tab_navigator.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/fruit.dart';
import '../../data/core/infra.dart';
import '../../mixins/key_provider.dart';
import '../../mixins/reward_mixin.dart';
import '../../services/connection/noob_socket.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../utils/assets.dart';
import '../../view/items/page_item_auction.dart';
import '../../view/items/page_item_tribe.dart';
import '../items/page_item_cards.dart';
import '../items/page_item_map.dart';
import '../items/page_item_shop.dart';
import '../overlays/ioverlay.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/indicator.dart';
import '../widgets/indicator_level.dart';
import 'iscreen.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home, args: {});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen>
    with RewardScreenMixin, KeyProvider {
  final int _tabsCont = 5;
  late PageController _pageController;
  final ValueNotifier<int> _selectedTab = ValueNotifier(2);

  @override
  void initState() {
    waitingSFX = "";
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
          backgrounBuilder(color: 2, animated: false),
          PageView.builder(
            controller: _pageController,
            itemCount: _tabsCont,
            itemBuilder: _pageItemBuilder,
            onPageChanged: (value) => _selectTap(value, pageChange: false),
          ),
          TabNavigator(
              tabsCount: _tabsCont,
              selectedIndex: _selectedTab,
              onChange: (i) => _selectTap(i, tabsChange: false)),
          //   BlocConsumer<ServicesBloc, ServicesState>(
          //       builder: (context, state) => const SizedBox(),
          //       listener: (context, state) => _selectTap(state.data as int))
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
    if (message.type == Noobs.help &&
        ModalRoute.of(context)!.settings.name == Routes.home.routeName) {
      var help = message as NoobHelpMessage;
      if (help.ownerTribeId == accountBloc.account!.tribeId) {
      Overlays.insert(context, OverlayType.confirm, args: {
        "message": "tribe_help".l([help.attackerName, help.defenderName]),
          "onAccept": () => _onAcceptHelp(help, accountBloc.account!)
        });
          }
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
    var attacker = Opponent.initialize(
        {"id": help.attackerId, "name": help.attackerName, "level": 1, "xp": 1},
        account.id);
    var defender = Opponent.initialize(
        {"id": help.defenderId, "name": help.defenderName, "level": 1, "xp": 1},
        account.id);
    getFriend() => help.ownerId == help.attackerId ? attacker : defender;
    getOpposite() => help.ownerId == help.attackerId ? defender : attacker;
    var result = await rpc(RpcId.joinBattle,
        params: {"battle_id": help.id, "mainEnemy": getOpposite().id});
    if (!mounted) return;
    result["help_cost"] = 0;
    result["battle_id"] = help.id;
    result["friendsHead"] = getFriend();
    result["oppositesHead"] = getOpposite();
    Navigator.pushNamed(context, Routes.livebattle.routeName,
        arguments: result);
  }

  @override
  void dispose() {
    getService<NoobSocket>().onReceive.remove(_onNoobReceive);
    super.dispose();
  }
}
