import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../utils/assets.dart';
import '../../view/items/page_item.dart';
import '../../view/widgets/indicator.dart';
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
      return Stack(alignment: Alignment.topLeft, children: [
        const LoaderWidget(AssetType.animation, "map_home",
            fit: BoxFit.fitWidth),
        Positioned(
            top: 240.d,
            left: 32.d,
            child: Indicator("home", AccountField.league_rank,
                onTap: () => Navigator.pushNamed(
                    context, Routes.popupLeague.routeName))),
        Positioned(
            top: 380.d,
            left: 32.d,
            child: Indicator("home", AccountField.rank,
                onTap: () => Navigator.pushNamed(
                    context, Routes.popupRanking.routeName))),
        // _building(buildings[Buildings.cards]!, 167, 560),
        _building(buildings[Buildings.defense]!, 400, 300),
        _building(buildings[Buildings.offense]!, 95, 670),
        _building(buildings[Buildings.tribe]!, 725, 630),
        _building(buildings[Buildings.base]!, 400, 840),
        _building(buildings[Buildings.treasury]!, 130, 1140),
        _building(buildings[Buildings.mine]!, 754, 1140),
        // _building(buildings[Buildings.shop]!, 773, 1040),
        // _building(buildings[Buildings.quest]!, 169, 1244),
        // _building(buildings[Buildings.message]!, 532, 1268),
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
      ]);
    });
  }

  _button(String icon, String text, double x, double bottom, double width,
      [Function()? onPressed]) {
    var bgCenterSlice = ImageCenterSliceDate(
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

  Widget _building(Building building, double x, double y) {
    return Positioned(
        left: x.d,
        top: y.d,
        width: 280.d,
        height: 300.d,
        child: BuildingWidget(building.type,
            level: building.level, onTap: () => _onBuildingTap(building)));
  }

  _onBuildingTap(Building building) {
    var type = switch (building.type) {
      Buildings.mine => Routes.popupMineBuilding,
      Buildings.treasury => Routes.popupTreasuryBuilding,
      Buildings.defense || Buildings.offense => Routes.popupSupportiveBuilding,
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
