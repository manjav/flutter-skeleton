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
  final String? heroTag;
  const MinimalCardItem(this.card,
      {this.size = 400,
      this.showTitle = true,
      this.extraPower = 0,
      this.heroTag,
      super.key});

  @override
  State<MinimalCardItem> createState() => _MinimalCardItemState();

  static Image getCardBackground(CardData card) {
    var frameName = card.get<int>(CardFields.rarity).toString();
    if (card.isHero) frameName = "hero";
    if (card.isMonster) frameName = "monster";
    if (card.isCrystal) frameName = "crystal";
    return Asset.load<Image>('card_frame_$frameName');
  }

  static getCardImage(CardData card, double size, {Key? key}) {
    return LoaderWidget(AssetType.image,
        card.isHero ? card.name : card.get<String>(CardFields.name),
        key: key, subFolder: "cards", width: size);
  }
}

class _MinimalCardItemState extends State<MinimalCardItem> {
  TextStyle? _style;
  final GlobalKey _imageKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    var baseCard = widget.card.base;
    var level = baseCard.get<int>(CardFields.rarity).toString();
    var s = widget.size / 256;
    _style = TStyles.medium.copyWith(fontSize: 32 * s);

    return Hero(
      tag: widget.heroTag ?? widget.card.id,
      child: Stack(alignment: Alignment.center, children: [
        MinimalCardItem.getCardBackground(baseCard),
        MinimalCardItem.getCardImage(baseCard, 216 * s, key: _imageKey),
        widget.showTitle
            ? Positioned(
                top: 4 * s,
                left: 22 * s,
                height: 48 * s,
                child: SkinnedText("${baseCard.name}_t".l(),
                    style: _style!.autoSize(baseCard.name.length, 12, 32 * s)))
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
}
