import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_export.dart';

class MineBuildingPopup extends AbstractPopup {
  const MineBuildingPopup({super.key})
      : super(Routes.popupMineBuilding);

  @override
  createState() => _MineBuildingPopupState();
}

class _MineBuildingPopupState extends AbstractPopupState<MineBuildingPopup>
    with BuildingPopupMixin, SupportiveBuildingPopupMixin {
  @override
  contentFactory() {
    return Consumer<AccountProvider>(builder: (_, state, child) {
      var benefits = building.getCardsBenefit(state.account);
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Column(children: [
            getBuildingIcon(),
            SizedBox(height: 8.d),
            SkinnedText("level_l".l([building.level])),
          ]),
          SizedBox(width: 32.d),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            dualColorText("building_mine_speed".l(), benefits.compact(),
                style: TStyles.medium),
            dualColorText(
                "building_mine_capacity".l(), building.benefit.compact(),
                style: TStyles.medium),
          ])
        ]),
        SizedBox(height: 16.d),
        SkinnedText(descriptionBuilder(),
            style: TStyles.medium.copyWith(height: 2.7.d),hideStroke: true,),
        SizedBox(height: 48.d),
        upgradeButton(state.account, building),
        Widgets.divider(margin: 36.d, width: 700.d),
        cardHolder(building),
        SizedBox(height: 48.d)
      ]);
    });
  }
}
