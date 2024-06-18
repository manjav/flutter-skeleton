import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app_export.dart';

class LiveTribe extends StatefulWidget {
  final int ownerId, battleId, helpCost;
  final Warriors warriors;
  final bool isTutorial;

  const LiveTribe(this.ownerId, this.battleId, this.helpCost, this.warriors,
      {this.isTutorial = false, super.key});

  @override
  State<LiveTribe> createState() => _LiveTribeState();
}

class _LiveTribeState extends State<LiveTribe>
    with
        TickerProviderStateMixin,
        ServiceFinderWidgetMixin,
        ClassFinderWidgetMixin {
  Timer? _timer;
  final double _helpTimeout = 38;
  late AnimationController _animationController;
  bool _requestSent = false;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, upperBound: _helpTimeout, value: _helpTimeout);
    if (widget.isTutorial == false) {
      const duration = Duration(seconds: 1);
      _timer = Timer.periodic(duration, (t) {
        if (t.tick > _helpTimeout) {
          t.cancel();
          if (mounted) {
            setState(() {});
          }
        }
        _animationController.animateTo(_helpTimeout - t.tick.toDouble(),
            curve: Curves.easeInOutSine, duration: duration);
      });
    } else {
      _animationController.animateTo(30,
          curve: Curves.easeInOutSine, duration: 100.ms);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var owner = widget.warriors.value[widget.ownerId]!;
    var avatar = owner.side == WarriorSide.friends
        ? widget.warriors.value[accountProvider.account.id]!
        : owner;
    return Positioned(
      top: owner.side == WarriorSide.opposites ? 0 : null,
      bottom: owner.side == WarriorSide.friends ? 0 : null,
      height: 190.d,
      child: Widgets.rect(
        padding: EdgeInsets.symmetric(horizontal: 12.d),
        decoration: Widgets.imageDecorator(
            "live_tribe_${owner.side.name}", ImageCenterSliceData(101, 92)),
        child: ValueListenableBuilder(
            valueListenable: widget.warriors,
            builder: (context, value, child) {
              var team = value.values
                  .where((o) => owner.side == o.side && o != avatar);
              var items = <Widget>[
                LevelIndicator(
                    size: 150.d,
                    xp: avatar.base.score,
                    level: avatar.base.level,
                    avatarId: avatar.base.avatarId),
                Widgets.divider(
                    margin: 16.d, height: 56.d, direction: Axis.vertical),
                _hornButton(owner, team)
              ];

              for (var warrior in team) {
                items.add(SizedBox(
                    width: 260.d,
                    height: 174.d,
                    child: LiveWarriorView(warrior)));
              }
              return Row(
                  mainAxisAlignment: owner.side == WarriorSide.opposites
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: items);
            }),
      ),
    );
  }

  Widget _hornButton(LiveWarrior owner, Iterable<LiveWarrior> team) {
    if (!widget.isTutorial &&
        (!owner.base.itsMe ||
            owner.base.tribeId <= 0 ||
            _requestSent ||
            team.isNotEmpty)) {
      return const SizedBox();
    }
    return SkinnedButton(
        width: 320.d,
        height: 150.d,
        isEnable: widget.isTutorial || (_timer != null && _timer!.isActive),
        color: ButtonColor.teal,
        padding: EdgeInsets.fromLTRB(20.d, 0.d, 20.d, 8.d),
        onPressed: _help,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Asset.load<Image>("icon_horn", height: 76.d),
            SizedBox(width: 12.d),
            Widgets.rect(
                padding: EdgeInsets.symmetric(horizontal: 8.d),
                decoration: Widgets.imageDecorator(
                    "frame_hatch_button", ImageCenterSliceData(42)),
                child: Row(children: [
                  Asset.load<Image>("icon_gold", height: 76.d),
                  SkinnedText(widget.helpCost.compact()),
                ]))
          ]),
          SizedBox(height: 12.d),
          AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Widgets.slider(
                  0, _animationController.value, _helpTimeout,
                  width: 270.d,
                  height: 22.d,
                  border: 2,
                  radius: 10.d,
                  padding: 4.d))
        ]));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  _help() async {
    if (widget.isTutorial) {
      setState(() {
        _requestSent = true;
      });
      return;
    }
    if (_timer == null) return;
    if (!_timer!.isActive) return;
    _requestSent = true;
    try {
      await rpc(RpcId.battleHelp,
          params: {RpcParams.battle_id.name: widget.battleId});
      _timer?.cancel();
    } catch (e) {
      _requestSent = false;
    }
    setState(() {});
  }
}