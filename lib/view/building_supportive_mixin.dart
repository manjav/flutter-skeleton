import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../utils/utils.dart';
import '../../view/widgets.dart';
import '../blocs/account_bloc.dart';
import '../blocs/services.dart';
import '../data/core/account.dart';
import '../data/core/building.dart';
import '../data/core/card.dart';
import '../data/core/rpc.dart';
import '../services/connection/http_connection.dart';
import '../services/theme.dart';
import '../utils/assets.dart';
import 'overlays/ioverlay.dart';
import 'popups/ipopup.dart';
import 'route_provider.dart';
import 'widgets/card_holder.dart';
import 'widgets/skinnedtext.dart';

mixin SupportiveBuildingPopupMixin<T extends AbstractPopup> on State<T> {
  cardHolder(Building building, {bool showPower = false}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < building.cards.length; i++)
            CardHolder(
                showPower: showPower,
                card: building.cards[i],
                onTap: () => onSelectCard(i, building))
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

  upgtadeButton(Account account, Building building) {
    var bgCenterSlice = ImageCenterSliceDate(42, 42);
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Widgets.skinnedButton(
            height: 160.d,
            isEnable: building.level < building.maxLevel,
            color: ButtonColor.green,
            padding: EdgeInsets.fromLTRB(44.d, 10.d, 32.d, 30.d),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkinnedText("upgrade_l".l(),
                    style: TStyles.large.copyWith(height: 3.d)),
                SizedBox(width: 24.d),
                Widgets.rect(
                  padding:
                      EdgeInsets.symmetric(vertical: 6.d, horizontal: 12.d),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          centerSlice: bgCenterSlice.centerSlice,
                          image: Asset.load<Image>('ui_frame_inside',
                                  centerSlice: bgCenterSlice)
                              .image)),
                  child: Row(children: [
                    Asset.load<Image>("ui_gold", height: 76.d),
                    SkinnedText(building.upgradeCost.compact(),
                        style: TStyles.large),
                  ]),
                )
              ],
            ),
            onPressed: () => _upgrade(account, building),
            onDisablePressed: () => Overlays.insert(context, OverlayType.toast,
                args: "building_max_level"
                    .l(["building_${building.type.name}_t".l()])),
          )
        ]);
  }

  _upgrade(Account account, Building building) async {
    var params = {RpcParams.type.name: building.type.id};
    var tribe = account.getBuilding(Buildings.tribe);
    if (tribe != null) {
      params[RpcParams.tribe_id.name] = tribe.get<int>(BuildingField.id);
    }
    try {
      var data = await BlocProvider.of<Services>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.upgrade, params: params);
      if (!mounted) return;
      var accountBloc = BlocProvider.of<AccountBloc>(context);
      accountBloc.account!.update(data);
      building.map["level"] = data["level"];
      accountBloc.add(SetAccount(account: accountBloc.account!));
    } finally {}
  }
}
