import 'package:flutter/material.dart';

import '../../app_export.dart';

class TribeDonatePopup extends AbstractPopup {
  const TribeDonatePopup({super.key}) : super(Routes.popupTribeDonate);

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
      SkinnedText(
        "tribe_donate_description".l(),
        style: TStyles.medium.copyWith(height: 1),
        hideStroke: true,
      ),
      SizedBox(height: 50.d),
      SizedBox(
          height: 320.d,
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, childAspectRatio: 1.5),
              itemCount: _donates.length,
              itemBuilder: _gridItemBuilder)),
      SizedBox(height: 40.d),
      SkinnedButton(
          color: ButtonColor.green,
          height: 160.d,
          // width: 400.d,
          isEnable: _donateValue > 0,
          padding: EdgeInsets.fromLTRB(28.d, 18.d, 22.d, 28.d),
          onPressed: _donate,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            SkinnedText("tribe_donate".l(), style: TStyles.large),
            SizedBox(width: 20.d),
            Widgets.rect(
              padding: EdgeInsets.fromLTRB(0, 2.d, 10.d, 2.d),
              decoration: Widgets.imageDecorator(
                  "frame_hatch_button", ImageCenterSliceData(42)),
              child: Row(children: [
                Asset.load<Image>("icon_gold", height: 76.d),
                SkinnedText(_donateValue.compact(),
                    style: TStyles.large.copyWith(height: 1)),
              ]),
            )
          ])),
    ]);
  }

  Widget? _gridItemBuilder(BuildContext context, int index) {
    return Widgets.button(context,
        color: TColors.primary90,
        margin: EdgeInsets.all(10.d),
        padding: EdgeInsets.all(1.d),
        height: 160.d,
        child: SkinnedText(_donates[index].compact(), style: TStyles.large),
        onPressed: () => setState(() => _donateValue += _donates[index]));
  }

  _donate() async {
    var account = accountProvider.account;
    try {
      var result = await rpc(RpcId.tribeDonate, params: {
        RpcParams.tribe_id.name: account.tribe!.id,
        RpcParams.gold.name: _donateValue,
      });

      if (mounted) {
        account.update(context, result);
        Navigator.pop(context);
      }
    } finally {}
  }
}
