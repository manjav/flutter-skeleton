import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/tribe.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/tribe_search_popup.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'page_item.dart';

class TribePageItem extends AbstractPageItem {
  const TribePageItem({super.key}) : super("battle");
  @override
  createState() => _TribePageItemState();
}

class _TribePageItemState extends AbstractPageItemState<TribePageItem> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var tribe = state.account.get<Tribe?>(AccountField.tribe);
      if (tribe == null) {
        return Column(children: [
          Expanded(child: TribeSearchPopup()),
          Widgets.skinnedButton(label: "tribe_new".l(), width: 380.d),
          SizedBox(height: 200.d),
        ]);
      } //
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(height: 180.d),
        Widgets.button(
            height: 368.d,
            margin: EdgeInsets.all(12.d),
            padding: EdgeInsets.fromLTRB(32.d, 22.d, 32.d, 0),
            decoration: Widgets.imageDecore(
                "tribe_header", ImageCenterSliceData(267, 256)),
            child: Stack(clipBehavior: Clip.none, children: [
              Asset.load<Image>("tribe_icon", width: 120.d),
              Positioned(
                  left: 150.d,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          SkinnedText(tribe.name, style: TStyles.large),
                          SizedBox(width: 16.d),
                          Widgets.rect(
                              padding: EdgeInsets.all(10.d),
                              decoration: Widgets.imageDecore(
                                  "ui_frame_inside", ImageCenterSliceData(42)),
                              child:
                                  Asset.load<Image>("tribe_edit", width: 42.d))
                        ]),
                        Row(children: [
                          _indicator("icon_score", tribe.weeklyRank.compact(),
                              100.d, EdgeInsets.only(right: 16.d)),
                          SizedBox(width: 16.d),
                          _indicator("icon_gold", tribe.gold.compact(), 100.d,
                              EdgeInsets.only(right: 16.d)),
                        ]),
                      ])),
              Positioned(
                  right: 0,
                  width: 250.d,
                  child: Widgets.touchable(
                      onTap: () => Navigator.pushNamed(
                          context, Routes.popupTribeMembers.routeName),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _indicator("icon_population",
                                "${tribe.population}/${tribe.capacity}", 40.d),
                            SizedBox(height: 8.d),
                            _indicator("tribe_online", "2 onlines", 32.d),
                          ]))),
              Positioned(
                  left: 40.d,
                  right: 40.d,
                  top: 160.d,
                  child: SkinnedText(tribe.description,
                      alignment: Alignment.centerLeft)),
              Positioned(
                  bottom: -16.d,
                  right: 76.d,
                  left: 76.d,
                  height: 96.d,
                  child: Row(
                    children: [
                      _upgradable(ButtonColor.wooden, "tribe_offense", "tribe"),
                      _upgradable(ButtonColor.wooden, "tribe_defense", "tribe"),
                      _upgradable(
                          ButtonColor.wooden, "tribe_cooldown", "tribe"),
                      Expanded(
                          child: _upgradable(ButtonColor.green, "tribe_upgrade",
                              "upgrade_l".l()))
                    ],
                  ))
            ]))
      ]);
    });
  }

  Widget _indicator(String icon, String label, double iconSize,
      [EdgeInsetsGeometry? padding]) {
    return Widgets.rect(
        height: 64.d,
        padding: padding ?? EdgeInsets.only(left: 16.d, right: 16.d),
        decoration:
            Widgets.imageDecore("ui_frame_inside", ImageCenterSliceData(42)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Asset.load<Image>(icon, height: iconSize),
          SizedBox(width: 12.d),
          SkinnedText(label)
        ]));
  }

  Widget _upgradable(ButtonColor color, String icon, String label) {
    return Widgets.skinnedButton(
        padding: EdgeInsets.fromLTRB(20.d, 0, 20.d, 20.d),
        color: color,
        size: ButtonSize.small,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Asset.load<Image>(icon, width: 50.d),
          SizedBox(width: 12.d),
          SkinnedText(label),
        ]));
  }
}
