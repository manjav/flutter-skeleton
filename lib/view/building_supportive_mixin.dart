import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/account_bloc.dart';
import '../blocs/services.dart';
import '../data/core/account.dart';
import '../data/core/building.dart';
import '../data/core/card.dart';
import '../data/core/rpc.dart';
import '../services/connection/http_connection.dart';
import 'popups/ipopup.dart';
import 'route_provider.dart';
import 'widgets/card_holder.dart';

mixin SupportiveBuildingPopupMixin<T extends AbstractPopup> on State<T> {
  cardHolder(Building building) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < building.cards.length; i++)
            CardHolder(
                card: building.cards[i], onTap: () => onSelectCard(i, building))
        ]);
  }

  onSelectCard(int index, Building building) async {
    var returnValue = await Navigator.pushNamed(
        context, Routes.popupCardSelect.routeName,
        arguments: {'building': building});
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
    await BlocProvider.of<Services>(context)
        .get<HttpConnection>()
        .tryRpc(context, RpcId.assignCard, params: params);
    for (var i = 0; i < selectedCards.length; i++) {
      building.cards[i] = selectedCards[i];
    }

    if (!mounted) return;
    var accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.account!.get<Map<Buildings, Building>>(
        AccountField.buildings)[building.type] = building;
    accountBloc.add(SetAccount(account: accountBloc.account!));
  }
}