import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../data/core/adam.dart';
import '../../../data/core/rpc.dart';
import '../../../mixins/service_provider.dart';
import '../../../services/deviceinfo.dart';
import '../../../utils/assets.dart';
import '../../../utils/utils.dart';
import '../../../view/widgets/indicator_level.dart';
import '../../../view/widgets/live_battle/live_opponent.dart';
import '../../../view/widgets/skinnedtext.dart';
import '../../widgets.dart';

class LiveTribe extends StatefulWidget {
  final int ownerId, battleId, helpCost;
  final Map<int, LiveOpponent> opponents;

  const LiveTribe(this.ownerId, this.battleId, this.helpCost, this.opponents,
      {super.key});

  @override
  State<LiveTribe> createState() => _LiveTribeState();
}

class _LiveTribeState extends State<LiveTribe>
    with TickerProviderStateMixin, ServiceProviderMixin {
  late Timer _timer;
  final double _helpTimeout = 38;
  late AnimationController _animationControler;
  bool _requestSent = false;

  @override
  void initState() {
    _animationControler = AnimationController(
        vsync: this, upperBound: _helpTimeout, value: _helpTimeout);
    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (t) {
      if (t.tick > _helpTimeout) {
        t.cancel();
        setState(() {});
      }
      _animationControler.animateTo(_helpTimeout - t.tick.toDouble(),
          curve: Curves.easeInOutSine, duration: duration);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var side = widget.opponents[widget.ownerId]!.fraction;
    var team = widget.opponents.values.where(
        (o) => o.fraction == side && o != widget.opponents[widget.ownerId]!);
    var items = <Widget>[
      LevelIndicator(
          size: 150.d,
          level: widget.opponents.values.first.base.level,
          xp: widget.opponents.values.first.base.score,
          avatarId: widget.opponents.values.first.base.avatarId),
      Widgets.divider(margin: 16.d, height: 56.d, direction: Axis.vertical)
    ];
    if (team.isEmpty && side == OpponentSide.allies) {
      items.add(_hornButton());
    }
    for (var opponent in team) {
      items.add(SizedBox(
          width: 260.d, height: 174.d, child: LiveOpponentView(opponent)));
    }
    return Positioned(
        top: side == OpponentSide.axis ? 0 : null,
        bottom: side == OpponentSide.allies ? 0 : null,
        height: 190.d,
        child: Widgets.rect(
            padding: EdgeInsets.symmetric(horizontal: 12.d),
            decoration: Widgets.imageDecore(
                "live_tribe_${side.name}", ImageCenterSliceData(101, 92)),
            child: Row(
                mainAxisAlignment: side == OpponentSide.axis
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: items)));
  }

  Widget _hornButton() {
    if (widget.helpCost == 0 || _requestSent) {
      return const SizedBox();
    }
    return Widgets.skinnedButton(
        width: 320.d,
        height: 150.d,
        isEnable: _timer.isActive,
        color: ButtonColor.teal,
        padding: EdgeInsets.fromLTRB(20.d, 0.d, 20.d, 8.d),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Asset.load<Image>("icon_horn", height: 76.d),
            SizedBox(width: 12.d),
            Widgets.rect(
                padding: EdgeInsets.symmetric(horizontal: 8.d),
                decoration: Widgets.imageDecore(
                    "frame_hatch_button", ImageCenterSliceData(42)),
                child: Row(children: [
                  Asset.load<Image>("icon_gold", height: 76.d),
                  SkinnedText(widget.helpCost.compact()),
                ]))
          ]),
          SizedBox(height: 12.d),
          AnimatedBuilder(
              animation: _animationControler,
              builder: (context, child) => Widgets.slider(
                  0, _animationControler.value, _helpTimeout,
                  width: 270.d,
                  height: 22.d,
                  border: 2,
                  radius: 10.d,
                  padding: 4.d))
        ]),
        onPressed: _help);
  }

  _help() async {
    if (!_timer.isActive) return;
    _requestSent = true;
    try {
      await rpc(RpcId.battleHelp,
          params: {RpcParams.battle_id.name: widget.battleId});
      _timer.cancel();
    } catch (e) {
      _requestSent = false;
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}
