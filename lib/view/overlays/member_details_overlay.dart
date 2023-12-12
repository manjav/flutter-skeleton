import 'package:flutter/material.dart';
import '../../view/route_provider.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/adam.dart';
import '../../data/core/infra.dart';
import '../../data/core/rpc.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/widgets.dart';
import '../../view/widgets/indicator.dart';
import '../../view/widgets/indicator_level.dart';
import '../../view/widgets/skinnedtext.dart';
import 'ioverlay.dart';

class MemberOverlay extends AbstractOverlay {
  final double y;
  final Opponent member, me;
  const MemberOverlay(this.member, this.me, this.y, {super.key})
      : super(type: OverlayType.member);

  @override
  createState() => _MemberOverlayState();
}

class _MemberOverlayState extends AbstractOverlayState<MemberOverlay> {
  @override
  Widget build(BuildContext context) {
    var member = widget.member;
    var buttons = <RpcId, ButtonColor>{};
    if (!member.itsMe) {
      buttons[RpcId.getProfileInfo] = ButtonColor.teal;
      buttons[RpcId.tribePoke] = ButtonColor.green;
    }
    if (!member.itsMe &&
        member.tribePosition.index < widget.me.tribePosition.index) {
      buttons[widget.member.tribePosition == TribePosition.member
          ? RpcId.tribePromote
          : RpcId.tribeDemote] = ButtonColor.green;
      buttons[RpcId.tribeKick] = ButtonColor.yellow;
    }
    if (member.itsMe) {
      buttons[RpcId.tribeLeave] = ButtonColor.yellow;
    }
    var items = buttons.entries.toList();
    return Material(
        color: TColors.transparent,
        child: Widgets.button(
            child: Stack(children: [
              PositionedDirectional(
                  top: widget.y,
                  start: 240.d,
                  width: 680.d,
                  height: 192.d + (items.length / 2).ceil() * 125.d,
                  child: Widgets.rect(
                    padding: EdgeInsets.fromLTRB(16.d, 16.d, 16.d, 32.d),
                    decoration: Widgets.imageDecore(
                        "tribe_item_bg", ImageCenterSliceData(56)),
                    child: Column(children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            LevelIndicator(
                                size: 120.d,
                                xp: member.xp,
                                level: member.level,
                                avatarId: member.avatarId),
                            SizedBox(
                                width: 240.d,
                                child: SkinnedText(member.name,
                                    overflow: TextOverflow.ellipsis)),
                            const Expanded(child: SizedBox()),
                            Transform.scale(
                                scale: 0.7,
                                child: Indicator("member", Values.leagueRank,
                                    value: member.leagueRank,
                                    data: member.leagueId,
                                    hasPlusIcon: false,
                                    width: 240.d))
                          ]),
                      Expanded(
                          child: GridView.builder(
                              itemCount: items.length,
                              padding: EdgeInsets.only(top: 22.d),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 2.5, crossAxisCount: 2),
                              itemBuilder: (c, i) =>
                                  _button(items[i].key, items[i].value))),
                    ]),
                  ))
            ]),
            onPressed: close));
  }

  Widget _button(RpcId id, ButtonColor color) {
    if (id == RpcId.none) {
      return const SizedBox();
    }
    return Widgets.skinnedButton(
        padding: EdgeInsets.only(bottom: 20.d),
        color: color,
        label: "${id.name.toLowerCase()}_l".l(),
        onPressed: () => _onButtonsPressed(id));
  }

  _onButtonsPressed(RpcId id) async {
    var bloc = accountBloc;
    if (id == RpcId.getProfileInfo) {
      Navigator.pushNamed(context, Routes.popupProfile.routeName,
          arguments: {"id": widget.member.id});
      close();
      return;
    }
    try {
      await rpc(id, params: {
        RpcParams.tribe_id.name: bloc.account!.tribe!.id,
        RpcParams.member_id.name: widget.member.id,
      });
      if (id == RpcId.tribePoke) toast("tribe_poke_success".l());
      if (mounted && id == RpcId.tribeLeave) {
        bloc.account!.tribe = null;
        bloc.add(SetAccount(account: bloc.account!));
        Navigator.pop(context);
      }
      close();
    } finally {}
  }
}
