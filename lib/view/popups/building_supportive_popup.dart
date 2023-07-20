import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/building.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../../view/widgets.dart';
import '../../view/widgets/skinnedtext.dart';
import '../map_elements/building_widget.dart';
import '../route_provider.dart';
import '../widgets/card_holder.dart';
import 'building_mixin.dart';

class SupportiveBuildingPopup extends AbstractPopup {
  const SupportiveBuildingPopup({super.key, required super.args})
      : super(Routes.popupCard);

  @override
  createState() => _WarBuildingPopupState();
}

class _WarBuildingPopupState extends AbstractPopupState<SupportiveBuildingPopup>
    with BuildingPopupMixin {
  final SelectedCards _selectedCards =
      SelectedCards(List.generate(4, (i) => null));

  @override
  contentFactory() {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var accountPower = state.account.calculateMaxPower();
      var benefits = building.getCardsBenefit(state.account);
      var cards = state.account.getCards();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: 360.d,
              child: BuildingWidget(building.type,
                  level: building.get<int>(BuildingField.level))),
          SizedBox(height: 8.d),
          SkinnedText("level_l".l([building.level])),
          SizedBox(height: 16.d),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SkinnedText("building_defense_value".l(), style: TStyles.large),
            SkinnedText("  ${accountPower.compact()} + ${benefits.compact()}",
                style: TStyles.large.copyWith(color: TColors.orange)),
          ]),
          SizedBox(height: 16.d),
          Text(descriptionBuilder(),
              style: TStyles.medium.copyWith(height: 2.7.d)),
          Widgets.divider(margin: 36.d, width: 700.d),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SkinnedText("building_cards_benefit".l()),
            SkinnedText("  ${benefits.compact()}",
                style: TStyles.medium.copyWith(color: TColors.orange)),
          ]),
          SizedBox(height: 16.d),
        ],
      );
    });
  }
}
