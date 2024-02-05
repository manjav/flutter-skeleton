import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_export.dart';

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
      Overlays.insert(
        context,
        ToastOverlay("card_holder_unavailable".l([
          "building_${building.type.name}_t".l(),
          building.isAvailableCardHolder(index)
        ])),
      );
      return;
    }
    var returnValue = await context
        .read<ServicesProvider>()
        .get<RouteService>()
        .to(Routes.popupCardSelect, args: {'building': building});
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
      await context
          .read<ServicesProvider>()
          .get<HttpConnection>()
          .tryRpc(context, RpcId.assignCard, params: params);
    }
    for (var i = 0; i < selectedCards.length; i++) {
      building.cards[i] = selectedCards[i];
    }

    if (mounted) {
      var accountProvider = context.read<AccountProvider>();
      accountProvider.updateBuilding(building);
      context
          .read<ServicesProvider>()
          .get<Notifications>()
          .schedule(accountProvider.account.getSchedules());
    }
  }
}
