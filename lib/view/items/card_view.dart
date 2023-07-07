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
  const CardView(this.card, {super.key});

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
    var name = baseCard.get<String>(CardFields.name);
    var parts = name.split(' ');
    return Stack(alignment: Alignment.center, children: [
      Asset.load<Image>('cards_frame_${parts[1]}'),
      LoaderWidget(
          key: widget.card.key,
          AssetType.image,
          name,
          subFolder: "cards",
          width: 216.d),
      Positioned(
          top: 34.d,
          left: 22.d,
          child: SkinnedText(parts[0],
              style: TStyles.small.copyWith(
                  fontSize:
                      (24.d + 60.d / (parts[0].length)).clamp(22.d, 42.d)))),
      Positioned(
          top: 37.d,
          right: 24.d,
          width: 27.d,
          child: SkinnedText(parts[1], style: TStyles.medium)),
      Positioned(
          bottom: 36.d,
          left: 22.d,
          child:
              SkinnedText(widget.card.power.summarize(), style: TStyles.small)),
      Positioned(
          bottom: 36.d,
          right: 20.d,
          child: SkinnedText(
              baseCard.get<int>(CardFields.cooldown).toRemainingTime(),
              style: TStyles.tiny)),
    ]);
  }
}
