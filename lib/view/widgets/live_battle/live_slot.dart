import 'package:flutter/material.dart';

import '../../../data/core/card.dart';
import '../../../data/core/infra.dart';
import '../../../services/deviceinfo.dart';
import '../../../services/theme.dart';
import '../../../utils/assets.dart';
import '../../../view/widgets/skinnedtext.dart';
import '../../items/card_item.dart';
import '../../key_provider.dart';
import '../../widgets.dart';
import '../card_holder.dart';

class LiveSlot extends StatelessWidget with KeyProvider {
  final int index;
  final double alignX, alignY, rotation;
  final SelectedCards deployedCards;
  final ValueNotifier<IntVec2d> currentIndex;

  LiveSlot(this.index, this.alignX, this.alignY, this.rotation,
      this.currentIndex, this.deployedCards,
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
          var offset = 0.0;
          if (deployedCards.value[2] != null) {
            size = 180.d;
            offset = switch (index) {
              0 => -0.15,
              1 => -0.20,
              3 => 0.20,
              4 => 0.15,
              _ => 0,
            };
          }
          var duration = const Duration(milliseconds: 500);
          const curve = Curves.easeInOutExpo;
          return AnimatedAlign(
              curve: curve,
              duration: duration,
              alignment: Alignment(alignX + offset, alignY),
              child: Transform.rotate(
                  angle: rotation,
                  child: AnimatedContainer(
                      duration: duration,
                      curve: curve,
                      width: size,
                      height: size / CardItem.aspectRatio,
                      child: _deadlineSlider(card))));
        });
  }

  Widget _deadlineSlider(Widget card) {
    var turns = 0.0;
    return ValueListenableBuilder<IntVec2d>(
        valueListenable: currentIndex,
        builder: (context, value, child) {
          var visible = index == value.i && alignY > 0;
          var duration = const Duration(milliseconds: 800);
          if (visible) {
            if (turns == 0.0) turns = 0.01;
            turns *= -1.0;
          }
          return Stack(
            alignment: Alignment.center,
            children: [
              AnimatedRotation(
                turns: turns,
                duration: duration,
                curve: Curves.easeInOutSine,
                child: card,
              ),
              visible
                  ? Widgets.rect(
                      color: TColors.green.withOpacity(0.8),
                      width: 122.d,
                      height: 122.d,
                      radius: 66.d,
                      child: SkinnedText("${value.j}"))
                  : const SizedBox(),
              visible
                  ? CircularProgressIndicator(
                      value: 0.95,
                      strokeWidth: 12.d,
                      backgroundColor: TColors.black.withOpacity(0.3),
                      color: TColors.primary10,
                    )
                  : const SizedBox(),
            ],
          );
        });
  }
}
