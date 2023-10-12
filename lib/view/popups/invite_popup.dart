import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/skinnedtext.dart';

class InvitePopup extends AbstractPopup {
  InvitePopup({super.key}) : super(Routes.popupInvite, args: {});

  @override
  createState() => _InvitePopupState();
}

class _InvitePopupState extends AbstractPopupState<InvitePopup> {
  late Account _account;

  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
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
        Widgets.clipboardGetter(_account.get<String>(AccountField.invite_key))
      ],
    ));
  }
}
