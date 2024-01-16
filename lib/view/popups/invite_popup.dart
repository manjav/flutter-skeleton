import 'package:flutter/material.dart';

import '../../data/core/account.dart';
import '../../skeleton/skeleton.dart';
import '../view.dart';

class InvitePopup extends AbstractPopup {
  InvitePopup({super.key}) : super(Routes.popupInvite, args: {});

  @override
  createState() => _InvitePopupState();
}

class _InvitePopupState extends AbstractPopupState<InvitePopup> {
  late Account _account;
  @override
  BoxDecoration get chromeSkinBuilder => Widgets.imageDecorator(
      "popup_chrome_pink", ImageCenterSliceData(410, 460));

  @override
  void initState() {
    _account = accountProvider.account;
    super.initState();
  }

  @override
  String titleBuilder() => "settings_invite".l();

  @override
  contentFactory() {
    return SizedBox(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 30.d),
        Text("settings_invite_get".l(),
            style: TStyles.medium.copyWith(height: 1)),
        SizedBox(height: 30.d),
        SkinnedText("settings_invite_yours".l()),
        SizedBox(height: 10.d),
        Widgets.clipboardGetter(context, _account.inviteKey)
      ],
    ));
  }
}
