import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app_export.dart';

class SettingsPopup extends AbstractPopup {
  const SettingsPopup({super.key}) : super(Routes.popupSettings);

  @override
  createState() => _SettingsPopupState();
}

class _SettingsPopupState extends AbstractPopupState<SettingsPopup> {
  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(60.d, 200.d, 60.d, 80.d);
  @override
  BoxDecoration get chromeSkinBuilder => Widgets.imageDecorator(
      "popup_chrome_pink", ImageCenterSliceData(410, 460));

  @override
  Widget contentFactory() {
    return Column(
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
            Row(children: [
              SkinnedText("settings_${Pref.language.getString()}".l()),
              SizedBox(width: 16.d),
              Asset.load<Image>("icon_chevron", width: 44.d),
            ]),
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
    );
  }

  Widget _row(Pref setting, Widget action, Function(Pref) onPressed) {
    return Widgets.button(context,
        height: 120.d,
        padding: EdgeInsets.all(30.d),
        child: Row(children: [
          Asset.load<Image>("icon_${setting.name}", height: 70.d),
          SizedBox(width: 20.d),
          Text("settings_${setting.name}".l()),
          const Expanded(child: SizedBox()),
          IgnorePointer(child: action),
        ]),
        onPressed: () => onPressed(setting));
  }

  void _onRowPressed(Pref setting) {
    if (setting == Pref.language) {
      _showLocales();
      return;
    }
    setting.setBool(!setting.getBool());

    // Handle music toggle switch
    if (setting == Pref.music) {
      var sounds = serviceLocator<Sounds>();
      if (setting.getBool()) {
        sounds.playMusic();
      } else {
        sounds.stopAll();
      }
    }
    setState(() {});
  }

  Widget _button(String title,
      {ButtonColor color = ButtonColor.teal, double? width}) {
    return SkinnedButton(
        width: width,
        color: color,
        icon: "icon_$title",
        label: "settings_$title".l(),
        margin: EdgeInsets.all(4.d),
        onPressed: () => _onButtonPressed(title));
  }

  Widget _buttons(List<String> titles) {
    return Row(children: [
      _button(titles[0], color: ButtonColor.teal),
      Expanded(child: _button(titles[1], color: ButtonColor.teal)),
    ]);
  }

  void _onButtonPressed(String title) {
    if (title == 'feedback' ||
        title == 'credits' ||
        title == 'web' ||
        title == 'instagram') {
      toast("coming_soon".l());
      return;
    }
    var route = switch (title) {
      "restore" => Routes.popupRestore,
      "invite" => Routes.popupInvite,
      _ => Routes.popupRedeemGift,
    };
    serviceLocator<RouteService>()
        .to(route);
  }

  void _showLocales() {
    showModalBottomSheet(
        context: context,
        backgroundColor: TColors.transparent,
        constraints: BoxConstraints.tightFor(height: 700.d),
        builder: (BuildContext context) {
          return Widgets.rect(
            decoration: BoxDecoration(
              color: TColors.primary90,
              border: Border.all(color: TColors.clay, width: 8.d),
              borderRadius: BorderRadius.vertical(top: Radius.circular(80.d)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(height: 20.d),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Asset.load<Image>("icon_language", height: 70.d),
                SizedBox(width: 20.d),
                Text("settings_language".l()),
              ]),
              SizedBox(height: 20.d),
              Expanded(
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(100.d)),
                      child: ListView.builder(
                          padding: EdgeInsets.all(12.d),
                          itemExtent: 240.d,
                          itemBuilder: (c, i) =>
                              _localeItemBuilder(Localization.locales[i]),
                          itemCount: Localization.locales.length))),
            ]),
          );
        });
  }

  Widget _localeItemBuilder(Locale local) {
    return Widgets.button(
      context,
      child: SkinnedText("settings_${local.languageCode}".l()),
      onPressed: () async {
        Pref.language.setString(local.languageCode);
        await serviceLocator<Localization>().changeLocal(local);
        Get.updateLocale(local);
        if (context.mounted) Get.back();
      },
    );
  }
}
