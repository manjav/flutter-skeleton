import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/rpc.dart';
import '../../data/core/tribe.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';

class TribeDonatePopup extends AbstractPopup {
  TribeDonatePopup({super.key}) : super(Routes.popupTribeDonate, args: {});

  @override
  createState() => _TribeDonatePopupState();
}

class _TribeDonatePopupState extends AbstractPopupState<TribeDonatePopup> {
  final List<int> _donates = [
    100,
    500,
    1000,
    5000,
    10000,
    50000,
    100000,
    500000,
  ];
  int _donateValue = 0;
  @override
  contentFactory() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(height: 60.d),
      Text("tribe_donate_description".l(),
          style: TStyles.medium.copyWith(height: 1)),
      SizedBox(height: 50.d),
      SizedBox(
          height: 320.d,
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, childAspectRatio: 1.5),
              itemCount: _donates.length,
              itemBuilder: _gridItemBuilder)),
      SizedBox(height: 40.d),
      Widgets.skinnedButton(
          color: ButtonColor.green,
          height: 160.d,
          // width: 400.d,
          isEnable: _donateValue > 0,
          padding: EdgeInsets.fromLTRB(28.d, 18.d, 22.d, 28.d),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            SkinnedText("tribe_donate".l(), style: TStyles.large),
            SizedBox(width: 20.d),
            Widgets.rect(
              padding: EdgeInsets.fromLTRB(0, 2.d, 10.d, 2.d),
              decoration: Widgets.imageDecore(
                  "ui_frame_inside", ImageCenterSliceData(42)),
              child: Row(children: [
                Asset.load<Image>("icon_gold", height: 76.d),
                SkinnedText(_donateValue.compact(),
                    style: TStyles.large.copyWith(height: 1)),
              ]),
            )
          ]),
          onPressed: _donate),
    ]);
  }

  Widget? _gridItemBuilder(BuildContext context, int index) {
    return Widgets.button(
        color: TColors.primary90,
        margin: EdgeInsets.all(10.d),
        padding: EdgeInsets.all(1.d),
        height: 160.d,
        child: SkinnedText(_donates[index].compact(), style: TStyles.large),
        onPressed: () => setState(() => _donateValue += _donates[index]));
  }

  _donate() async {
    var account = accountBloc.account!;
    try {
      var result = await rpc(RpcId.tribeDonate, params: {
        RpcParams.tribe_id.name: account.get<Tribe>(AccountField.tribe).id,
        RpcParams.gold.name: _donateValue,
      });

      account.update(result);
      if (mounted) Navigator.pop(context);
    } finally {}
  }
}
