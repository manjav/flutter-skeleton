import 'package:flutter/material.dart';

import '../../data/core/rpc_data.dart';
import '../../services/deviceinfo.dart';
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
  // GlobalKey? _imageKey;

  @override
  void initState() {
    // _imageKey = GlobalKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var baseCard = widget.card.base;
    var s = widget.size / 256;
    medium = TStyles.medium.copyWith(fontSize: 42 * s);
    small = TStyles.medium.copyWith(fontSize: 33 * s);
    tiny = TStyles.medium.copyWith(fontSize: 28 * s);

    return Stack(alignment: Alignment.center, children: [
          subFolder: "cards", width: 216 * s),
      Positioned(
          top: 30 * s,
          left: 22 * s,
          child: SkinnedText(name,
              style: TStyles.small.copyWith(
                  fontSize: (22 * s + 60 * s / (name.length))
                      .clamp(22 * s, 40 * s)))),
      Positioned(
          top: 37 * s,
          right: 24 * s,
          width: 27 * s,
          child: SkinnedText(level, style: medium)),
      Positioned(
          bottom: 36 * s,
          left: 22 * s,
          child: SkinnedText(widget.card.power.summarize(), style: small)),
      Positioned(
          bottom: 36 * s,
          right: 20 * s,
          child: SkinnedText(
              baseCard.get<int>(CardFields.cooldown).toRemainingTime(),
              style: tiny)),
    ]);
  }
}
