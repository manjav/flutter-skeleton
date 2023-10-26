import 'package:flutter/cupertino.dart';

import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../data/core/adam.dart';
import '../../data/core/rpc.dart';
import '../../data/core/tribe.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../../view/tab_provider.dart';
import '../../view/widgets/skinnedtext.dart';
import '../overlays/ioverlay.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/loaderwidget.dart';

class TribeOptionsPopup extends AbstractPopup {
  const TribeOptionsPopup({required super.args, super.key})
      : super(Routes.popupTribeOptions);

  @override
  createState() => _TribeMembersPopupState();
}

class _TribeMembersPopupState extends AbstractPopupState<TribeOptionsPopup>
    with TabProviderMixin {
  Member? _member;
  late Account _account;
  @override
  void initState() {
    selectedTabIndex = widget.args["index"] ?? 0;
    _account = accountBloc.account!;
    var index = _account.tribe!.members.indexWhere((member) => member.itsMe);
    if (index > -1) {
      _member = _account.tribe!.members[index];
    } else {
      _member = Member.initialize({"id": _account.id}, _account.id);
    }

    super.initState();
  }

  @override
  Widget contentFactory() {
    return SizedBox(
        height: 1380.d,
        child: Column(children: [
          tabsBuilder(data: [
            for (var i = 0; i < 2; i++)
              TabData("tribe_option_$i".l(),
                  ["icon_population", "tribe_upgrade"][i])
          ]),
          SizedBox(height: 30.d),
          Expanded(child: _getSelectedPage(_account.tribe!))
        ]));
  }

  Widget _getSelectedPage(Tribe tribe) {
    return switch (selectedTabIndex) {
      0 => _membersBuilder(tribe),
      _ => _upgradeBuilder(tribe)
    };
  }

  Widget _membersBuilder(Tribe tribe) {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      Row(children: [
        CupertinoSwitch(
            value: _member?.status == 1, onChanged: _changeVisibility),
        Asset.load<Image>("tribe_visibility", width: 44.d),
        SizedBox(width: 12.d),
        Text("tribe_visibility".l()),
        const Expanded(child: SizedBox()),
        _indicator("icon_population",
            "${tribe.population}/${tribe.getOption(Buildings.base.id)}", 40.d),
      ]),
      SizedBox(height: 20.d),
      Widgets.skinnedButton(
          color: ButtonColor.teal,
          label: "tribe_invite".l(),
          icon: "tribe_invite",
          onPressed: () => Navigator.of(context)
              .pushNamed(Routes.popupTribeInvite.routeName)),
      SizedBox(height: 20.d),
      Expanded(
          child: ListView.builder(
              itemCount: tribe.members.length,
              itemBuilder: (c, i) =>
                  _listItemBuilder(tribe, tribe.members[i], i))),
    ]);
  }

  Widget? _listItemBuilder(Tribe tribe, Member member, int index) {
    return Widgets.button(
        height: 120.d,
        margin: EdgeInsets.all(4.d),
        padding: EdgeInsets.fromLTRB(20.d, 0, 22.d, 10.d),
        decoration: Widgets.imageDecore(
            "tribe_member_bg${member.itsMe ? "_me" : ""}",
            ImageCenterSliceData(132, 68, const Rect.fromLTWH(100, 30, 2, 2))),
        child: Row(
          children: [
            SizedBox(width: 70.d, child: SkinnedText("${index + 1}")),
            SizedBox(width: 12.d),
            Widgets.rect(
                radius: 48.d,
                width: 90.d,
                height: 90.d,
                padding: EdgeInsets.all(6.d),
                decoration: Widgets.imageDecore(
                    "frame_hatch_button", ImageCenterSliceData(42)),
                child: LoaderWidget(
                    AssetType.image, "avatar_${member.avatarId + 1}",
                    width: 76.d, height: 76.d, subFolder: "avatars")),
            SizedBox(width: 20.d),
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    member.status == 1
                        ? Asset.load<Image>("tribe_online", height: 32.d)
                        : const SizedBox(),
                    SizedBox(width: member.status == 1 ? 12.d : 0),
                    SkinnedText(member.name,
                        style: TStyles.medium.copyWith(height: 1.1)),
                  ]),
                  Text("tribe_degree_${member.degree.index}".l(),
                      style: TStyles.small),
                ]),
            const Expanded(child: SizedBox()),
            _indicator("icon_xp", member.xp.compact(), 60.d,
                EdgeInsets.only(right: 16.d)),
          ],
        ),
        onTapUp: (details) {
          Overlays.insert(context, OverlayType.member, args: [
            member,
            tribe.members.firstWhere((m) => m.itsMe),
            details.globalPosition.dy - 220.d
          ]);
        });
  }

  Widget _indicator(String icon, String label, double iconSize,
      [EdgeInsetsGeometry? padding]) {
    return Widgets.rect(
        height: 64.d,
        padding: padding ?? EdgeInsets.only(left: 16.d, right: 16.d),
        decoration:
            Widgets.imageDecore("frame_hatch_button", ImageCenterSliceData(42)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Asset.load<Image>(icon, height: iconSize),
          SizedBox(width: 2.d),
          SkinnedText(label)
        ]));
  }

  void _changeVisibility(bool value) {
    var newStatus = value ? 1 : 3;
    try {
      rpc(RpcId.tribeVisibility, params: {RpcParams.status.name: newStatus});
      setState(() => _member!.status = newStatus);
    } finally {}
  }

  Widget _upgradeBuilder(Tribe tribe) {
    return Column(children: [
      Row(children: [
        SkinnedText("tribe_gold".l(), style: TStyles.large),
        SizedBox(width: 4.d),
        Asset.load<Image>("icon_gold", width: 70.d),
        SizedBox(width: 4.d),
        SkinnedText(tribe.gold.compact(), style: TStyles.large),
        const Expanded(child: SizedBox()),
        Widgets.skinnedButton(
            label: "tribe_donate".l(),
            padding: EdgeInsets.fromLTRB(44.d, 10.d, 44.d, 32.d),
            onPressed: () async {
              await Navigator.pushNamed(
                  context, Routes.popupTribeDonate.routeName);
              setState(() {});
            })
      ]),
      Widgets.divider(width: 900.d, margin: 8.d),
      Expanded(
          child: GridView.builder(
              itemCount: 4,
              padding: EdgeInsets.only(top: 50.d),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.86, crossAxisCount: 2),
              itemBuilder: (c, i) => _upgradeItemBuilder(tribe, 1002 + i))),
    ]);
  }

  Widget? _upgradeItemBuilder(Tribe tribe, int id) {
    return Widgets.rect(
      radius: 32.d,
      color: TColors.primary90,
      padding: EdgeInsets.all(10.d),
      margin: EdgeInsets.symmetric(horizontal: 8.d, vertical: 40.d),
      child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
                top: -80.d,
                child: Asset.load<Image>("tribe_upgrade_$id",
                    width: 220.d, height: 180.d)),
            Positioned(
                top: 90.d,
                child: SkinnedText("tribe_upgrade_t_$id".l(),
                    style: TStyles.large)),
            Positioned(
                top: 170.d,
                width: 400.d,
                child: Text("tribe_upgrade_d_$id".l([tribe.getOption(id)]),
                    textAlign: TextAlign.center,
                    style: TStyles.medium.copyWith(height: 1))),
            Positioned(
                bottom: 0,
                right: 8.d,
                left: 8.d,
                child: _upgradeButton(tribe, id))
          ]),
    );
  }

  Widget _upgradeButton(Tribe tribe, int id) {
    if (tribe.levels[id]! >= Building.get_maxLevel(id.toBuildings())) {
      return SkinnedText("max_level".l(["tribe_upgrade_t_$id".l()]),
          textAlign: TextAlign.center);
    }
    var cost = tribe.getOptionCost(id);
    var newBenefit = tribe.getOption(id, tribe.levels[id]! + 1);
    return Widgets.skinnedButton(
      height: 150.d,
      color: ButtonColor.green,
      padding: EdgeInsets.fromLTRB(28.d, 18.d, 22.d, 28.d),
      isEnable: cost <= tribe.gold,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SkinnedText("tribe_upgarde".l(),
              style: TStyles.small.copyWith(height: 3.d)),
          SkinnedText("$newBenefit${id == Buildings.base.id ? "ˡ" : "%"}",
              style: TStyles.large.copyWith(height: 3.5.d)),
        ]),
        SizedBox(width: 20.d),
        Widgets.rect(
          padding: EdgeInsets.fromLTRB(0, 2.d, 10.d, 2.d),
          decoration: Widgets.imageDecore(
              "frame_hatch_button", ImageCenterSliceData(42)),
          child: Row(children: [
            Asset.load<Image>("icon_gold", height: 76.d),
            SkinnedText(cost.compact(),
                style: TStyles.large.copyWith(height: 1)),
          ]),
        )
      ]),
      onPressed: () => _upgrade(id, tribe),
      onDisablePressed: () {
        var message = cost > tribe.gold
            ? "error_227".l()
            : "max_level".l(["tribe_upgrade_t_$id".l()]);
        Overlays.insert(context, OverlayType.toast, args: message);
      },
    );
  }

  _upgrade(int id, Tribe tribe) async {
    try {
      var result = await rpc(RpcId.tribeUpgrade, params: {
        RpcParams.tribe_id.name: tribe.id,
        RpcParams.type.name: id,
      });
      _account.update(result);
      _account.buildings[id.toBuildings()]!.map['level']++;
      tribe.levels[id] = tribe.levels[id]! + 1;
      setState(() {});
    } finally {}
  }
}
