import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/fruit.dart';
import '../../data/core/store.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../utils/utils.dart';
import '../../view/mixins/reward_mixin.dart';
import '../items/card_item.dart';
import '../route_provider.dart';
import 'iscreen.dart';

class OpenpackFeastScreen extends AbstractScreen {
  OpenpackFeastScreen({required super.args, super.key})
      : super(Routes.feastOpenpack);

  @override
  createState() => _OpenPackScreenState();
}

class _OpenPackScreenState extends AbstractScreenState<OpenpackFeastScreen>
    with RewardScreenMixin {
  late ShopItem _pack;
  late List<AccountCard> _cards;
  late AnimationController _opacityAnimationController;

  @override
  void initState() {
    getService<Sounds>().play("levelup");
    _pack = widget.args["item"] ??

    children = [
      backgrounBuilder(),
      _cardsList(),
      IgnorePointer(child: animationBuilder("openpack")),
    ];
        accountBloc.account!.loadingData.shopItems[ShopSections.card]![0];

    _opacityAnimationController = AnimationController(
        vsync: this, upperBound: 3, duration: const Duration(seconds: 3));
    _opacityAnimationController.forward();
    super.initState();
        });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    var count = _cards.length > 2 ? 0 : _cards.length;
    controller.findInput<double>("cards")?.value = count.toDouble();
    for (var i = 1; i <= count; i++) {
      var card = _cards[i - 1];
      updateRiveText("cardNameText$i", "${card.base.fruit.name}_title".l());
      updateRiveText("cardLevelText$i", card.base.rarity.convert());
      updateRiveText("cardPowerText$i", "ˢ${card.power.compact()}");
    }
    updateRiveText("packNameText", "shop_card_${_pack.id}".l());
    updateRiveText("packDescriptionText", "shop_card_${_pack.id}_desc".l());
    return controller;
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "packIcon") {
        loadCardIcon(asset, "shop_card_${_pack.id}");
        return true;
      } else if (asset.name.startsWith("cardIcon")) {
        if (_cards.length < 3) {
          var index = int.parse(asset.name.substring(8)) - 1;
          loadCardIcon(asset, _cards[index].base.getName());
        }
        return true;
      } else if (asset.name.startsWith("cardFrame")) {
        if (_cards.length < 3) {
          var index = int.parse(asset.name.substring(9)) - 1;
          loadCardFrame(asset, _cards[index].base);
        }
        return true;
      }
    }
    if (asset is FontAsset) {
      loadFont(asset);
      return true;
    }
    return false; // load the default embedded asset
  }

  Widget _cardsList() {
    var len = _cards.length;
    if (len < 3) return const SizedBox();
    var gap = 8.d;
    var crossAxisCount = 2;
    var itemSize = 240.d;
    return Positioned(
        left: 22.d,
        right: 22.d,
        height: itemSize / CardItem.aspectRatio * crossAxisCount +
            gap * (crossAxisCount - 1),
        child: GridView.builder(
          itemCount: len,
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1 / CardItem.aspectRatio,
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: gap,
              mainAxisSpacing: gap),
          itemBuilder: (c, i) => _cardItemBuilder(len, i, itemSize),
        ));
  }

  Widget _cardItemBuilder(int len, int index, double size) {
    return AnimatedBuilder(
        animation: _opacityAnimationController,
        builder: (context, child) {
          return Opacity(
              opacity:
                  (_opacityAnimationController.value - 2 + (len - index) * 0.01)
                      .clamp(0, 1),
              child: SizedBox(
                  width: size, child: CardItem(_cards[index], size: size)));
        });
  }
}
