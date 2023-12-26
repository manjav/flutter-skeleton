import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/rpc.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import 'popup.dart';
import '../route_provider.dart';
import '../widgets.dart';

class RedeemGiftPopup extends AbstractPopup {
  RedeemGiftPopup({super.key}) : super(Routes.popupRedeemGift, args: {});

  @override
  createState() => _RewardPopupState();
}

class _RewardPopupState extends AbstractPopupState<RedeemGiftPopup> {
  late Account _account;
  late TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    _account = accountBloc.account!;
    super.initState();
  }

  @override
  String titleBuilder() => "settings_gift".l();
  @override
  BoxDecoration get chromeSkinBuilder =>
      Widgets.imageDecorator("popup_chrome_pink", ImageCenterSliceData(410, 460));

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
        Widgets.skinnedButton(
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
      _account.update(context, data);
      accountBloc.add(SetAccount(account: _account));
    } finally {}
  }
}
