import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../view/popups/ipopup.dart';
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
          controller: _textController,
          hintText: "player_name".l(),
          onChanged: (t) => setState(() {})),
      SizedBox(height: 40.d),
      Widgets.skinnedButton(
          height: 160.d,
          color: ButtonColor.teal,
          label: "tribe_invite".l(),
          icon: "tribe_invite",
          isEnable: _textController.text.isNotEmpty,
          onPressed: _invite),
    ]);
  }

  _invite() {}
}
