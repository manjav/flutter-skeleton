import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruitcraft/mixins/notif_mixin.dart';
import 'package:fruitcraft/services/event_notification.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key})
      : super(
          Routes.home,
        );

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<HomeScreen>
    with BackgroundMixin, KeyProvider, NotifMixin {
  late PageController _pageController;
  int _selectedTabIndex = 2, punchIndex = -1;
  final List<SMITrigger?> _punchInputs = List.generate(5, (index) => null);
  final List<SMIBool?> _selectionInputs = List.generate(5, (index) => null);
  SMINumber? _tribeLevelInput;

  var controller = Get.put(LoadingController());

  @override
  void initState() {
    _pageController = PageController(initialPage: _selectedTabIndex);
    super.initState();
  }

  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.addListener(() {
      var state = services.state;
      if (state.status == ServiceStatus.initialize) {
        if (accountProvider.account.dailyReward.containsKey("day_index")) {
          serviceLocator<RouteService>().to(Routes.popupDailyGift);
        }
        serviceLocator<NoobSocket>().onReceive.add(_onNoobReceive);
        setState(() {});
      }
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
                serviceLocator<RouteService>().to(Routes.popupProfile)),
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
                  serviceLocator<RouteService>().to(Routes.popupSettings))),
      ];
    }
    return super.appBarElementsRight();
  }

  @override
  Widget appBarFactory(double paddingTop) {
    if (services.state.status.index < ServiceStatus.initialize.index) {
      return const SizedBox();
    }
    return super.appBarFactory(paddingTop);
  }

  @override
  Widget contentFactory() {
    if (services.state.status.index < ServiceStatus.initialize.index) {
      return const SizedBox();
    }
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

  void _onNoobReceive(NoobMessage message) async {
    var account = accountProvider.account;
    var sound = serviceLocator<Sounds>();
    var notifService = serviceLocator<EventNotification>();

    if (message.type == Noobs.playerStatus) {
      var status = message as NoobStatusMessage;
      if (status.playerId == account.id) {
        return;
      }
      if (account.tribe != null && account.tribe!.members.value.isEmpty) {
        await account.tribe!.loadMembers(context, account);
      }
      var player = account.tribe?.members.value
          .firstWhereOrNull((item) => item.id == status.playerId);
      if (player == null) {
        return;
      }
      if (status.status != 1) {
        return;
      }
      // ignore: use_build_context_synchronously
      notifService.addStatus("event_online".l([player.name]), context);
      return;
    }

    if (message.type == Noobs.help &&
        serviceLocator<RouteService>().currentRoute == Routes.home) {
      var help = message as NoobHelpMessage;
      if (help.ownerTribeId == account.tribeId) {
        sound.play("help");
        notifService.showNotif(
            NotifData(
              message: message,
              title: help.defenderName,
              caption: "tribe_help".l([help.defenderName, help.attackerName]),
              mode: 1,
              onTap: () {
                onAcceptHelp(message, account);
                notifService.hideNotif(message);
              },
            ),
            context);
      }
      return;
    }

    if (message.type == Noobs.battleRequest) {
      sound.play("attack");
      var request = message as NoobRequestBattleMessage;
      notifService.showNotif(
          NotifData(
            message: message,
            title: request.attackerName,
            caption: "battle_request".l([request.attackerName]),
            mode: 0,
            onTap: () {
              onAcceptAttack(message, account);
              notifService.hideNotif(message);
            },
          ),
          context);
      return;
    }

    if (message.type == Noobs.auctionBid) {
      var bid = message as NoobAuctionMessage;
      if (bid.card.ownerIsMe && bid.card.loserIsMe) {
        var text = bid.card.ownerIsMe ? "auction_bid_sell" : "auction_bid_deal";
        accountProvider.update(context, {"gold": bid.card.lastBidderGold});
        notifService.showNotif(
            NotifData(
              message: message,
              title: bid.card.maxBidderName,
              caption: text.l([bid.card.maxBidderName]),
              mode: 1,
              onTap: () {
                _selectTap(4);
                notifService.hideNotif(message);
              },
            ),
            context);
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

  @override
  void dispose() {
    serviceLocator<NoobSocket>().onReceive.remove(_onNoobReceive);
    super.dispose();
  }
}
