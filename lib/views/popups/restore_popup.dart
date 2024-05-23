import 'package:flutter/material.dart';

import '../../app_export.dart';

class RestorePopup extends AbstractPopup {
  const RestorePopup({super.key}) : super(Routes.popupRestore);

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
    barrierDismissible = canPop = !widget.args.containsKey("onlySet");
    super.initState();
  }

  @override
  String titleBuilder() => "settings_restore".l();

  @override
  closeButtonFactory() {
    if (canPop) {
      return super.closeButtonFactory();
    }
    return const SizedBox();
  }

  @override
  contentFactory() {
    var style = TStyles.medium.copyWith(height: 1);
    var items = <Widget>[];

    if (!widget.args.containsKey("onlySet")) {
      items.addAll([
        Text("settings_restore_get".l(), style: style),
        SizedBox(height: 20.d),
        SkinnedText("settings_restore_yours".l()),
        Widgets.clipboardGetter(
          context,
          accountProvider.account.restoreKey,
          onCopy: () => toast("settings_restore_copied".l()),
        ),
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
      SkinnedButton(
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

  @override
  List<Widget> appBarElements() => widget.args.containsKey("onlySet")
      ? []
      : [
          Indicator(widget.name, Values.gold),
          Indicator(widget.name, Values.nectar, width: 310.d)
        ];
}
