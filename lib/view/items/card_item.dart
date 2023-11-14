import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../data/core/fruit.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets.dart';
import '../widgets/loaderwidget.dart';
import '../widgets/skinnedtext.dart';

class CardItem extends StatefulWidget {
  static const aspectRatio = 0.74;
  final double size;
  final bool showCooloff;
  final bool showCooldown;
  final bool showPower;
  final bool showTitle;
  final int extraPower;
  final String? heroTag;
  final AbstractCard card;
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

  static Image getCardBackground(int category, int rarity) {
    var level = category == 0 ? "_$rarity" : "";
    return Asset.load<Image>("card_frame_$category$level");
  }

  static LoaderWidget getCardImage(FruitCard card, double size, {Key? key}) {
    return LoaderWidget(AssetType.image, card.getName(),
        key: key, subFolder: "cards", width: size);
  }

  static getHeroAnimation(AbstractCard card, double size, {Key? key}) {
    var hero = card.account.heroes[card.id];
    var items = <String, HeroItem>{};
    if (hero != null) {
      for (var item in hero.items) {
        if (item.base.category == 1) {
          items[item.position == 1 ? "minion_left" : "minion_right"] = item;
        } else {
          items[item.position == 1 ? "weapon_left" : "weapon_right"] = item;
        }
      }
    }

    return LoaderWidget(AssetType.animation, "heroes",
        width: size, height: size, onRiveInit: (Artboard artboard) {
      final controller =
          StateMachineController.fromArtboard(artboard, 'Heroes')!;
      controller.findInput<double>('hero')?.value = card.fruit.id.toDouble();
      for (var item in items.entries) {
        controller.findInput<double>(item.key)?.value =
            item.value.base.id.toDouble();
      }
      artboard.addController(controller);
    }, key: key);
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
    var level = baseCard.rarity;
    var cooldown = baseCard.cooldown;
    _remainingCooldown.value = widget.card.getRemainingCooldown();
    if (widget.showCooloff && _remainingCooldown.value > 0) {
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _remainingCooldown.value = widget.card.getRemainingCooldown();
        if (_remainingCooldown.value <= 0) {
          if (mounted) setState(() => timer.cancel());
        }
      });
    }
    var s = widget.size / 256;
    if (_tiny == null) {
      _medium = TStyles.medium.copyWith(fontSize: 41 * s);
      _small = TStyles.medium.copyWith(fontSize: 33 * s);
      _tiny = TStyles.medium.copyWith(fontSize: 28 * s);
    }

    var items = <Widget>[
      CardItem.getCardBackground(baseCard.fruit.category, baseCard.rarity),
      widget.card.base.isHero
          ? CardItem.getHeroAnimation(widget.card, 320 * s)
          : CardItem.getCardImage(baseCard, 216 * s, key: _imageKey),
      Positioned(
          top: (level > 9 ? 8 : 2) * s,
          right: 13 * s,
          width: 48 * s,
          child: SkinnedText(level.toString(),
              style: level > 9 ? _small : _medium))
    ];
    if (widget.showTitle) {
      items.add(Positioned(
          top: 6 * s,
          left: 22 * s,
          height: 52 * s,
          child: SkinnedText("${baseCard.fruit.name}_t".l(),
              style: _small!.autoSize(baseCard.name.length, 8, 36 * s))));
    }
    if (widget.showCooldown) {
      items.add(Positioned(
          bottom: 20 * s,
          right: 20 * s,
          child: SkinnedText("ˣ${cooldown.toRemainingTime()}", style: _tiny)));
    }

    if (widget.showPower) {
      items.add(Positioned(
          bottom: 16 * s,
          left: 16 * s,
          child: Row(children: [
            SkinnedText("ˢ${widget.card.power.compact()}", style: _small),
            widget.extraPower > 0
                ? SkinnedText("+${widget.extraPower.compact()}",
                    style: _small!.copyWith(color: TColors.orange))
                : const SizedBox(),
          ])));
    }
    if (widget.showCooloff && _remainingCooldown.value > 0) {
      items.add(Positioned(
          top: 1 * s,
          left: 6 * s,
          bottom: 8 * s,
          right: 6 * s,
          child: ValueListenableBuilder<int>(
              valueListenable: _remainingCooldown,
              builder: (context, value, child) => Widgets.rect(
                  radius: 23 * s,
                  color: TColors.white50,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox()),
                        SkinnedText(_remainingCooldown.value.toRemainingTime()),
                        IgnorePointer(
                            ignoring: true,
                            child: Widgets.skinnedButton(
                                height: 128.d,
                                color: ButtonColor.teal,
                                padding: EdgeInsets.only(bottom: 12.d),
                                label: widget.card
                                    .cooldownTimeToCost(
                                        _remainingCooldown.value)
                                    .compact(),
                                icon: "icon_gold"))
                      ])))));
    }

    var stack = Stack(alignment: Alignment.center, children: items);
    if (widget.heroTag != null) {
      return Hero(
          tag: widget.heroTag!,
          child: Material(type: MaterialType.transparency, child: stack));
    }
    return stack;
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
