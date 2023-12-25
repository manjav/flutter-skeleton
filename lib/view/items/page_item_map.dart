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
        const LoaderWidget(AssetType.animation, "map_home", fit: BoxFit.cover),
        PositionedDirectional(
            bottom: 350.d,
            start: 32.d,
            child: Indicator("home", Values.leagueRank,
                hasPlusIcon: false,
                onTap: () => Navigator.pushNamed(
                    context, Routes.popupLeague.routeName))),
        PositionedDirectional(
            bottom: 220.d,
            start: 32.d,
            child: Indicator("home", Values.rank,
                hasPlusIcon: false,
                onTap: () => Navigator.pushNamed(
                    context, Routes.popupRanking.routeName))),
        PositionedDirectional(
            bottom: 180.d,
            end: 32.d,
            child: Widgets.button(
                child: Asset.load<Image>("icon_notifications", width: 60.d),
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.popupInbox.routeName))),
        _building(state.account, Buildings.defense, 0, -470),
        _building(state.account, Buildings.offense, -340, -330),
        _building(state.account, Buildings.base, 0, -110),
        _building(state.account, Buildings.treasury, -280, 150),
        _building(state.account, Buildings.mine, 330, -300),
        _building(state.account, Buildings.park, 340, 140),
        _building(state.account, Buildings.quest, 140, 440),
        if (state.account.deadlines.isNotEmpty)
          for (var i = 0; i < state.account.deadlines.length; i++)
            Positioned(
                right: 32.d,
                top: 200.d + i * 180.d,
                child: DeadlineIndicator(state.account.deadlines[i])),
      ]);
    });
  }

  Widget _building(Account account, Buildings type, double x, double y) {
    var building = account.buildings[type]!;
    Widget child =
        type == Buildings.mine ? BuildingBalloon(building) : const SizedBox();
    var center = DeviceInfo.size.center(Offset.zero);
    var size = Size(280.d, 300.d);
    return Positioned(
        left: center.dx + x.d - size.width * 0.5,
        top: center.dy + y.d - size.height * 0.5,
        width: size.width,
        height: size.height,
        child: BuildingWidget(building,
            child: child, onTap: () => _onBuildingTap(account, building)));
  }

  _onBuildingTap(Account account, Building building) {
    if (account.level < Account.availablityLevels["liveBattle"]!) {
      toast("unavailable_l"
          .l(["battle_l".l(), Account.availablityLevels["liveBattle"]]));
      return;
    }
    if (building.level < 1) {
      toast(account.level < Account.availablityLevels["tribe"]!
          ? "coming_soon".l()
          : "error_149".l());
      return;
    }
    var type = switch (building.type) {
      Buildings.quest => Routes.quest,
      Buildings.base => Routes.popupOpponents,
      Buildings.mine => Routes.popupMineBuilding,
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
