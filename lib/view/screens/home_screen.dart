import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    if (ModalRoute.of(context)!.settings.name == Routes.home.routeName) {
      var help = message as NoobHelpMessage;
      Overlays.insert(context, OverlayType.confirm, args: {
        "message": "tribe_help".l([help.attackerName, help.defenderName]),
        "onAccept": () async {
          var result = await rpc(RpcId.joinBattle,
              params: {"battle_id": help.id, "mainEnemy": help.ownerId});
          if (mounted) {
            result["help_cost"] = 0;
            result["axis"] = Opponent.initialize({
              "id": help.ownerId,
              "name": help.ownerId == help.attackerId
                  ? help.attackerName
                  : help.defenderName
            }, accountBloc.account!.id);
            Navigator.pushNamed(context, Routes.livebattle.routeName,
                arguments: result);
          }
        }
      });
      return;
    }
    if (message.type == Noobs.auctionBid) {
      var bid = message as NoobAuctionMessage;
      var bloc = accountBloc;
      if (bid.card.ownerIsMe && bid.card.loserIsMe) {
        var text =
            bid.card.ownerIsMe ? "auction_bid_sell" : "auction_bid_deals";
        if (bid.card.loserIsMe) {
          bloc.account!.gold = bid.card.lastBidderGold;
          bloc.add(SetAccount(account: bloc.account!));
        }
        Overlays.insert(context, OverlayType.confirm, args: {
          "message": text.l([bid.card.maxBidderName]),
          "acceptLabel": "go_l".l(),
          "onAccept": () => _selectTap(4)
        });
      }
      if (message.type == Noobs.auctionSold) {
        if (bid.card.loserIsMe) {
          bloc.account!.gold = bid.card.lastBidderGold;
        } else if (bid.card.ownerIsMe) {
          var card = AccountCard(bloc.account!, bid.card.map);
          card.id = bid.card.cardId;
          bloc.account!.cards[card.id] = card;
        }
        bloc.add(SetAccount(account: bloc.account!));
      }
    }
  }

  @override
  void dispose() {
    getService<NoobSocket>().onReceive.remove(_onNoobReceive);
    super.dispose();
  }
}
