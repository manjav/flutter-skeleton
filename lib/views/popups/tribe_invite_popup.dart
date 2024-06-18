import 'package:flutter/material.dart';

import '../../app_export.dart';

class TribeInvitePopup extends AbstractPopup {
  const TribeInvitePopup({super.key}) : super(Routes.popupTribeInvite);

  @override
  createState() => _TribeInvitePopupState();
}

class _TribeInvitePopupState extends AbstractPopupState<TribeInvitePopup> {
  final TextEditingController _textController = TextEditingController();

  @override
  contentFactory() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 860.d, height: 60.d),
      SkinnedText(
        "tribe_invite_description".l(),
        style: TStyles.medium.copyWith(height: 1),
        hideStroke: true,
      ),
      SizedBox(height: 50.d),
      Widgets.skinnedInput(
          width: 700.d,
          maxLines: 1,
          hintText: "player_name".l(),
          controller: _textController,
          onChange: (t) => setState(() {})),
      SizedBox(height: 40.d),
      SkinnedButton(
          height: 160.d,
          color: ButtonColor.teal,
          label: "tribe_invite".l(),
          icon: "tribe_invite",
          isEnable: _textController.text.isNotEmpty,
          onPressed: _invite),
    ]);
  }

  _invite() async {
    try {
      await rpc(RpcId.tribeInvite, params: {
        RpcParams.tribe_id.name: accountProvider.account.tribe!.id,
        RpcParams.invitee_name.name: _textController.text
      });
      if (mounted) {
        Navigator.pop(context);
        Overlays.insert(context, const ToastOverlay("message"));
      }
    } finally {}
  }
}
