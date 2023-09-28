import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/ranking.dart';
import '../../data/core/rpc.dart';
import '../../data/core/tribe.dart';
import '../../services/connection/http_connection.dart';
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
  final Member member, me;
  const MemberOverlay(this.member, this.me, this.y, {super.key})
      : super(type: OverlayType.member);

  @override
  createState() => _MemberOverlayState();
}

class _MemberOverlayState extends AbstractOverlayState<MemberOverlay> {
  @override
  Widget build(BuildContext context) {
    var member = widget.member;
    var buttons = <RpcId, ButtonColor>{RpcId.none: ButtonColor.gray};
    if (!member.itsMe) {
      buttons[RpcId.tribePoke] = ButtonColor.green;
    }
    if (!member.itsMe && member.degree < widget.me.degree) {
      buttons[widget.me.degree - member.degree > 1
          ? RpcId.tribePromote
          : RpcId.tribeDemote] = ButtonColor.teal;
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
              Positioned(
                  top: widget.y,
                  left: 240.d,
                  width: 640.d,
                  height: 182.d + (items.length / 2).ceil() * 116.d,
                  child: Widgets.rect(
                    padding: EdgeInsets.fromLTRB(16.d, 16.d, 16.d, 32.d),
                    decoration: Widgets.imageDecore(
                        "tribe_item_bg", ImageCenterSliceData(56)),
                    child: Column(children: [
                      Row(children: [
                        LevelIndicator(
                            size: 100.d,
                            xp: member.xp,
                            level: member.level,
                            avatarId: member.avatarId),
                        SizedBox(width: 16.d),
                        SizedBox(
                            width: 240.d,
                            child: SkinnedText(member.name,
                                overflow: TextOverflow.ellipsis)),
                        const Expanded(child: SizedBox()),
                        Transform.scale(
                            scale: 0.7,
                            child: Indicator("member", AccountField.league_rank,
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
        label: "${id.name.substring(5).toLowerCase()}_l".l(),
        onPressed: () => _onButtonsPressed(id));
  }

  _onButtonsPressed(RpcId id) async {
    var bloc = BlocProvider.of<AccountBloc>(context);
    var tribe = bloc.account!.get<Tribe>(AccountField.tribe);
    try {
      await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, id, params: {
        RpcParams.tribe_id.name: tribe.id,
        RpcParams.member_id.name: widget.member.id,
      });
      if (mounted && id == RpcId.tribeLeave) {
        bloc.account!.map["tribe"] = null;
        bloc.add(SetAccount(account: bloc.account!));
        Navigator.pop(context);
      }
      close();
    } finally {}
  }
}