import 'package:flutter/cupertino.dart';

import '../../app_export.dart';

class TribeDetailsPopup extends AbstractPopup {
  const TribeDetailsPopup({super.key}) : super(Routes.popupTribeOptions);

  @override
  createState() => _TribeDetailsPopupState();
}

class _TribeDetailsPopupState extends AbstractPopupState<TribeDetailsPopup>
    with TabBuilderMixin {
  Opponent? _member;
  late Account _account;
  @override
  void initState() {
    selectedTabIndex = widget.args["index"] ?? 0;
    _account = accountProvider.account;
    var index =
        _account.tribe!.members.value.indexWhere((member) => member.itsMe);
    if (index > -1) {
      _member = _account.tribe!.members.value[index];
    } else {
      _member = Opponent.initialize({"id": _account.id}, _account.id);
    }

    super.initState();
  }

  @override
  Widget contentFactory() {
    var tabCount = _member?.tribePosition.index == 1 ? 2 : 3;
    return SizedBox(
        height: 1380.d,
        child: Column(children: [
          tabsBuilder(data: [
            for (var i = 0; i < tabCount; i++)
              TabData("tribe_option_$i".l(),
                  ["icon_population", "tribe_upgrade", "tribe_edit"][i])
          ]),
          SizedBox(height: 30.d),
          Expanded(child: _getSelectedPage(_account.tribe!))
        ]));
  }

  Widget _getSelectedPage(Tribe tribe) {
    return switch (selectedTabIndex) {
      0 => _membersBuilder(tribe),
      1 => _upgradeBuilder(tribe),
      _ => const EditTribe()
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
        _indicator(
            "icon_population",
            " ${tribe.population}/${tribe.getOption(Buildings.tribe.id)} ",
            40.d),
      ]),
      SizedBox(height: 20.d),
      SkinnedButton(
          color: ButtonColor.teal,
          label: "tribe_invite".l(),
          icon: "tribe_invite",
          onPressed: () =>
              serviceLocator<RouteService>().to(Routes.popupTribeInvite)),
      SizedBox(height: 20.d),
      Expanded(
          child: FutureBuilder(
        future: tribe.loadMembers(context, _account),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox();
          }
          return ListView.builder(
              itemCount: tribe.members.value.length,
              itemBuilder: (c, i) =>
                  _memberItemBuilder(tribe, tribe.members.value[i], i));
        },
      )),
    ]);
  }

  Widget? _memberItemBuilder(Tribe tribe, Opponent member, int index) {
    return Widgets.button(context,
        height: 144.d,
        margin: EdgeInsets.all(2.d),
        padding: EdgeInsets.fromLTRB(20.d, 0, 22.d, 10.d),
        decoration: Widgets.imageDecorator(
            "iconed_item_bg${member.itsMe ? "_selected" : ""}",
            ImageCenterSliceData(132, 68, const Rect.fromLTWH(100, 30, 2, 2))),
        child: Row(textDirection: TextDirection.ltr, children: [
          SizedBox(width: 70.d, child: SkinnedText("${index + 1}")),
          SizedBox(width: 12.d),
          Widgets.rect(
              radius: 48.d,
              width: 90.d,
              height: 90.d,
              padding: EdgeInsets.all(6.d),
              decoration: Widgets.imageDecorator(
                  "frame_hatch_button", ImageCenterSliceData(42)),
              child: LoaderWidget(AssetType.image, "avatar_${member.avatarId}",
                  width: 76.d, height: 76.d, subFolder: "avatars")),
          SizedBox(width: 20.d),
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(textDirection: TextDirection.ltr, children: [
                  member.status == 1
                      ? Asset.load<Image>("tribe_online", height: 32.d)
                      : const SizedBox(),
                  SizedBox(width: member.status == 1 ? 12.d : 0),
                  SkinnedText(member.name,
                      style: TStyles.medium.copyWith(height: 1.1)),
                ]),
                SizedBox(height: 8.d),
                Row(textDirection: TextDirection.ltr, children: [
                  member.tribePosition.index < 2
                      ? const SizedBox()
                      : Asset.load<Image>(
                          "position_${member.tribePosition.index}",
                          height: 40.d),
                  SizedBox(width: member.tribePosition.index < 2 ? 0 : 12.d),
                  Text("tribe_degree_${member.tribePosition.index}".l(),
                      style: TStyles.small)
                ]),
              ]),
          const Expanded(child: SizedBox()),
          _indicator("icon_xp", member.xp.compact(), 60.d,
              EdgeInsets.only(right: 16.d)),
        ]), onTapUp: (details) {
      Overlays.insert(
          context,
          MemberOverlay(
            member,
            tribe.members.value.firstWhere((m) => m.itsMe),
            details.globalPosition.dy - 220.d,
            onClose: (data) {
              setState(() {});
            },
          ));
    });
  }

  Widget _indicator(String icon, String label, double iconSize,
      [EdgeInsetsGeometry? padding]) {
    return Widgets.rect(
        height: 64.d,
        padding: padding ?? EdgeInsets.only(left: 16.d, right: 16.d),
        decoration: Widgets.imageDecorator(
            "frame_hatch_button", ImageCenterSliceData(42)),
        child: Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
        Row(
          textDirection: Localization.textDirection,
          children: [
            SkinnedText("tribe_gold".l(), style: TStyles.large),
            SizedBox(width: 4.d),
            Asset.load<Image>("icon_gold", width: 70.d),
            SizedBox(width: 4.d),
            SkinnedText(tribe.gold.compact(), style: TStyles.large),
          ],
        ),
        const Expanded(child: SizedBox()),
        SkinnedButton(
            label: "tribe_donate".l(),
            padding: EdgeInsets.fromLTRB(44.d, 10.d, 44.d, 32.d),
            onPressed: () async {
              await serviceLocator<RouteService>().to(Routes.popupTribeDonate);
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
                top: -90.d,
                child: Asset.load<Image>("upgrade_$id",
                    width: 220.d, height: 180.d)),
            Positioned(
                top: 80.d,
                child: SkinnedText("upgrade_t_$id".l(), style: TStyles.large)),
            Positioned(
                top: 160.d,
                width: 400.d,
                child: Text("upgrade_d_$id".l([tribe.getOption(id).convert()]),
                    textAlign: TextAlign.center,
                    style: TStyles.medium.copyWith(height: 1))),
            Positioned(
                bottom: 0, right: 0, left: 0, child: _upgradeButton(tribe, id))
          ]),
    );
  }

  Widget _upgradeButton(Tribe tribe, int id) {
    if (tribe.levels[id]! >= Building.get_maxLevel(id.toBuildings())) {
      return Column(children: [
        Asset.load<Image>("tick", height: 70.d),
        SizedBox(height: 10.d),
        SkinnedText("max_level".l(["upgrade_t_$id".l()]),
            style: TStyles.medium.copyWith(height: 1),
            textAlign: TextAlign.center),
        SizedBox(height: 10.d),
      ]);
    }
    var cost = tribe.getOptionCost(id);
    var newBenefit = tribe.getOption(id, tribe.levels[id]! + 1);
    return SkinnedButton(
      height: 150.d,
      color: ButtonColor.green,
      padding: EdgeInsets.fromLTRB(28.d, 18.d, 22.d, 28.d),
      isEnable: cost <= tribe.gold,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SkinnedText("tribe_upgrade".l(),
              style: TStyles.small.copyWith(height: 3.d)),
          Expanded(
            child: SkinnedText(
                "$newBenefit${id == Buildings.tribe.id ? "ˡ" : "%"}".convert(),
                style: TStyles.large.copyWith(height: 3.5.d)),
          ),
        ]),
        SizedBox(width: 20.d),
        Widgets.rect(
          padding: EdgeInsets.fromLTRB(0, 2.d, 10.d, 2.d),
          decoration: Widgets.imageDecorator(
              "frame_hatch_button", ImageCenterSliceData(42)),
          child: Row(textDirection: TextDirection.ltr, children: [
            Asset.load<Image>("icon_gold", height: 76.d),
            SkinnedText(cost.compact(),
                style: TStyles.large.copyWith(height: 1)),
          ]),
        )
      ]),
      onPressed: () => Overlays.insert(
          context,
          UpgradeFeastOverlay(
            args: {"id": id, "tribe": tribe},
            onClose: (data) => setState(() {}),
          )),
      onDisablePressed: () {
        var message = cost > tribe.gold
            ? "error_227".l()
            : "max_level".l(["tribe_upgrade_t_$id".l()]);
        Overlays.insert(context, ToastOverlay(message));
      },
    );
  }
}
