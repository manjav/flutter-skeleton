import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../../view/widgets.dart';
import '../../view/widgets/skinnedtext.dart';
import '../building_mixin.dart';
import '../building_supportive_mixin.dart';
import '../route_provider.dart';

class MineBuildingPopup extends AbstractPopup {
  const MineBuildingPopup({required super.args, super.key})
      : super(Routes.popupMineBuilding);

  @override
  createState() => _MineBuildingPopupState();
}

class _MineBuildingPopupState extends AbstractPopupState<MineBuildingPopup>
    with BuildingPopupMixin, SupportiveBuildingPopupMixin {
  @override
  contentFactory() {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var benefits = building.getCardsBenefit(state.account);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Column(
                children: [
                  getBuildingIcon(),
                  SizedBox(height: 8.d),
                  SkinnedText("level_l".l([building.level])),
                ],
              ),
              SizedBox(width: 32.d),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dualColorText("building_mine_speed".l(), benefits.compact(),
                      style: TStyles.medium),
                  dualColorText(
                      "building_mine_capacity".l(), building.benefit.compact(),
                      style: TStyles.medium),
                ],
              )
            ],
          ),
          SizedBox(height: 16.d),
          Text(descriptionBuilder(),
              style: TStyles.medium.copyWith(height: 2.7.d)),
          SizedBox(height: 48.d),
          upgtadeButton(state.account, building),
          Widgets.divider(margin: 36.d, width: 700.d),
          cardHolder(building),
          SizedBox(height: 48.d)
        ],
      );
    });
  }
}
