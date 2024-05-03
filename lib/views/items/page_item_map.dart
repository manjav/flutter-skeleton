import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

class MainMapPageItem extends AbstractPageItem {
  const MainMapPageItem({super.key}) : super(Routes.pageItemMap);

  @override
  createState() => _MainMapItemState();
}

class _MainMapItemState extends AbstractPageItemState<MainMapPageItem> {
  Map<String, dynamic> _buildingPositions = {};

  @override
  initState() {
    services.addListener(() {
      var state = services.state;
      if (state.status == ServiceStatus.changeTab && state.data["index"] == 2) {
        checkTutorial();
      }
    });
    super.initState();
  }

  @override
  void onTutorialStart(data) {
    if (data["id"] == 961) {
      serviceLocator<EventNotification>().showNotif(
          NotifData(
              message: NoobMessage(Noobs.none, {"id": 1}),
              title: "Khoonkhar",
              caption: "Attacked you now!"),
          context,
          isTutorial: true);
    }
    super.onTutorialStart(data);
  }

  @override
  void onTutorialStep(data) {
    if (data["id"] == 961) {
      serviceLocator<EventNotification>().openAllNotif();
    } else if (data["id"] == 962) {
      serviceLocator<EventNotification>().hideAllNotif();
      serviceLocator<EventNotification>().showNotif(
          NotifData(
              message: NoobMessage(Noobs.none, {"id": 1}),
              title: "Khoonkhar",
              mode: 1,
              caption: "Attacked you now!"),
          context,
          isTutorial: true);
    } else if (data["id"] == 963) {
      serviceLocator<EventNotification>().hideAllNotif();
    }
    super.onTutorialStep(data);
  }

