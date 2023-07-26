import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets.dart';
import '../../view/widgets/loaderwidget.dart';
import '../widgets/skinnedtext.dart';

class CardItem extends StatefulWidget {
  final double size;
  final bool inDeck;
  final AccountCard card;
  const CardItem(this.card, {this.size = 400, this.inDeck = false, super.key});

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  TextStyle? _medium;
  TextStyle? _small;
  TextStyle? _tiny;
  Timer? _cooldownTimer;
  final ValueNotifier<int> _remainingCooldown = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    var baseCard = widget.card.base;
    var fruit = baseCard.get<FruitData>(CardFields.fruit);
    var level = baseCard.get<int>(CardFields.rarity).toString();
    var name = fruit.get<String>(FriutFields.name);
    var cooldown = baseCard.get<int>(CardFields.cooldown);
    if (widget.inDeck) {
      _remainingCooldown.value = widget.card.getRemainingCooldown();
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _remainingCooldown.value = widget.card.getRemainingCooldown();
        if (_remainingCooldown.value <= 0) {
          if (mounted) setState(() => timer.cancel());
        }
      });
    }
    var s = widget.size / 256;
    if (_tiny == null) {
      _medium = TStyles.medium.copyWith(fontSize: 42 * s);
      _small = TStyles.medium.copyWith(fontSize: 33 * s);
      _tiny = TStyles.medium.copyWith(fontSize: 28 * s);
    }

    return Hero(
      tag: widget.card.id,
      child: Stack(alignment: Alignment.center, children: [
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
            top: 1 * s,
            right: 23 * s,
            width: 27 * s,
            child: SkinnedText(level, style: _medium)),
        Positioned(
            bottom: 16 * s,
            left: 22 * s,
            child: SkinnedText(widget.card.power.compact(), style: _small)),
        Positioned(
            bottom: 20 * s,
            right: 20 * s,
            child: SkinnedText(cooldown.toRemainingTime(), style: _tiny)),
        _remainingCooldown.value == 0
            ? const SizedBox()
            : ValueListenableBuilder<int>(
                valueListenable: _remainingCooldown,
                builder: (context, value, child) => Positioned(
                  child: Widgets.rect(
                    margin: EdgeInsets.all(8.d),
                    color: TColors.white50,
                    padding: EdgeInsets.zero,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 64.d),
                          SkinnedText(
                              _remainingCooldown.value.toRemainingTime()),
                          IgnorePointer(
                            ignoring: true,
                            child: Widgets.labeledButton(
                                width: 230.d,
                                color: ButtonColor.teal,
                                padding:
                                    EdgeInsets.fromLTRB(20.d, 20.d, 20.d, 32.d),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Asset.load<Image>("ui_gold",
                                          height: 64.d),
                                      SizedBox(width: 4.d),
                                      SkinnedText(widget.card
                                          .cooldownTimeToCost(
                                              _remainingCooldown.value)
                                          .compact()),
                                    ])),
                          )
                        ]),
                  ),
                ),
              )
      ]),
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
