import 'package:flutter/material.dart';

import '../../data/core/card.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets/loaderwidget.dart';
import '../widgets/skinnedtext.dart';

class MinimalCardItem extends StatefulWidget {
  final AccountCard card;
  final double size;
  final int extraPower;
  const MinimalCardItem(this.card,
      {this.size = 400, this.extraPower = 0, super.key});

  @override
  State<MinimalCardItem> createState() => _MinimalCardItemState();
}

class _MinimalCardItemState extends State<MinimalCardItem> {
  TextStyle? _style;

  @override
  Widget build(BuildContext context) {
    var baseCard = widget.card.base;
    var level = baseCard.get<int>(CardFields.rarity).toString();
    var name =
        baseCard.get<FruitData>(CardFields.fruit).get<String>(FriutFields.name);

    var s = widget.size / 256;
    _style ??= TStyles.medium.copyWith(fontSize: 36 * s);

    return Stack(alignment: Alignment.center, children: [
      Asset.load<Image>('cards_frame_$level'),
      LoaderWidget(AssetType.image, baseCard.get<String>(CardFields.name),
          subFolder: "cards", width: 216 * s),
      Positioned(
          top: 4 * s,
          left: 22 * s,
          child: SkinnedText(name,
              style: _style!.copyWith(
                  fontSize: (22 * s + 60 * s / (name.length))
                      .clamp(22 * s, 40 * s)))),
      Positioned(
          top: 1 * s,
          right: 20 * s,
          width: 27 * s,
          child: SkinnedText(level, style: _style)),
      Positioned(
          bottom: 16 * s,
          left: 22 * s,
          child: Row(
            children: [
              SkinnedText(widget.card.power.compact(), style: _style),
              widget.extraPower > 0
                  ? SkinnedText("+${widget.extraPower.compact()}",
                      style: _style!.copyWith(color: TColors.orange))
                  : const SizedBox(),
            ],
          ))
    ]);
  }
}