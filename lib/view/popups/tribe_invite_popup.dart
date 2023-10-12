import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/tribe.dart';

import '../../blocs/services_bloc.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../view/popups/ipopup.dart';
import '../overlays/ioverlay.dart';
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
      Widgets.skinnedButton(
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
      var tribe = BlocProvider.of<AccountBloc>(context)
          .account!
          .get<Tribe>(AccountField.tribe);
      await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.tribeInvite, params: {
        RpcParams.tribe_id.name: tribe.id,
        RpcParams.invitee_name.name: _textController.text
      });
      if (mounted) {
        Navigator.pop(context);
        Overlays.insert(context, OverlayType.toast, args: "message");
      }
    } finally {}
  }
}
