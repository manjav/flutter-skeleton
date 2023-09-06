import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_skeleton/utils/utils.dart';

import '../../../data/core/ranking.dart';
import '../../../services/deviceinfo.dart';
import '../../../utils/assets.dart';
import '../../../view/widgets/indicator_level.dart';
import '../../../view/widgets/live_battle/live_opponent.dart';
import '../../../view/widgets/skinnedtext.dart';
import '../../widgets.dart';

class LiveTribe extends StatefulWidget {
  final int ownerId, helpCost;
  final Map<int, LiveOpponent> opponents;

  const LiveTribe(this.ownerId, this.opponents, this.helpCost, {super.key});

  @override
  State<LiveTribe> createState() => _LiveTribeState();
}

class _LiveTribeState extends State<LiveTribe> with TickerProviderStateMixin {
  final double _helpTimeout = 38;
  late Timer _timer;
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
    if (_requestSent) {
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
                    "ui_frame_inside", ImageCenterSliceData(42, 42)),
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

  _help() {
    if (!_timer.isActive) return;
    _timer.cancel();
    _requestSent = true;
  }
}
