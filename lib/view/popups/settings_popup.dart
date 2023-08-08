import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/prefs.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/skinnedtext.dart';

class SettingsPopup extends AbstractPopup {
  const SettingsPopup({super.key, required super.args})
      : super(Routes.popupSettings);

  @override
  createState() => _SettingsPopupState();
}

class _SettingsPopupState extends AbstractPopupState<SettingsPopup> {
  @override
  void initState() {
    contentPadding = EdgeInsets.fromLTRB(60.d, 200.d, 60.d, 80.d);
    super.initState();
  }

  @override
  contentFactory() {
    return SizedBox(
        height: 1240.d,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row(
                Pref.music,
                CupertinoSwitch(value: Pref.music.getBool(), onChanged: (b) {}),
                _onRowPressed),
            _row(
                Pref.sfx,
                CupertinoSwitch(value: Pref.sfx.getBool(), onChanged: (b) {}),
                _onRowPressed),
            _row(
                Pref.language,
                IgnorePointer(
                    ignoring: true,
                    child: DropdownButton<String>(
                      value: Pref.language.getString(),
                      style: TStyles.medium,
                      icon: Asset.load<Image>("icon_chevron", width: 44.d),
                      onChanged: (String? value) =>
                          setState(() => Pref.language.setString(value!)),
                      items: ['en', 'fa']
                          .map<DropdownMenuItem<String>>((String value) =>
                              DropdownMenuItem<String>(
                                  value: value,
                                  child: SkinnedText(
                                      "${"settings_$value".l()}  ")))
                          .toList(),
                    )),
                _onRowPressed),
            Widgets.divider(width: 120.d, margin: 20.d),
            SizedBox(height: 16.d),
            _button("restore", color: ButtonColor.green, width: 660.d),
            _button("invite", color: ButtonColor.green, width: 660.d),
        _button("gift", color: ButtonColor.yellow, width: 660.d),
            Widgets.divider(width: 120.d, margin: 30.d),
            _buttons(["feedback", "credits"]),
            _buttons(["web", "instagram"]),
          ],
        ));
  }

  _row(Pref setting, Widget action, Function(Pref) onPressed) {
    return Widgets.button(
        height: 120.d,
        padding: EdgeInsets.all(30.d),
        child: Row(children: [
          Asset.load<Image>("icon_${setting.name}", height: 70.d),
          SizedBox(width: 20.d),
          Text("settings_${setting.name}".l()),
          const Expanded(child: SizedBox()),
          action,
        ]),
        onPressed: () => onPressed(setting));
  }

  _onRowPressed(Pref setting) {
    if (setting == Pref.language) {
      toast("coming_soon".l());
      return;
    }
    setting.setBool(!setting.getBool());
    setState(() {});
  }

  _button(String title, {ButtonColor color = ButtonColor.teal, double? width}) {
    return Widgets.skinnedButton(
        width: width,
        label: "settings_$title".l(),
        icon: "icon_$title",
        color: color,
        onPressed: () => _onButtonPressed(title));
  }

  _buttons(List<String> titles) {
    return Row(children: [
      _button(titles[0], color: ButtonColor.teal),
      Expanded(child: _button(titles[1], color: ButtonColor.teal)),
    ]);
  }

  _onButtonPressed(String title) {
    if (title == 'feedback' ||
        title == 'creadits' ||
        title == 'web' ||
        title == 'instagram') {
      return;
    }
    var route = switch (title) {
      "restore" => Routes.popupRestore,
      "invite" => Routes.popupInvite,
      _ => Routes.popupReward,
    };
    Navigator.pushNamed(context, route.routeName);
  }
}
