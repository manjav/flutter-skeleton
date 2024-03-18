import 'package:flutter/material.dart';

import '../../app_export.dart';

class CardHolder extends StatefulWidget {
  final AccountCard? card;
  final bool heroMode;
  final bool showPower;
  final bool isLocked;
  final Function()? onTap;

  const CardHolder({
    this.card,
    this.heroMode = false,
    this.showPower = true,
    this.isLocked = false,
    this.onTap,
    super.key,
  });

  @override
  State<CardHolder> createState() => _CardHolderState();
}

class _CardHolderState extends State<CardHolder> with KeyProvider {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330.d,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Widgets.button(
            context,
            onPressed: () => widget.onTap?.call(),
            width: widget.heroMode ? 218.d : 183.d,
            height: widget.heroMode ? 296.d : 249.d,
            margin: EdgeInsets.only(bottom: 25.d),
            padding: EdgeInsets.all(12.d),
            decoration: Widgets.imageDecorator(
                "deck_placeholder", ImageCenterSliceData(117, 117)),
            child: widget.card == null ? _emptyCard() : _filledCard(),
          ),
          widget.card == null || !widget.showPower
              ? const SizedBox()
              : Positioned(
                bottom: 0.d,
                child: SkinnedText(widget.card!.power.compact(),
                    style: TStyles.mediumInvert),
              ),
        ],
      ),
    );
  }

  Widget _emptyCard() {
    var inside = "card";
    if (widget.isLocked) {
      inside = "lock";
    } else if (widget.heroMode) {
      inside = "hero";
    }
    return Padding(
        padding: EdgeInsets.all(24.d),
        child: Asset.load<Image>("deck_placeholder_$inside"));
  }

  Widget _filledCard() {
    var card = widget.card!;
    var name = card.base.isHero ? card.base.fruit.name : card.base.name;
    return LoaderWidget(AssetType.image, name,
        subFolder: "cards", key: getGlobalKey(card.id));
  }
}
