import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_export.dart';

class SupportiveBuildingPopup extends AbstractPopup {
  const SupportiveBuildingPopup({required super.args, super.key})
      : super(Routes.popupSupportiveBuilding);

  @override
  createState() => _SupportiveBuildingPopupState();
}

class _SupportiveBuildingPopupState
    extends AbstractPopupState<SupportiveBuildingPopup>
    with BuildingPopupMixin, SupportiveBuildingPopupMixin {
  @override
  contentFactory() {
    return Consumer<AccountProvider>(builder: (_, state, child) {
      var benefits = building.getCardsBenefit(state.account);
      return Column(mainAxisSize: MainAxisSize.min, children: [
        getBuildingIcon(),
        SizedBox(height: 8.d),
        SkinnedText("level_l".l([building.level])),
        SizedBox(height: 16.d),
        dualColorText(
            "${"building_${building.type.name}_value".l()}  ${state.account.calculateMaxPower().compact()}",
            " + ${benefits.compact()}"),
        SizedBox(height: 16.d),
        Text(descriptionBuilder(),
            style: TStyles.medium.copyWith(height: 2.7.d)),
        Widgets.divider(margin: 36.d, width: 700.d),
        dualColorText("building_cards_benefit".l(), benefits.compact(),
            style: TStyles.medium),
        SizedBox(height: 16.d),
        cardHolder(building),
      ]);
    });
  }
}
