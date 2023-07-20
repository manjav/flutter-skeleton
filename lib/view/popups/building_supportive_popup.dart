import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../data/core/card.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
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
      : super(Routes.popupSupportiveBuilding);

  @override
  createState() => _WarBuildingPopupState();
}

class _WarBuildingPopupState extends AbstractPopupState<SupportiveBuildingPopup>
    with BuildingPopupMixin {

  @override
  contentFactory() {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var accountPower = state.account.calculateMaxPower();
      var benefits = building.getCardsBenefit(state.account);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < building.cards.length; i++)
                CardHolder(
                    card: building.cards[i], onTap: () => _onSelectCard(i))
            ],
          ),
          SizedBox(height: 48.d),
        ],
      );
    });
  }

  _onSelectCard(int index) async {
    var returnValue = await Navigator.pushNamed(
        context, Routes.popupCardSelect.routeName,
        arguments: {'building': building});
    if (returnValue == null) return;
    var selectedCards = returnValue as List<AccountCard?>;
    if (const ListEquality().equals(selectedCards, building.cards) ||
        !mounted) {
      return;
    }
    for (var i = 0; i < selectedCards.length; i++) {
      building.cards[i] = selectedCards[i];
    }
    var accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.account!.get<Map<Buildings, Building>>(
        AccountField.buildings)[building.type] = building;
    accountBloc.add(SetAccount(account: accountBloc.account!));
  }
}
