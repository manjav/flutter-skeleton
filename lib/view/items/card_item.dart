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

class CardView extends StatefulWidget {
  final AccountCard card;
  final double size;
  final bool inDeck;
  const CardView(this.card, {this.size = 400, this.inDeck = false, super.key});

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  static TextStyle? _medium;
  static TextStyle? _small;
  static TextStyle? _tiny;
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

    return Stack(alignment: Alignment.center, children: [
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
          top: 2 * s,
          right: 24 * s,
          width: 27 * s,
          child: SkinnedText(level, style: _medium)),
      Positioned(
          bottom: 6 * s,
          left: 22 * s,
          child: SkinnedText(widget.card.power.compact(), style: _small)),
      Positioned(
          bottom: 6 * s,
          right: 20 * s,
          child: SkinnedText(cooldown.toRemainingTime(), style: _tiny)),
      _remainingCooldown.value == 0
          ? const SizedBox()
          : ValueListenableBuilder<int>(
              valueListenable: _remainingCooldown,
              builder: (context, value, child) => Positioned(
                  child: Widgets.button(
                      margin: EdgeInsets.all(8.d),
                      color: TColors.white50,
                      child: Column(
                        children: [
                          SkinnedText(
                              _remainingCooldown.value.toRemainingTime()),
                          SkinnedText(widget.card
                              .cooldownTimeToCost(_remainingCooldown.value)
                              .compact())
                        ],
                      ))))
    ]);
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
