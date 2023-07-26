import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services.dart';
import '../../data/core/account.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../../view/widgets.dart';
import '../../view/widgets/skinnedtext.dart';
import '../building_mixin.dart';
import '../building_supportive_mixin.dart';
import '../route_provider.dart';

class TreasuryBuildingPopup extends AbstractPopup {
  const TreasuryBuildingPopup({super.key, required super.args})
      : super(Routes.popupTreasuryBuilding);

  @override
  createState() => _TreasuryBuildingPopupState();
}

class _TreasuryBuildingPopupState
    extends AbstractPopupState<TreasuryBuildingPopup>
    with BuildingPopupMixin, SupportiveBuildingPopupMixin {
  @override
  contentFactory() {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var gold = state.account.get<int>(AccountField.bank_account_balance);
      var step = (building.benefit / 5).round();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          getBuildingIcon(),
          SkinnedText("level_l".l([building.level])),
          SizedBox(height: 16.d),
          Text(descriptionBuilder(),
              style: TStyles.medium.copyWith(height: 2.7.d)),
          SizedBox(height: 48.d),
          upgtadeButton(state.account, building),
          Widgets.divider(margin: 36.d, width: 700.d),
          Widgets.slider(0, gold.toDouble(), building.benefit.toDouble(),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Asset.load<Image>("ui_gold", height: 64.d),
                SkinnedText("${gold.compact()}/${building.benefit.compact()}",
                    style: TStyles.large),
              ])),
          SizedBox(height: 32.d),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _transactionButton(
                  ButtonColor.teal,
                  gold > 0,
                  [
                    Asset.load<Image>("ui_gold", height: 64.d),
                    SizedBox(width: 8.d),
                    SkinnedText("-${step.compact()}".l())
                  ],
                  () => _transaction(state.account, RpcId.witdraw, step)),
              SizedBox(width: 40.d),
              _transactionButton(
                  ButtonColor.green,
                  gold < building.benefit,
                  [
                    Asset.load<Image>("ui_down", height: 36.d),
                    SizedBox(width: 16.d),
                    SkinnedText("building_treasury_deposit".l())
                  ],
                  () => _transaction(state.account, RpcId.deposit, step)),
            ],
          )
        ],
      );
    });
  }

  Widget _transactionButton(ButtonColor color, bool isEnable,
      List<Widget> children, Function() onTap) {
    return Widgets.skinnedButton(
        color: color,
        isEnable: isEnable,
        height: 140.d,
        width: 360.d,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center, children: children),
        onPressed: onTap);
  }

  _transaction(Account account, RpcId id, int amount) async {
    try {
      var data = await BlocProvider.of<Services>(context)
          .get<HttpConnection>()
          .tryRpc(context, id, params: {RpcParams.amount.name: amount});
      account.update(data);
      if (!mounted) return;
      BlocProvider.of<AccountBloc>(context).add(SetAccount(account: account));
    } finally {}
  }
}