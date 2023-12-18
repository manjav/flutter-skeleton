import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../data/core/fruit.dart';
import '../../data/core/infra.dart';
import '../../mixins/key_provider.dart';
import '../../mixins/reward_mixin.dart';
import '../../services/connection/noob_socket.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
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
import '../widgets/loaderwidget.dart';
import '../widgets/skinnedtext.dart';
import 'iscreen.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home, args: {});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen>
    with RewardScreenMixin, KeyProvider {
  int _selectedTab = 2;
  final double _navbarHeight = 210.d;
  final _tabInputs = List<SMIBool?>.generate(5, (index) => null);
  late PageController _pageController;

  @override
  void initState() {
    waitingSFX = "";
    _pageController = PageController(initialPage: _selectedTab);
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
    if (_selectedTab != 2) return [];
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
    if (_selectedTab == 3) {
      return [];
    }
    if (_selectedTab == 4) {
      return [Indicator(widget.type.name, Values.gold)];
    }
    if (_selectedTab == 2) {
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
    var tabSize = DeviceInfo.size.width / _tabInputs.length;
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          backgrounBuilder(color: 2, animated: false),
          PageView.builder(
            controller: _pageController,
            itemCount: _tabInputs.length,
            itemBuilder: _pageItemBuilder,
            onPageChanged: (value) => _selectTap(value, pageChange: false),
          ),
          SizedBox(
              height: _navbarHeight,
              child: ListView.builder(
                  itemExtent: tabSize,
                  itemBuilder: (c, i) =>
                      _tabItemBuilder(state.account, i, tabSize),
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabInputs.length)),
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

  Widget? _tabItemBuilder(Account account, int index, double size) {
    return Widgets.touchable(
        onTap: () => _selectTap(index, tabsChange: false),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
                top: index == 3 ? 10.d : 0,
                width: size * (index == 3 ? 0.6 : 1),
                height: size * (index == 3 ? 0.6 : 1),
                child: LoaderWidget(
                  AssetType.animation,
                  "tab_$index",
                  fit: BoxFit.fitWidth,
                  riveAssetLoader: _onTabAssetLoad,
                  onRiveInit: (Artboard artboard) {
                    final controller =
                        StateMachineController.fromArtboard(artboard, "Tab");
                    _tabInputs[index] =
                        controller!.findInput<bool>("active") as SMIBool;
                    _tabInputs[index]!.value =
                        index == _pageController.initialPage;
                    if (index == 3) {
                      var input =
                          controller.findInput<double>("level") as SMINumber;
                      input.value = account.tribe != null
                          ? account.tribe!.levels[Buildings.base.id]!.toDouble()
                          : 0.0;
                    }
                    artboard.addController(controller);
                  },
                )),
            _selectedTab == index
                ? Positioned(
                    bottom: 6.d,
                    child: SkinnedText("home_tab_$index".l().toPascalCase(),
                        style: TStyles.small))
                : const SizedBox()
          ],
        ));
  }

  _selectTap(int index, {bool tabsChange = true, bool pageChange = true}) {
    changeBackgroundColor(index + 1);

    if (tabsChange) {
      for (var i = 0; i < _tabInputs.length; i++) {
        _tabInputs[i]!.value = i == index;
      }
      setState(() => _selectedTab = index);
    }
    if (pageChange) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 700), curve: Curves.ease);
    }
  }

  void _onNoobReceive(NoobMessage message) {
    if (message.type == Noobs.help) {
      if (ModalRoute.of(context)!.settings.name != Routes.home.routeName) {
        return;
      }
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

  Future<bool> _onTabAssetLoad(FileAsset asset, Uint8List? list) async {
    if (asset is ImageAsset && asset.name == "background") {
      var bytes = await rootBundle.load('assets/images/tab_background.webp');
      asset.image = await ImageAsset.parseBytes(bytes.buffer.asUint8List());
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    getService<NoobSocket>().onReceive.remove(_onNoobReceive);
    super.dispose();
  }
}
