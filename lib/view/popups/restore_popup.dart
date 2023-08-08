import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/rpc_data.dart';
import '../../main.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/skinnedtext.dart';

class RestorePopup extends AbstractPopup {
  const RestorePopup({super.key, required super.args})
      : super(Routes.popupRestore);

  @override
  createState() => _RestorePopupState();
}

class _RestorePopupState extends AbstractPopupState<RestorePopup> {
  late Account _account;
  late TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    _account = BlocProvider.of<AccountBloc>(context).account!;
    super.initState();
  }

  @override
  String titleBuilder() => "settings_restore".l();

  @override
  contentFactory() {
    var style = TStyles.medium.copyWith(height: 1);
    return SizedBox(
        height: 960.d,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30.d),
            Text("settings_restore_get".l(), style: style),
            SizedBox(height: 30.d),
            SkinnedText("settings_restore_yours".l()),
            Widgets.clipboardGetter(
                _account.get<String>(AccountField.restore_key)),
            Widgets.divider(width: 120.d, margin: 36.d),
            Text("settings_restore_set".l(), style: style),
            SizedBox(height: 30.d),
            Widgets.skinnedInput(
                controller: _textController,
                hintText: "settings_restore_hint".l(),
                onChanged: (t) => setState(() {})),
            SizedBox(height: 40.d),
            Widgets.skinnedButton(
                width: 590.d,
                color: ButtonColor.green,
                icon: "icon_restore",
                label: "settings_restore".l(),
                isEnable: _textController.text.isNotEmpty,
                onPressed: _restoreAccount),
          ],
        ));
  }

  _restoreAccount() {
    LoadingData.restoreKey = _textController.text;
    MyApp.restartApp(context);
  }
}
