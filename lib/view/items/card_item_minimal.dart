import 'package:flutter/material.dart';

import '../../data/core/card.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets/loaderwidget.dart';
import '../widgets/skinnedtext.dart';

class MinimalCardItem extends StatefulWidget {
  final AccountCard card;
  final double size;
  final int extraPower;
  final bool showTitle;
  const MinimalCardItem(this.card,
      {this.size = 400, this.showTitle = true, this.extraPower = 0, super.key});

  @override
  State<MinimalCardItem> createState() => _MinimalCardItemState();
}

class _MinimalCardItemState extends State<MinimalCardItem> {
  TextStyle? _style;
  final GlobalKey _imageKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    var baseCard = widget.card.base;
    var level = baseCard.get<int>(CardFields.rarity).toString();
    var name =
        baseCard.get<FruitData>(CardFields.fruit).get<String>(FriutFields.name);

    var s = widget.size / 256;
    _style = TStyles.medium.copyWith(fontSize: 32 * s);

    return Hero(
      tag: widget.card.id,
      child: Stack(alignment: Alignment.center, children: [
        Asset.load<Image>('card_frame_${_getCardBg(level)}'),
        LoaderWidget(AssetType.image,
            widget.card.isHero ? name : baseCard.get<String>(CardFields.name),
            key: _imageKey, subFolder: "cards", width: 216 * s),
        widget.showTitle
            ? Positioned(
                top: 4 * s,
                left: 22 * s,
                height: 48 * s,
                child: SkinnedText("${name}_t".l(),
                    style: _style!.autoSize(name.length, 12, 32 * s)))
            : const SizedBox(),
        Positioned(
            top: 6 * s,
            right: 20 * s,
            width: 30 * s,
            height: 48 * s,
            child: SkinnedText(level, style: _style)),
        Positioned(
          bottom: 16 * s,
          left: 16 * s,
          child: Row(children: [
            SkinnedText(widget.card.power.compact(), style: _style),
            widget.extraPower > 0
                ? SkinnedText("+${widget.extraPower.compact()}",
                    style: _style!.copyWith(color: TColors.orange))
                : const SizedBox(),
          ]),
        )
      ]),
    );
  }

  _getCardBg(String level) {
    if (widget.card.isHero) return "hero";
    if (widget.card.isMonster) return "monster";
    return level;
  }
}
