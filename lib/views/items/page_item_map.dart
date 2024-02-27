import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

class MainMapPageItem extends AbstractPageItem {
  const MainMapPageItem({super.key}) : super("battle");

  @override
  createState() => _MainMapItemState();
}

class _MainMapItemState extends AbstractPageItemState<MainMapPageItem> {
  Map<String, dynamic> _buildingPositions = {};

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
        child: Column(
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
                margin: EdgeInsets.only(top: 20.d),
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
          bottom: 180.d,
          end: 32.d,
          child: Widgets.button(
            context,
            child: Asset.load<Image>("icon_notifications", width: 60.d),
            onPressed: () =>
                serviceLocator<RouteService>().to(Routes.popupInbox),
          )),
      PositionedDirectional(
        bottom: 200.d,
        end: 150.d,
        height: 150.d,
        child: _box(0, "06:12:06".l()),
      ),
      PositionedDirectional(
          bottom: 200.d,
          end: 320.d,
          height: 150.d,
          child: _box(1, "chance_box".l())),
      _building(account, Buildings.defense),
      _building(account, Buildings.offense),
      _building(account, Buildings.base),
      _building(account, Buildings.treasury),
      _building(account, Buildings.mine),
      _building(account, Buildings.park),
      _building(account, Buildings.quest),
      if (account.deadlines.isNotEmpty)
        for (var i = 0; i < account.deadlines.length; i++)
          Positioned(
              right: 32.d,
              top: 200.d + i * 180.d,
              child: DeadlineIndicator(account.deadlines[i])),
    ]);
  }

  Widget _building(Account account, Buildings type) {
    if (!_buildingPositions.containsKey(type.name)) return const SizedBox();

    var building = account.buildings[type]!;
    if (building.type == Buildings.park) {
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
        child: BuildingWidget(
            building,
            onTap: () => _onBuildingTap(account, building),
            child: child));
  }

  _onBuildingTap(Account account, Building building) {
    var type = switch (building.type) {
      Buildings.quest => Routes.quest,
      Buildings.base => Routes.popupOpponents,
      Buildings.mine => Routes.popupMineBuilding,
      Buildings.treasury => Routes.popupTreasuryBuilding,
      Buildings.defense || Buildings.offense => Routes.popupSupportiveBuilding,
      _ => "",
    };
    // Offense and defense buildings need tribe membership.
    if (type == Routes.popupSupportiveBuilding &&
        (account.tribe == null || account.tribe!.id <= 0)) {
      toast("error_149".l());
      return;
    }
    // Get availability level from account
    var levels = account.loadingData.rules["availabilityLevels"]!;
    if (levels.containsKey(building.type.name)) {
      var availableAt = levels[building.type.name]!;
      if (availableAt == -1) {
        toast("coming_soon".l());
        return;
      } else if (account.level < availableAt) {
        toast("unavailable_l".l(["${building.type.name}_l".l(), availableAt]));
        return;
      }
    }

    if (type == "") {
      return;
    }
    serviceLocator<RouteService>().to(type, args: {"building": building});
  }

  Widget _box(double type, String title) {
    return Widgets.touchable(
      context,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Widgets.rect(
              color: TColors.primary20,
              padding: EdgeInsets.symmetric(horizontal: 12.d),
              borderRadius: BorderRadius.circular(30.d),
              child: Text(
                title,
                style: TStyles.small.copyWith(color: TColors.white),
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

  _onBoxTap(double type) {
    if (type == 0) {
      Overlays.insert(
          context,
          BundleFeastOverlay(
            onClose: (data) {},
          ));
    }
  }

  void _riveEventsListener(RiveEvent event) {
    Timer(const Duration(milliseconds: 100), () {
      setState(
          () => _buildingPositions = jsonDecode(event.properties["buildings"]));
    });
  }
}
