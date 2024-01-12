import 'package:flutter/material.dart';

import '../../data/core/fruit.dart';
import '../../skeleton/mixins/key_provider.dart';
import '../../skeleton/services/device_info.dart';
import '../../skeleton/services/theme.dart';
import '../../skeleton/utils/assets.dart';
import '../../skeleton/utils/utils.dart';
import '../../skeleton/views/widgets.dart';
import '../../skeleton/views/widgets/loader_widget.dart';

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
    return Column(children: [
      widget.card == null || !widget.showPower
          ? const SizedBox()
          : Widgets.rect(
              padding: EdgeInsets.all(12.d),
              decoration: Widgets.imageDecorator(
                  "deck_balloon",
                  ImageCenterSliceData(
                      50, 57, const Rect.fromLTWH(11, 11, 2, 2))),
              child: Text(widget.card!.power.compact(),
                  style: TStyles.mediumInvert)),
      Widgets.button(context,
          onPressed: () => widget.onTap?.call(),
          width: widget.heroMode ? 202.d : 184.d,
          height: widget.heroMode ? 202.d : 184.d,
          padding: EdgeInsets.all(12.d),
          decoration: Widgets.imageDecorator(
              "deck_placeholder", ImageCenterSliceData(117, 117)),
          child: widget.card == null ? _emptyCard() : _filledCard())
    ]);
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

