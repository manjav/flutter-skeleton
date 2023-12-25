import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/rpc.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import 'popup.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/skinned_text.dart';

class PotionPopup extends AbstractPopup {
  PotionPopup({super.key}) : super(Routes.popupPotion, args: {});

  @override
  createState() => _PotionPopupState();
}

class _PotionPopupState extends AbstractPopupState<PotionPopup> {
  static const capacity = 50.0;
  @override
  contentFactory() {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var potion = state.account.potion;
      var price = state.account.potionPrice;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Asset.load<Image>("icon_potion", height: 210.d),
          SizedBox(height: 32.d),
          Text("potion_description".l(),
              style: TStyles.medium.copyWith(height: 2.7.d)),
          Widgets.divider(margin: 36.d, width: 700.d),
          Widgets.slider(
            0,
            potion.toDouble(),
            capacity,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Asset.load<Image>("icon_potion", height: 64.d),
              SizedBox(width: 12.d),
              SkinnedText("$potion/${capacity.floor()}", style: TStyles.large)
            ]),
            width: 600.d,
          ),
          SizedBox(height: 50.d),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _fillButton(ButtonColor.teal, potion < capacity, "+1", price,
                  () => _fill(state.account, 1)),
              SizedBox(width: 10.d),
              _fillButton(
                  ButtonColor.yellow,
                  potion < capacity,
                  "fill_l".l(),
                  ((capacity - potion) * price).round(),
                  () => _fill(state.account, capacity - potion)),
            ],
          )
        ],
      );
    });
  }

  Widget _fillButton(ButtonColor color, bool isEnable, String label, int cost,
      Function() onTap) {
    return Widgets.skinnedButton(
        color: color,
        isEnable: isEnable,
        width: 420.d,
        height: 150.d,
        onDisablePressed: () => toast("max_level".l([titleBuilder()])),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Asset.load<Image>("icon_potion", height: 80.d),
          SizedBox(width: 6.d),
          SkinnedText(label),
          SizedBox(width: 16.d),
          Widgets.rect(
            padding: EdgeInsets.only(right: 12.d),
            decoration: Widgets.imageDecore(
                "frame_hatch_button", ImageCenterSliceData(42)),
            child: Row(children: [
              Asset.load<Image>("icon_gold", height: 66.d),
              SkinnedText(cost.compact()),
            ]),
          ),
        ]),
        onPressed: onTap);
  }

  _fill(Account account, double amount) async {
    try {
      var data =
          await rpc(RpcId.fillPotion, params: {RpcParams.amount.name: amount});
      if (!mounted) return;
      account.update(context, data);
      accountBloc.add(SetAccount(account: account));
    } finally {}
  }
}
