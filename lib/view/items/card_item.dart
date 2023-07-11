import 'package:flutter/material.dart';

import '../../data/core/card.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets/loaderwidget.dart';
import '../widgets/skinnedtext.dart';

class CardView extends StatefulWidget {
  final AccountCard card;
  final double size;
  const CardView(this.card, {this.size = 400, super.key});

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  static late TextStyle medium;
  static late TextStyle small;
  static late TextStyle tiny;
  @override
  Widget build(BuildContext context) {
    var baseCard = widget.card.base;
    var fruit = baseCard.get<FruitData>(CardFields.fruit);
    var level = baseCard.get<int>(CardFields.rarity).toString();
    var name = fruit.get<String>(FriutFields.name);

    var s = widget.size / 256;
    medium = TStyles.medium.copyWith(fontSize: 42 * s);
    small = TStyles.medium.copyWith(fontSize: 33 * s);
    tiny = TStyles.medium.copyWith(fontSize: 28 * s);

    return Stack(alignment: Alignment.center, children: [
      Asset.load<Image>('cards_frame_$level'),
      LoaderWidget(AssetType.image, baseCard.get<String>(CardFields.name),
          subFolder: "cards", width: 216 * s),
      Positioned(
          top: 4 * s,
          left: 22 * s,
          child: SkinnedText(name,
              style: TStyles.small.copyWith(
                  fontSize: (22 * s + 60 * s / (name.length))
                      .clamp(22 * s, 40 * s)))),
      Positioned(
          top: 2 * s,
          right: 24 * s,
          width: 27 * s,
          child: SkinnedText(level, style: medium)),
      Positioned(
          bottom: 6 * s,
          left: 22 * s,
          child: SkinnedText(widget.card.power.compact(), style: small)),
      Positioned(
          bottom: 6 * s,
          right: 20 * s,
          child: SkinnedText(
              baseCard.get<int>(CardFields.cooldown).toRemainingTime(),
              style: tiny)),
    ]);
  }
}
