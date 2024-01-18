import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home, args: {});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen>
    with BackgroundMixin, KeyProvider {
  late PageController _pageController;
  int _selectedTabIndex = 2, punchIndex = -1;
  final List<SMITrigger?> _punchInputs = List.generate(5, (index) => null);
  final List<SMIBool?> _selectionInputs = List.generate(5, (index) => null);
  SMINumber? _tribeLevelInput;

  @override
  void initState() {
    _pageController = PageController(initialPage: _selectedTabIndex);
    super.initState();
  }

  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.changeState(ServiceStatus.complete);
    getService<NoobSocket>().onReceive.add(_onNoobReceive);
    if (accountProvider.account.dailyReward.containsKey("day_index")) {
      services.get<RouteService>().to(Routes.popupDailyGift);
    }
    getService<Sounds>().playMusic();
    context.read<ServicesProvider>().addListener(() async {
      var state = services.state;
      if (state.status == ServiceStatus.changeTab) {
        _selectTap(state.data as int);
      } else if (state.status == ServiceStatus.punch) {
        _punchTab(state.data as int);
      }
    });
  }

  @override
  List<Widget> appBarElementsLeft() {
    if (_selectedTabIndex != 2) return [];
    return [
      SizedBox(
        width: 196.d,
        height: 200.d,
        child: LevelIndicator(
            onPressed: () =>
                services.get<RouteService>().to(Routes.popupProfile)),
      )
    ];
  }

  @override
  List<Widget> appBarElementsRight() {
    if (_selectedTabIndex == 3) {
      return [];
    }
    if (_selectedTabIndex == 4) {
      return [Indicator(widget.route, Values.gold)];
    }
    if (_selectedTabIndex == 2) {
      return <Widget>[
        ...super.appBarElementsRight()
          ..add(Widgets.button(context,
              width: 110.d,
              height: 110.d,
              padding: EdgeInsets.all(16.d),
              child: Asset.load<Image>("ui_settings"),
              onPressed: () =>
                  services.get<RouteService>().to(Routes.popupSettings))),
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
            var result = await services
                .get<RouteService>()
                .to(Routes.popupMessage, args: {
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
        _tribeLevelInput?.value = state.account.tribe != null
            ? state.account.tribe!.levels[Buildings.tribe.id]!.toDouble()
            : 0.0;
        return Stack(alignment: Alignment.bottomCenter, children: [
          backgroundBuilder(color: 2, animated: false),
          PageView.builder(
            controller: _pageController,
            itemCount: _selectionInputs.length,
            itemBuilder: _pageItemBuilder,
            onPageChanged: (value) => _selectTap(value, pageChange: false),
          ),
          TabNavigator(
              tabsCount: _selectionInputs.length, itemBuilder: _tabItemBuilder)
        ]);
      }),
    );
  }

  Widget? _tabItemBuilder(int index, double size) {
    var account = accountProvider.account;
    return Widgets.touchable(context,
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
                    _punchInputs[index] =
                        controller!.findInput<bool>("punch") as SMITrigger?;
                    _selectionInputs[index] =
                        controller.findInput<bool>("active") as SMIBool;
                    _selectionInputs[index]!.value = index == _selectedTabIndex;
                    if (index == 3) {
                      _tribeLevelInput =
                          controller.findInput<double>("level") as SMINumber;
                      _tribeLevelInput?.value = account.tribe != null
                          ? account.tribe!.levels[Buildings.tribe.id]!
                              .toDouble()
                          : 0.0;
                    }
                    artboard.addController(controller);
                  },
                )),
            _selectedTabIndex == index
                ? Positioned(
                    bottom: 6.d,
                    child: SkinnedText("home_tab_$index".l().toPascalCase(),
                        style: TStyles.small))
                : const SizedBox()
          ],
        ));
  }

  Future<bool> _onTabAssetLoad(FileAsset asset, Uint8List? list) async {
    if (asset is ImageAsset && asset.name == "background") {
      var bytes = await rootBundle.load('assets/images/tab_background.webp');
      asset.image = await ImageAsset.parseBytes(bytes.buffer.asUint8List());
      return true;
    }
    return false;
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

  void _selectTap(int index, {bool tabsChange = true, bool pageChange = true}) {
    changeBackgroundColor(index + 1);
    for (var i = 0; i < _selectionInputs.length; i++) {
      _selectionInputs[i]?.value = i == index;
    }

    if (tabsChange) {
      setState(() => _selectedTabIndex = index);
    }
    if (pageChange) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 700), curve: Curves.ease);
    }
  }

  void _punchTab(int index) {
    _punchInputs[index]?.value = true;
    Timer(const Duration(seconds: 1), () => _punchInputs[index]?.value = false);
  }

  void _onNoobReceive(NoobMessage message) {
    var account = accountProvider.account;
    if (message.type == Noobs.help &&
        ModalRoute.of(context)!.settings.name == Routes.home) {
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
    Overlays.insert(
        context,
        ConfirmOverlay(
          message,
          "accept_l".l(),
          "decline_l".l(),
          onAccept,
          barrierDismissible: false,
        ));
    Timer(const Duration(seconds: 10),
        () => Overlays.remove(OverlaysName.confirm));
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
    services.get<RouteService>().to(Routes.liveBattle, args: args);
  }
}
