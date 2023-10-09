import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../view/popups/ipopup.dart';
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
    _account = BlocProvider.of<AccountBloc>(context).account!;
    super.initState();
  }

  @override
  String titleBuilder() => "settings_gift".l();

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
            controller: _textController,
            hintText: "settings_gift_hint".l(),
            onSubmit: (t) => setState(() {})),
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
      var data = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.redeemGift,
              params: {RpcParams.code.name: _textController.text});
      _account.update(data);
      if (!mounted) return;
      BlocProvider.of<AccountBloc>(context).add(SetAccount(account: _account));
    } finally {}
  }
}