  @override
  onTutorialFinish(data) {
    if (data["index"] == 11) {
      services.changeState(ServiceStatus.changeTab, data: {"index": 0});
    } else if (data["index"] == 15 || data["index"] == 45) {
      checkTutorial();
    } else if (data["index"] == 17) {
      var account = accountProvider.account;
      _onBuildingTap(account, account.buildings[Buildings.quest]!);
    } else if (data["index"] == 18 || data["id"] == 7300) {
      services.changeState(ServiceStatus.changeTab, data: {"index": 1});
    } else if (data["id"] == 700) {
      services.changeState(ServiceStatus.changeTab, data: {"index": 4});
    } else if (data["id"] == 800) {
      serviceLocator<RouteService>().to(Routes.popupLeague);
    } else if (data["id"] == 1002) {
      services.changeState(ServiceStatus.changeTab, data: {"index": 0});
    } else if (data["id"] == 1201) {
      services.changeState(ServiceStatus.changeTab, data: {"index": 0});
    } else if (data["id"] == 402) {
      services.changeState(ServiceStatus.changeTab, data: {"index": 1});
    } else if (data["id"] == 302) {
      var account = accountProvider.account;
      _onBuildingTap(account, account.buildings[Buildings.base]!);
    } else if (data["id"] == 1501) {
      Get.toNamed(Routes.popupCombo);
    } else if (data["id"] == 901) {
      var account = accountProvider.account;
      _onBuildingTap(account, account.buildings[Buildings.base]!);
    } else if (data["id"] == 923) {
      checkTutorial();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var paddingTop = MediaQuery.of(context).viewPadding.top;
    if (paddingTop <= 0) {
      paddingTop = 24.d;
    }
    var account = accountProvider.account;
    return Stack(alignment: Alignment.topLeft, children: [
      LoaderWidget(AssetType.animation, "map_home", fit: BoxFit.cover,
          onRiveInit: (Artboard artboard) {
        var controller =
            StateMachineController.fromArtboard(artboard, "State Machine 1");
        controller?.addEventListener((event) => _riveEventsListener(event));
        artboard.addController(controller!);
      }),
      PositionedDirectional(
        top: paddingTop,
        start: 32.d,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 196.d,
              height: 200.d,
              child: LevelIndicator(
                  onPressed: () =>
                      serviceLocator<RouteService>().to(Routes.popupProfile)),
            ),
            Widgets.button(context,
                width: 110.d,
                height: 110.d,
                margin: EdgeInsets.only(top: 10.d, left: 10.d),
                padding: EdgeInsets.all(16.d),
                child: Asset.load<Image>("ui_settings"),
                onPressed: () =>
                    serviceLocator<RouteService>().to(Routes.popupSettings))
          ],
        ),
      ),
      PositionedDirectional(
        bottom: 350.d,
        start: 32.d,
        child: Indicator("home", Values.leagueRank,
            hasPlusIcon: false,
            onTap: () => serviceLocator<RouteService>().to(Routes.popupLeague)),
      ),
      PositionedDirectional(
          bottom: 220.d,
          start: 32.d,
          child: Indicator(
            "home",
            Values.rank,
            hasPlusIcon: false,
            onTap: () => serviceLocator<RouteService>().to(Routes.popupRanking),
          )),
      PositionedDirectional(
          bottom: 195.d,
          end: 32.d,
          child: Widgets.button(
            context,
            child: Asset.load<Image>("icon_notifications", width: 60.d),
            onPressed: () =>
                serviceLocator<RouteService>().to(Routes.popupInbox),
          )),
      account.bundles != null
          ? PositionedDirectional(
              bottom: 210.d,
              end: 150.d,
              height: 150.d,
              child: StreamBuilder<dynamic>(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    var endDate = Convert.toInt(account.bundles[0]["end_date"]);
                    var duration = Duration(
                        seconds: endDate - DateTime.now().secondsSinceEpoch);
                    String time =
                        "${duration.inHours.toString().padLeft(2, "0")}:${(duration.inMinutes % 60).toString().padLeft(2, "0")}:${(duration.inSeconds % 60).toString().padLeft(2, "0")}";
                    return _box(0, time);
                  }),
            )
          : const SizedBox(),
      PositionedDirectional(
        bottom: 210.d,
        end: 150.d,
        height: 150.d,
        child: _box(0, "06:12:06".l()),
      ),
      PositionedDirectional(
          bottom: 210.d,
          end: 330.d,
          height: 150.d,
          child: _box(1, "chance_box".l())),
      PositionedDirectional(
          bottom: 210.d,
          end: 510.d,
          height: 150.d,
          child: _box(2, "gift_reward".l())),
      _building(account, Buildings.defense),
      _building(account, Buildings.offense),
      _building(account, Buildings.base),
      _building(account, Buildings.treasury),
      _building(account, Buildings.mine),
      _building(account, Buildings.lab),
      _building(account, Buildings.quest),
      if (account.deadlines.isNotEmpty)
        for (var i = 0; i < account.deadlines.length; i++)
          Positioned(
              left: -10.d,
              top: 350.d + i * 140.d,
              child: DeadlineIndicator(account.deadlines[i])),
    ]);
  }

  Widget _building(Account account, Buildings type) {
    if (!_buildingPositions.containsKey(type.name)) return const SizedBox();

    var building = account.buildings[type]!;
    if (building.type == Buildings.lab) {
      building.level = account.potion ~/ 10;
    }
    var position = _buildingPositions[type.name]!;
    Widget child =
        type == Buildings.mine ? BuildingBalloon(building) : const SizedBox();
    var center = DeviceInfo.size.center(Offset.zero);
    var size = Size(280.d, 300.d);
    return Positioned(
        left: center.dx + position[0] * DeviceInfo.ratio - size.width * 0.5,
        top: center.dy + position[1] * DeviceInfo.ratio - size.height * 0.5,
        width: size.width,
        height: size.height,
        child: BuildingWidget(building,
            onTap: () => _onBuildingTap(account, building), child: child));
  }

  _onBuildingTap(Account account, Building building) async {
    var type = switch (building.type) {
      Buildings.quest => Routes.quest,
      Buildings.base => Routes.popupOpponents,
      Buildings.mine => Routes.popupMineBuilding,
      Buildings.treasury => Routes.popupTreasuryBuilding,
      Buildings.defense || Buildings.offense => Routes.popupSupportiveBuilding,
      Buildings.lab => Routes.popupPotion,
      _ => "",
    };
    // Offense and defense buildings need tribe membership.
    if (type == Routes.popupSupportiveBuilding &&
        (account.tribe == null || account.tribe!.id <= 0)) {
      toast("error_149".l());
      return;
    }
    // Get availability level from account
    if (!building.getIsAvailable(account)) {
      return;
    }
    if (type == "") {
      return;
    }
    await serviceLocator<RouteService>().to(type, args: {"building": building});
    checkTutorial();
  }

  Widget _box(double type, String title) {
    return Widgets.touchable(
      context,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Widgets.rect(
              color: TColors.primary20,
              width: 165.d,
              borderRadius: BorderRadius.circular(30.d),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TStyles.small.copyWith(color: TColors.white),
                  ),
                ],
              )),
          Positioned(
            bottom: 22.d,
            child: LoaderWidget(AssetType.animation, "icon_gift",
                height: 116.d,
                width: 105.d,
                fit: BoxFit.cover, onRiveInit: (Artboard artboard) {
              var controller = StateMachineController.fromArtboard(
                  artboard, "State Machine 1");
              var icon = controller?.findInput<double>("icon") as SMINumber;
              icon.value = type;
              artboard.addController(controller!);
            }),
          ),
        ],
      ),
      onTap: () => _onBoxTap(type),
    );
  }

  _onBoxTap(double type) async {
    if (type == 0) {
      Overlays.insert(
          context,
          BundleFeastOverlay(
            onClose: (data) {},
          ));
    }
    if (type == 2) {
      var ads = serviceLocator<Ads>();
      ads.changeState.listen((placment) {
        if (placment == null) return;
        if (placment.state != AdState.closed) return;
        if (placment.reward["reward"] != true) return;
        Overlays.insert(
          context,
          const GiftRewardFeastOverlay(),
        );
      });
      ads.show(AdType.rewarded);
    }
  }

  void _riveEventsListener(RiveEvent event) {
    Timer(const Duration(milliseconds: 100), () {
      setState(
          () => _buildingPositions = jsonDecode(event.properties["buildings"]));
    });
  }
}
