import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/data/core/building.dart';

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
      }
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [SizedBox(height: 150.d), _headerBuilder(tribe)]);
    });
  }

  Widget _headerBuilder(Tribe tribe) {
    var margin = 12.d;
    return Stack(children: [
      Positioned(
          top: margin,
          right: margin,
          left: margin,
          bottom: margin * 1.5,
          child: Widgets.rect(
              decoration: Widgets.imageDecore(
                  "tribe_header", ImageCenterSliceData(267, 256)))),
      Widgets.button(
        onPressed: () async {
          await Navigator.of(context)
              .pushNamed(Routes.popupTribeEdit.routeName);
          setState(() {});
        },
        padding: EdgeInsets.fromLTRB(48.d, 44.d, 48.d, 0),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Asset.load<Image>("tribe_icon", width: 120.d),
            SizedBox(width: 16.d),
            _informationBuilder(tribe),
            const Expanded(child: SizedBox()),
            _membersButtonBuilder(tribe),
          ]),
          SizedBox(height: 24.d),
          SizedBox(
              height: (tribe.description.length / 50).round() * 44.d,
              child: SkinnedText(tribe.description,
                  alignment: Alignment.centerLeft,
                  style: TStyles.medium.copyWith(height: 1.1))),
          SizedBox(height: 32.d),
          _upgradeLineBuilder(tribe)
        ]),
      )
    ]);
  }

  Widget _informationBuilder(Tribe tribe) {
    var name = tribe.name.substring(0, tribe.name.length.max(18));
    if (tribe.name.length > 18) {
      name += " ...";
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        SkinnedText(name, style: TStyles.large),
        SizedBox(width: 16.d),
        Widgets.rect(
            padding: EdgeInsets.all(10.d),
            decoration: Widgets.imageDecore(
                "ui_frame_inside", ImageCenterSliceData(42)),
            child: Asset.load<Image>("tribe_edit", width: 42.d))
      ]),
      Row(children: [
        _indicator("icon_score", tribe.weeklyRank.compact(), 100.d,
            EdgeInsets.only(right: 16.d)),
        SizedBox(width: 16.d),
        _indicator("icon_gold", tribe.gold.compact(), 100.d,
            EdgeInsets.only(right: 16.d)),
      ]),
    ]);
  }

  Widget _membersButtonBuilder(Tribe tribe) {
    return Widgets.button(
      width: 260.d,
      padding: EdgeInsets.zero,
      onPressed: () async {
        await Navigator.pushNamed(context, Routes.popupTribeOptions.routeName,
            arguments: {"index": 0});
        setState(() {});
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _indicator("icon_population",
            "${tribe.population}/${tribe.getOption(Buildings.base.id)}", 40.d),
        SizedBox(height: 8.d),
        _indicator("tribe_online", "2 onlines", 32.d),
      ]),
    );
  }

  Widget _upgradeLineBuilder(Tribe tribe) {
    return SizedBox(
        width: 840.d,
        height: 96.d,
        child: Row(
          children: [
            _upgradable(ButtonColor.wooden, "tribe_upgrade_1002",
                "${tribe.getOption(Buildings.offense.id)}%"),
            _upgradable(ButtonColor.wooden, "tribe_upgrade_1003",
                "${tribe.getOption(Buildings.defense.id)}%"),
            _upgradable(ButtonColor.wooden, "tribe_upgrade_1004",
                "${tribe.getOption(Buildings.cards.id)}%"),
            Expanded(
                child: _upgradable(
                    ButtonColor.green, "tribe_upgrade", "upgrade_l".l()))
          ],
        ));
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
      padding: EdgeInsets.fromLTRB(24.d, 0, 28.d, 20.d),
      color: color,
      size: ButtonSize.small,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Asset.load<Image>(icon, width: 50.d),
        SizedBox(width: 8.d),
        SkinnedText(label),
      ]),
      onPressed: () async {
        await Navigator.pushNamed(context, Routes.popupTribeOptions.routeName,
            arguments: {"index": 1});
        setState(() {});
      },
    );
  }
}
