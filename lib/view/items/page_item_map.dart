import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../data/core/infra.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/widgets/building_balloon.dart';
import '../../view/widgets/indicator.dart';
import '../../view/widgets/indicator_dedline.dart';
import '../../view/widgets/loaderwidget.dart';
import '../../view/widgets/skinnedtext.dart';
import '../map_elements/building_widget.dart';
import '../overlays/ioverlay.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'page_item.dart';

class MainMapPageItem extends AbstractPageItem {
  const MainMapPageItem({super.key}) : super("battle");
  @override
  createState() => _MainMapItemState();
}

class _MainMapItemState extends AbstractPageItemState<MainMapPageItem> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      return Stack(alignment: Alignment.topLeft, children: [
        const LoaderWidget(AssetType.animation, "map_home",
            fit: BoxFit.fitWidth),
        PositionedDirectional(
            top: 380.d,
            start: 32.d,
            child: Indicator("home", Values.leagueRank,
                hasPlusIcon: false,
                onTap: () => Navigator.pushNamed(
                    context, Routes.popupLeague.routeName))),
        PositionedDirectional(
            top: 240.d,
            start: 32.d,
            child: Indicator("home", Values.rank,
                hasPlusIcon: false,
                onTap: () => Navigator.pushNamed(
                    context, Routes.popupRanking.routeName))),
        PositionedDirectional(
            top: 150.d,
            end: 24.d,
            child: Widgets.button(
                child: Asset.load<Image>("icon_notifications", width: 60.d),
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.popupInbox.routeName))),
        _building(state.account, Buildings.defense, 400, 300),
        _building(state.account, Buildings.offense, 95, 670),
        _building(state.account, Buildings.base, 400, 820),
        _building(state.account, Buildings.treasury, 130, 1140),
        _building(state.account, Buildings.mine, 754, 1140),
        _button("battle", "battle_l", 150, 270, 442, () {
          if (state.account.level < Account.availablityLevels["liveBattle"]!) {
            Overlays.insert(context, OverlayType.toast,
                args: "unavailable_l".l(
                    ["battle_l".l(), Account.availablityLevels["liveBattle"]]));
          } else {
            Navigator.pushNamed(context, Routes.popupOpponents.routeName);
          }
        }),
        _button("quest", "quest_l", 620, 270, 310,
            () => Navigator.pushNamed(context, Routes.quest.routeName)),
        if (state.account.deadlines.isNotEmpty)
          for (var i = 0; i < state.account.deadlines.length; i++)
            Positioned(
                right: 32.d,
                top: 200.d + i * 180.d,
                child: DeadlineIndicator(state.account.deadlines[i])),
      ]);
    });
  }

  _button(String icon, String text, double x, double bottom, double width,
      [Function()? onPressed]) {
    return Positioned(
        left: x.d,
        bottom: bottom.d,
        width: width.d,
        height: 202.d,
        child: Widgets.button(
          onPressed: onPressed,
          decoration: Widgets.imageDecore(
              "button_map",
              ImageCenterSliceData(422, 202,
                  const Rect.fromLTWH(85, 85, 422 - 85 * 2, 202 - 85 * 2))),
          child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                    top: -80.d,
                    width: 148.d,
                    child: LoaderWidget(AssetType.image, "icon_$icon")),
                Positioned(
                    bottom: -10.d,
                    child: SkinnedText(text.l(), style: TStyles.large))
              ]),
        ));
  }

  Widget _building(Account account, Buildings type, double x, double y) {
    var building = account.buildings[type]!;
    Widget child =
        type == Buildings.mine ? BuildingBalloon(building) : const SizedBox();
    return Positioned(
        left: x.d,
        top: y.d,
        width: 280.d,
        height: 300.d,
        child: BuildingWidget(building,
            child: child, onTap: () => _onBuildingTap(account, building)));
  }

  _onBuildingTap(Account account, Building building) {
    if (building.level < 1) {
      Overlays.insert(context, OverlayType.toast,
          args: account.level < Account.availablityLevels["tribe"]!
              ? "coming_soon".l()
              : "error_149".l());
      return;
    }
    var type = switch (building.type) {
      Buildings.base => Routes.popupMineBuilding,
      Buildings.treasury => Routes.popupTreasuryBuilding,
      Buildings.defense || Buildings.offense => Routes.popupSupportiveBuilding,
      _ => Routes.none,
    };
    if (type == Routes.none) {
      return;
    }
    Navigator.pushNamed(context, type.routeName,
        arguments: {"building": building});
  }
}
