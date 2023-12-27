import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/core/account.dart';
import '../../main.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/prefs.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import 'popup.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/skinned_text.dart';

class RestorePopup extends AbstractPopup {
  const RestorePopup({required super.args, super.key})
      : super(Routes.popupRestore);

  @override
  createState() => _RestorePopupState();
}

class _RestorePopupState extends AbstractPopupState<RestorePopup> {
  @override
  BoxDecoration get chromeSkinBuilder => Widgets.imageDecorator(
      "popup_chrome_pink", ImageCenterSliceData(410, 460));

  late TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  String titleBuilder() => "settings_restore".l();

  @override
  contentFactory() {
    var style = TStyles.medium.copyWith(height: 1);
    var items = <Widget>[];
    if (!widget.args.containsKey("onlySet")) {
      items.addAll([
        Text("settings_restore_get".l(), style: style),
        SizedBox(height: 20.d),
        SkinnedText("settings_restore_yours".l()),
        Widgets.clipboardGetter(accountBloc.account!.restoreKey),
        Widgets.divider(width: 120.d, margin: 32.d),
      ]);
    }
    items.addAll([
      Text("settings_restore_set".l(), style: style),
      SizedBox(height: 20.d),
      Widgets.skinnedInput(
          maxLines: 1,
          controller: _textController,
          hintText: "settings_restore_hint".l(),
          onChange: (t) => setState(() {})),
      SizedBox(height: 30.d),
      Widgets.skinnedButton(
          width: 590.d,
          color: ButtonColor.green,
          icon: "icon_restore",
          label: "settings_restore".l(),
          isEnable: _textController.text.isNotEmpty,
          onPressed: _restoreAccount)
    ]);
    return SizedBox(
        child: Column(mainAxisSize: MainAxisSize.min, children: items));
  }

  _restoreAccount() {
    Pref.restoreKey.setString(_textController.text);
    MyApp.restartApp(context);
  }
}
