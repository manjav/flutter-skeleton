import 'package:flutter/material.dart';

import '../../app_export.dart';

class RedeemGiftPopup extends AbstractPopup {
  const RedeemGiftPopup({super.key}) : super(Routes.popupRedeemGift);

  @override
  createState() => _RewardPopupState();
}

class _RewardPopupState extends AbstractPopupState<RedeemGiftPopup> {
  late TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  String titleBuilder() => "settings_gift".l();
  @override
  BoxDecoration get chromeSkinBuilder => Widgets.imageDecorator(
      "popup_chrome_pink", ImageCenterSliceData(410, 460));

  @override
  contentFactory() {
    var style = TStyles.medium.copyWith(height: 1);
    return SizedBox(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 30.d),
        Text("settings_gift_set".l(), style: style),
        SizedBox(height: 50.d),
        Widgets.skinnedInput(
            maxLines: 1,
            controller: _textController,
            hintText: "settings_gift_hint".l(),
            onChange: (t) => setState(() {})),
        SizedBox(height: 40.d),
        SkinnedButton(
            width: 540.d,
            icon: "icon_gift",
            label: "settings_gift".l(),
            isEnable: _textController.text.isNotEmpty,
            onPressed: _redeemGift),
      ],
    ));
  }

  _redeemGift() async {
    try {
      var data = await rpc(RpcId.redeemGift,
          params: {RpcParams.code.name: _textController.text});
      if (!mounted) return;
      accountProvider.update(context, data);
    } finally {}
  }
}
