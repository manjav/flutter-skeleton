import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets.dart';
import '../widgets/loaderwidget.dart';
import '../widgets/skinnedtext.dart';

class CardItem extends StatefulWidget {
  final double size;
  final bool showCooloff;
  final bool showCooldown;
  final bool showPower;
  final bool showTitle;
  final int extraPower;
  final String? heroTag;
  final AccountCard card;
  const CardItem(this.card,
      {this.size = 400,
      this.showCooloff = false,
      this.showCooldown = true,
      this.showPower = true,
      this.showTitle = true,
      this.extraPower = 0,
      this.heroTag,
      super.key});

  @override
  State<CardItem> createState() => _CardItemState();

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

class _CardItemState extends State<CardItem> {
  TextStyle? _medium;
  TextStyle? _small;
  TextStyle? _tiny;
  Timer? _cooldownTimer;
  final GlobalKey _imageKey = GlobalKey();
  final ValueNotifier<int> _remainingCooldown = ValueNotifier(0);
  @override
  Widget build(BuildContext context) {
    var baseCard = widget.card.base;
    var level = baseCard.get<int>(CardFields.rarity).toString();
    var cooldown = baseCard.get<int>(CardFields.cooldown);
    if (widget.showCooloff) {
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

    var items = <Widget>[
      CardItem.getCardBackground(baseCard),
      CardItem.getCardImage(baseCard, 216 * s, key: _imageKey),
      Positioned(
          top: 1 * s,
          right: 23 * s,
          width: 27 * s,
          child: SkinnedText(level, style: _medium))
    ];
    if (widget.showTitle) {
      items.add(Positioned(
          top: 6 * s,
          left: 22 * s,
          height: 52 * s,
          child: SkinnedText("${baseCard.name}_t".l(),
              style: _small!.autoSize(baseCard.name.length, 8, 36 * s))));
    }
    if (widget.showCooldown) {
      items.add(Positioned(
          bottom: 20 * s,
          right: 20 * s,
          child: SkinnedText(cooldown.toRemainingTime(), style: _tiny)));
    }

    if (widget.showPower) {
      items.add(Positioned(
          bottom: 16 * s,
          left: 16 * s,
          child: Row(children: [
            SkinnedText(widget.card.power.compact(), style: _small),
            widget.extraPower > 0
                ? SkinnedText("+${widget.extraPower.compact()}",
                    style: _small!.copyWith(color: TColors.orange))
                : const SizedBox(),
          ])));
    }
    if (widget.showCooloff && _remainingCooldown.value > 0) {
      items.add(ValueListenableBuilder<int>(
          valueListenable: _remainingCooldown,
          builder: (context, value, child) => Positioned(
              child: Widgets.rect(
                  radius: 20.d,
                  color: TColors.white50,
                  padding: EdgeInsets.zero,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox()),
                        SkinnedText(_remainingCooldown.value.toRemainingTime()),
                        IgnorePointer(
                            ignoring: true,
                            child: Widgets.skinnedButton(
                                width: 230.d,
                                height: 128.d,
                                color: ButtonColor.teal,
                                padding: EdgeInsets.only(bottom: 12.d),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Asset.load<Image>("icon_gold",
                                          height: 56.d),
                                      SizedBox(width: 2.d),
                                      SkinnedText(widget.card
                                          .cooldownTimeToCost(
                                              _remainingCooldown.value)
                                          .compact())
                                    ])))
                      ])))));
    }

    return Hero(
        tag: widget.heroTag ?? widget.card.id,
        child: Stack(alignment: Alignment.center, children: items));
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
