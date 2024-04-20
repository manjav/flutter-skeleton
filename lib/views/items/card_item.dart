import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class CardItem extends StatefulWidget {
  static const aspectRatio = 0.72;
  final double size;
  final bool showCoolOff;
  final bool showCooldown;
  final bool showPower;
  final bool showTitle;
  final int extraPower;
  final String? heroTag;
  final AbstractCard card;
  final bool isTutorial;
  const CardItem(this.card,
      {this.size = 400,
      this.showCoolOff = false,
      this.showCooldown = true,
      this.showPower = true,
      this.showTitle = true,
      this.extraPower = 0,
      this.heroTag,
      this.isTutorial = false,
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

  static getHeroAnimation(AbstractCard card, double size,
      {Key? key, Function(StateMachineController)? onInitController}) {
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
      if (onInitController != null) onInitController(controller);
    }, riveAssetLoader: _onRiveAssetLoad, key: key);
  }
}

Future<bool> _onRiveAssetLoad(FileAsset asset, Uint8List? embeddedBytes) async {
  if (asset is FontAsset) {
    _loadFont(asset);
    return true;
  }
  return false; // load the default embedded asset
}

Future<void> _loadFont(FontAsset asset) async {
  var bytes = await rootBundle.load('assets/fonts/${asset.name}');
  var font = await FontAsset.parseBytes(bytes.buffer.asUint8List());
  asset.font = font;
}

class _CardItemState extends State<CardItem> {
  TextStyle? _medium;
  TextStyle? _small;
  TextStyle? _tiny;
  Timer? _cooldownTimer;
  final GlobalKey _imageKey = GlobalKey();
  final ValueNotifier<int> _remainingCooldown = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _remainingCooldown.value = widget.card.getRemainingCooldown();
    if (!widget.isTutorial &&
        widget.showCoolOff &&
        _remainingCooldown.value > 0) {
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _remainingCooldown.value = widget.card.getRemainingCooldown();
        if (_remainingCooldown.value <= 0) {
          if (mounted) setState(() => timer.cancel());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var baseCard = widget.card.base;
    var level = baseCard.rarity;
    var cooldown = baseCard.cooldown;

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
          child:
              SkinnedText(level.convert(), style: level > 9 ? _small : _medium))
    ];
    if (widget.showTitle) {
      items.add(Positioned(
          top: 6 * s,
          left: 22 * s,
          height: 52 * s,
          width: 180 * s,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: SkinnedText("${baseCard.fruit.name}_title".l(),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    alignment: Alignment.centerLeft,
                    style: _small!.autoSize(baseCard.name.length, 8, 40 * s)),
              ),
            ],
          )));
    }
    if (widget.showCooldown) {
      items.add(Positioned(
          bottom: 20 * s,
          right: 20 * s,
          child: SkinnedText("ˣ${cooldown.toRemainingTime().convert()}",
              style: _tiny)));
    }

    if (widget.showPower) {
      items.add(Positioned(
          bottom: 16 * s,
          left: 16 * s,
          child: Row(textDirection: TextDirection.ltr, children: [
            SkinnedText("ˢ${widget.card.power.compact().convert()}",
                style: _small),
            widget.extraPower > 0
                ? SkinnedText("+${widget.extraPower.compact().convert()}",
                    textDirection: TextDirection.ltr,
                    style: _small!.copyWith(color: TColors.orange))
                : const SizedBox(),
          ])));
    }
    if (widget.showCoolOff && _remainingCooldown.value > 0) {
      items.add(
        Positioned(
          top: 1 * s,
          left: 6 * s,
          bottom: 8 * s,
          right: 6 * s,
          child: ValueListenableBuilder<int>(
            valueListenable: _remainingCooldown,
            builder: (context, value, child) => Widgets.rect(
              radius: 23 * s,
              color: TColors.black80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  LoaderWidget(
                      AssetType.image,
                      subFolder: "cards",
                      "cooldown_glow",
                      height: 204.d,
                      width: 205.d),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ˣ ${widget.isTutorial ? baseCard.cooldown : _remainingCooldown.value.toRemainingTime().convert()}",
                        style: TStyles.medium.copyWith(
                          color: TColors.white,
                        ),
                      ),
                      SizedBox(height: 5.d),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          LoaderWidget(
                              AssetType.image,
                              subFolder: "cards",
                              "cooldown_button",
                              height: 80.d),
                          StreamBuilder<Object>(
                            stream: (widget.card as AccountCard)
                                .loadingCoolOff
                                .stream,
                            builder: (context, snapshot) {
                              return LoaderWidget(
                                  AssetType.image,
                                  subFolder: "cards",
                                  (snapshot.hasData && snapshot.data == true)
                                      ? "cooldown_reloaded"
                                      : "cooldown_reload",
                                  height: 50.d);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.d,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Asset.load<Image>('icon_gold', height: 60.d),
                          SizedBox(
                            width: 5.d,
                          ),
                          Text(
                              widget.card
                                  .cooldownTimeToCost(widget.isTutorial
                                      ? baseCard.cooldown
                                      : _remainingCooldown.value)
                                  .compact(),
                              style: TStyles.medium.copyWith(
                                color: TColors.white,
                              )),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
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
