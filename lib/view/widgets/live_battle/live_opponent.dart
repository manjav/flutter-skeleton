import 'package:flutter/widgets.dart';

import '../../../data/core/card.dart';
import '../../../data/core/ranking.dart';
import '../../../services/deviceinfo.dart';
import '../../../services/theme.dart';
import '../../../utils/assets.dart';
import '../../../utils/utils.dart';
import '../../widgets.dart';
import '../loaderwidget.dart';
import '../skinnedtext.dart';

class LiveOpponentView extends StatelessWidget {
  final bool isExpanded;
  final LiveOpponent opponent;
  const LiveOpponentView(this.opponent, {this.isExpanded = false, super.key});

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[_titleBuilder(opponent)];
    if (isExpanded) {
      items.addAll([
        SizedBox(height: 10.d),
        _rewardItemBuilder("icon_seed", opponent.score, "power", opponent),
        _rewardItemBuilder("icon_gold", opponent.gold, "gold", opponent),
        _rewardItemBuilder("icon_xp", opponent.xp, "cooldown", opponent)
      ]);
    }
    items.addAll([
      const Expanded(child: SizedBox()),
      SkinnedText(opponent.base.name),
    ]);
    return Widgets.rect(
        width: 400.d,
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(12.d, 12.d, 12.d, 0),
        decoration: Widgets.imageDecore("liveout_frame",
            ImageCenterSliceData(68, 92, const Rect.fromLTWH(32, 34, 4, 4))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, children: items));
  }

  Widget _titleBuilder(LiveOpponent opponent) {
    return SizedBox(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
      Widgets.rect(
          radius: 24.d,
          padding: EdgeInsets.all(6.d),
          color: TColors.black.withOpacity(0.3),
          child: LoaderWidget(
              AssetType.image, "avatar_${opponent.base.avatarId}",
              width: 88.d, height: 88.d, subFolder: "avatars")),
      SizedBox(width: 12.d),
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _usedCards(opponent),
            SkinnedText("ˢ${opponent.power.compact()}", style: TStyles.small)
          ])
    ]));
  }

  Widget _usedCards(LiveOpponent opponent) {
    var cards = opponent.cards.value;
    return SizedBox(
      height: 48.d,
      width: 112.d,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _usedCard(opponent.fraction, cards[0], -0.15, 0, 2.d),
          _usedCard(opponent.fraction, cards[1], -0.05, 16.d, 0),
          _usedCard(opponent.fraction, cards[4], 0.05, 37.d, 0),
          _usedCard(opponent.fraction, cards[2], 0.15, 60.d, 1.d),
          _usedCard(opponent.fraction, cards[3], 0.25, 86.d, 5.d),
        ],
      ),
    );
  }

  Widget _usedCard(OpponentSide fraction, AccountCard? card, double angle,
      double left, double top) {
    return Positioned(
        top: top,
        left: left,
        width: 32.d,
        child: Transform.rotate(
            angle: angle,
            child: Asset.load<Image>(
                "liveout_card_${card == null ? "missed" : fraction.name}")));
  }

  Widget _rewardItemBuilder(
      String icon, int value, String benefit, LiveOpponent opponent) {
    space(s) => SizedBox(width: s);
    format(int v) => benefit == "cooldown" ? v.toRemainingTime() : v.compact();

    return Row(mainAxisSize: MainAxisSize.min, children: [
      space(16.d),
      Asset.load<Image>(icon, width: 70.d, height: 78.d),
      space(10.d),
      SkinnedText(value.compact(), style: TStyles.small),
      const Expanded(child: SizedBox()),
      SkinnedText(format(opponent.heroBenefits[benefit]!),
          style: TStyles.small.copyWith(color: TColors.orange)),
      space(10.d),
      Asset.load<Image>("benefit_$benefit", width: 56.d),
      space(16.d),
    ]);
  }
}
