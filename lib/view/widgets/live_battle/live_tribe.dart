import 'package:flutter/widgets.dart';
import 'package:flutter_skeleton/utils/utils.dart';

import '../../../data/core/ranking.dart';
import '../../../services/deviceinfo.dart';
import '../../../utils/assets.dart';
import '../../../view/widgets/indicator_level.dart';
import '../../../view/widgets/live_battle/live_opponent.dart';
import '../../../view/widgets/skinnedtext.dart';
import '../../widgets.dart';

class LiveTribe extends StatelessWidget {
  final int ownerId, helpCost;
  final double _helpTimeout = 37;
  final Map<int, LiveOpponent> opponents;

  const LiveTribe(this.ownerId, this.opponents, this.helpCost, {super.key});

  @override
  Widget build(BuildContext context) {
    var side = opponents[ownerId]!.fraction;
    var team = opponents.values
        .where((o) => o.fraction == side && o != opponents[ownerId]!);
    var items = <Widget>[
      LevelIndicator(
          size: 150.d,
          level: opponents.values.first.base.level,
          xp: opponents.values.first.base.score,
          avatarId: opponents.values.first.base.avatarId),
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
    return Widgets.skinnedButton(
        width: 320.d,
        height: 150.d,
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
                  SkinnedText(helpCost.compact()),
                ]))
          ]),
          SizedBox(height: 12.d),
          Widgets.slider(0, 13.0, _helpTimeout,
              width: 270.d, height: 22.d, border: 2, radius: 10.d, padding: 4.d)
        ]),
        onPressed: _help);
  }

  _help() {}
}
