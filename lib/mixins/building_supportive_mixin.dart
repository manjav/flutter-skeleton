import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/localization.dart';
import '../blocs/account_bloc.dart';
import '../blocs/services_bloc.dart';
import '../data/core/building.dart';
import '../data/core/fruit.dart';
import '../data/core/rpc.dart';
import '../services/connection/http_connection.dart';
import '../view/overlays/overlay.dart';
import '../view/popups/popup.dart';
import '../view/route_provider.dart';
import '../view/widgets/card_holder.dart';

mixin SupportiveBuildingPopupMixin<T extends AbstractPopup> on State<T> {
  cardHolder(Building building, {bool showPower = false}) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < building.cards.length; i++)
            CardHolder(
                showPower: showPower,
                card: building.cards[i],
                isLocked: i >= building.maxCards,
                onTap: () => onSelectCard(i, building))
        ]);
  }

  onSelectCard(int index, Building building) async {
    if (index >= building.maxCards) {
      Overlays.insert(context, OverlayType.toast,
          args: "card_holder_unavailable".l([
            "building_${building.type.name}_t".l(),
            building.isAvailableCardHolder(index)
          ]));
      return;
    }
    var returnValue = await Routes.popupCardSelect
        .navigate(context, args: {'building': building});
    if (returnValue == null) return;
    var selectedCards = returnValue as List<AccountCard?>;
    if (const ListEquality().equals(selectedCards, building.cards) ||
        !mounted) {
      return;
    }
    var cardIds =
        selectedCards.map((c) => c?.id).where((id) => id != null).join(',');
    var params = {
      RpcParams.cards.name: "[$cardIds]",
      RpcParams.type.name: building.type.id
    };
    if (context.mounted) {
      await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.assignCard, params: params);
    }
    for (var i = 0; i < selectedCards.length; i++) {
      building.cards[i] = selectedCards[i];
    }

    if (!mounted) return;
    var accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.account!.buildings[building.type] = building;
    accountBloc.add(SetAccount(account: accountBloc.account!));
  }
}
