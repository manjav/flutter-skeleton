import 'package:flutter/widgets.dart';

import '../../../app_export.dart';


class LiveWarriorView extends StatelessWidget {
  final bool isExpanded;
  final LiveWarrior warrior;
  const LiveWarriorView(this.warrior, {this.isExpanded = false, super.key});

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[_titleBuilder(warrior)];
    if (isExpanded) {
      items.addAll([
        SizedBox(height: 10.d),
        _rewardItemBuilder("icon_seed", warrior.score, "power", warrior),
        _rewardItemBuilder("icon_gold", warrior.gold, "gold", warrior),
        _rewardItemBuilder("icon_xp", warrior.xp, "cooldown", warrior)
      ]);
    }
    items.addAll([
      const Expanded(child: SizedBox()),
      SkinnedText(warrior.base.name, overflow: TextOverflow.ellipsis),
    ]);
    return Widgets.rect(
        width: 400.d,
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(12.d, 12.d, 12.d, 0),
        decoration: Widgets.imageDecorator("liveout_frame",
            ImageCenterSliceData(68, 92, const Rect.fromLTWH(32, 34, 4, 4))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, children: items));
  }

  Widget _titleBuilder(LiveWarrior warrior) {
    return SizedBox(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
      Widgets.rect(
          radius: 24.d,
          padding: EdgeInsets.all(6.d),
          color: TColors.black.withOpacity(0.3),
          child: LoaderWidget(
              AssetType.image, "avatar_${warrior.base.avatarId}",
              width: 88.d, height: 88.d, subFolder: "avatars")),
      SizedBox(width: 12.d),
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _usedCards(warrior),
            SkinnedText("ˢ${warrior.power.compact()}", style: TStyles.small)
          ])
    ]));
  }

  Widget _usedCards(LiveWarrior warrior) {
    var cards = warrior.cards.value;
    return SizedBox(
      height: 48.d,
      width: 112.d,
      child: ValueListenableBuilder(
        valueListenable: warrior.cards,
        builder: (context, value, child) =>
            Stack(clipBehavior: Clip.none, children: [
          _usedCard(warrior.side, cards[0], -0.15, 0, 2.d),
          _usedCard(warrior.side, cards[1], -0.05, 16.d, 0),
          _usedCard(warrior.side, cards[4], 0.05, 37.d, 0),
          _usedCard(warrior.side, cards[2], 0.15, 60.d, 1.d),
          _usedCard(warrior.side, cards[3], 0.25, 86.d, 5.d),
        ]),
      ),
    );
  }

  Widget _usedCard(WarriorSide fraction, AccountCard? card, double angle,
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
      String icon, int value, String benefit, LiveWarrior opponent) {
    space(s) => SizedBox(width: s);
    format(int v) => benefit == "cooldown" ? v.toRemainingTime() : v.compact();

    return Row(mainAxisSize: MainAxisSize.min, children: [
      space(16.d),
      Asset.load<Image>(icon, width: 70.d, height: 78.d),
      space(10.d),
      SkinnedText(value.compact(),
          style: TStyles.small, textDirection: TextDirection.ltr),
      const Expanded(child: SizedBox()),
      SkinnedText(format(opponent.heroBenefits[benefit]!),
          style: TStyles.small.copyWith(color: TColors.orange)),
      space(10.d),
      Asset.load<Image>("benefit_$benefit", width: 56.d),
      space(16.d),
    ]);
  }
}
