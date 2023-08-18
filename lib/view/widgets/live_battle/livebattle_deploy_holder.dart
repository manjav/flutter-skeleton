import 'package:flutter/material.dart';
import '../../../services/deviceinfo.dart';

import '../../../data/core/card.dart';
import '../../../utils/assets.dart';
import '../../items/card_item.dart';
import '../../key_provider.dart';
import '../card_holder.dart';

class DeployHolder extends StatelessWidget with KeyProvider {
  final int index;
  final double alignX, alignY, rotation;
  final SelectedCards deployedCards;

  DeployHolder(
      this.index, this.alignX, this.alignY, this.rotation, this.deployedCards,
      {super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: deployedCards,
        builder: (context, value, child) {
          var size = 190.d;
          Widget? card;
          if (value[index] != null) {
            if (value[index]!.id == -1) {
              card = Asset.load<Image>("deck_live_missed");
            } else {
              card = CardItem(value[index]!,
                  size: size,
                  showCooldown: false,
                  key: getGlobalKey(value[index]!.id));
            }
          } else {
            card = Asset.load<Image>("deck_live_empty");
          }
          return Align(
              alignment: Alignment(alignX, alignY),
              child: Transform.rotate(
                  angle: rotation,
                  child: SizedBox(
                      width: size,
                      height: size / CardItem.aspectRatio,
                      child: card)));
        });
  }
}
