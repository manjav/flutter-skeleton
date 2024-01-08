import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/core/rpc.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import 'popup.dart';
import '../overlays/overlay.dart';
import '../route_provider.dart';
import '../widgets.dart';

class TribeInvitePopup extends AbstractPopup {
  TribeInvitePopup({super.key}) : super(Routes.popupTribeInvite, args: {});

  @override
  createState() => _TribeInvitePopupState();
}

class _TribeInvitePopupState extends AbstractPopupState<TribeInvitePopup> {
  final TextEditingController _textController = TextEditingController();

  @override
  contentFactory() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 860.d, height: 60.d),
      Text("tribe_invite_description".l(),
          style: TStyles.medium.copyWith(height: 1)),
      SizedBox(height: 50.d),
      Widgets.skinnedInput(
          width: 700.d,
          maxLines: 1,
          hintText: "player_name".l(),
          controller: _textController,
          onChange: (t) => setState(() {})),
      SizedBox(height: 40.d),
      Widgets.skinnedButton(context,
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
        RpcParams.tribe_id.name: accountBloc.account!.tribe!.id,
        RpcParams.invitee_name.name: _textController.text
      });
      if (mounted) {
        Navigator.pop(context);
        Overlays.insert(context, OverlayType.toast, args: "message");
      }
    } finally {}
  }
}
