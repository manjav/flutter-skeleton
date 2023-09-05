import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../utils/assets.dart';
import '../../view/items/page_item.dart';
import '../../view/widgets/building_balloon.dart';
import '../../view/widgets/indicator.dart';
import '../../view/widgets/indicator_dedline.dart';
import '../../view/widgets/loaderwidget.dart';
import '../../view/widgets/skinnedtext.dart';
import '../map_elements/building_widget.dart';
import '../overlays/ioverlay.dart';
import '../route_provider.dart';
import '../widgets.dart';

class MainMapPageItem extends AbstractPageItem {
  const MainMapPageItem({super.key}) : super("battle");
  @override
  createState() => _MainMapItemState();
}

class _MainMapItemState extends AbstractPageItemState<AbstractPageItem> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var buildings =
          state.account.get<Map<Buildings, Building>>(AccountField.buildings);
      List<Deadline> deadlines = state.account.map["deadlines"] ?? [];
      return Stack(alignment: Alignment.topLeft, children: [
        const LoaderWidget(AssetType.animation, "map_home",
            fit: BoxFit.fitWidth),
        Positioned(
            top: 240.d,
            left: 32.d,
            child: Indicator("home", AccountField.league_rank,
                hasPlusIcon: false,
                onTap: () => Navigator.pushNamed(
                    context, Routes.popupLeague.routeName))),
        Positioned(
            top: 380.d,
            left: 32.d,
            child: Indicator("home", AccountField.rank,
                hasPlusIcon: false,
                onTap: () => Navigator.pushNamed(
                    context, Routes.popupRanking.routeName))),
        _building(state.account, buildings[Buildings.defense]!, 400, 300),
        _building(state.account, buildings[Buildings.offense]!, 95, 670),
        _building(state.account, buildings[Buildings.tribe]!, 725, 630),
        _building(state.account, buildings[Buildings.base]!, 400, 840),
        _building(state.account, buildings[Buildings.treasury]!, 130, 1140),
        _building(state.account, buildings[Buildings.mine]!, 754, 1140),
        _button(
            "battle",
            "battle_l",
            150,
            270,
            442,
            () =>
                Navigator.pushNamed(context, Routes.popupOpponents.routeName)),
        _button("quest", "quest_l", 620, 270, 310,
            () => Navigator.pushNamed(context, Routes.deck.routeName)),
        if (state.account.contains(AccountField.deadlines))
          for (var i = 0; i < deadlines.length; i++)
            Positioned(
                right: 32.d,
                top: 200.d + i * 180.d,
                child: DeadlineIndicator(deadlines[i])),
      ]);
    });
  }

  _button(String icon, String text, double x, double bottom, double width,
      [Function()? onPressed]) {
    var bgCenterSlice = ImageCenterSliceData(
        422, 202, const Rect.fromLTWH(85, 85, 422 - 85 * 2, 202 - 85 * 2));
    return Positioned(
        left: x.d,
        bottom: bottom.d,
        width: width.d,
        height: 202.d,
        child: Widgets.button(
          onPressed: onPressed,
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  centerSlice: bgCenterSlice.centerSlice,
                  image: Asset.load<Image>(
                    'ui_button_map',
                    centerSlice: bgCenterSlice,
                  ).image)),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                  top: -80.d,
                  width: 148.d,
                  child: LoaderWidget(AssetType.image, "icon_$icon")),
              Positioned(bottom: -10.d, child: SkinnedText(text.l()))
            ],
          ),
        ));
  }

  Widget _building(Account account, Building building, double x, double y) {
    Widget child = building.type == Buildings.mine
        ? BuildingBalloon(building)
        : const SizedBox();
    return Positioned(
        left: x.d,
        top: y.d,
        width: 280.d,
        height: 300.d,
        child: BuildingWidget(building,
            child: child, onTap: () => _onBuildingTap(account, building)));
  }

  _onBuildingTap(Account account, Building building) {
    var type = switch (building.type) {
      Buildings.mine => Routes.popupMineBuilding,
      Buildings.treasury => Routes.popupTreasuryBuilding,
      Buildings.defense || Buildings.offense => Routes.popupSupportiveBuilding,
      // Buildings.base => Routes.livebattle,
      _ => Routes.none,
    };
    if (type == Routes.none) {
      Overlays.insert(context, OverlayType.toast, args: "coming_soon".l());
      return;
    }
    Navigator.pushNamed(context, type.routeName,
        arguments: {"building": building});
  }
}
