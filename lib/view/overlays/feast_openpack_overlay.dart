import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/fruit.dart';
import '../../data/core/store.dart';
import '../../mixins/background_mixin.dart';
import '../../mixins/reward_mixin.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../utils/utils.dart';
import '../items/card_item.dart';
import '../overlays/ioverlay.dart';

class OpenpackFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const OpenpackFeastOverlay({required this.args, super.key})
      : super(type: OverlayType.feastOpenpack);

  @override
  createState() => _OpenPackScreenState();
}

class _OpenPackScreenState extends AbstractOverlayState<OpenpackFeastOverlay>
    with RewardScreenMixin, TickerProviderStateMixin, BackgroundMixin {
  late ShopItem _pack;
  SMIInput<double>? _countInput;
  List<AccountCard> _cards = [];
  late AnimationController _opacityBackgroundAnimationController;
  late AnimationController _opacityAnimationController;
  final Map<int, ImageAsset> _cardIconAssets = {}, _cardFrameAssets = {};

  @override
  void initState() {
    startSFX = "open_card_pack";
    _opacityAnimationController = AnimationController(
        vsync: this, upperBound: 3, duration: const Duration(seconds: 3));
    _opacityBackgroundAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300), value: 1);
    children = [
      AnimatedBuilder(
          animation: _opacityBackgroundAnimationController,
          builder: (context, child) => Opacity(
              opacity: _opacityBackgroundAnimationController.value,
              child: backgroundBuilder())),
      _cardsList(),
      IgnorePointer(child: animationBuilder("openpack")),
    ];
    _pack = widget.args["pack"] ??
        accountBloc.account!.loadingData.shopItems[ShopSections.card]![0];

    _opacityAnimationController.forward();
    super.initState();

    process(() async {
      _cards = await accountBloc.openPack(context, _pack);
      var count = _cards.length > 2 ? 0 : _cards.length;
      _countInput?.value = count.toDouble();
      return _cards;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    _countInput = controller.findInput<double>("cards");

    updateRiveText("packNameText", "shop_card_${_pack.id}".l());
    updateRiveText("packDescriptionText", "shop_card_${_pack.id}_desc".l());
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == RewardAniationState.started) {
      var count = _cards.length > 2 ? 0 : _cards.length;
      for (var i = 0; i < count; i++) {
        var card = _cards[i];
        updateRiveText("cardNameText$i", "${card.base.fruit.name}_title".l());
        updateRiveText("cardLevelText$i", card.base.rarity.convert());
        updateRiveText("cardPowerText$i", "ˢ${card.power.compact()}");
        loadCardIcon(_cardIconAssets[i]!, card.base.getName());
        loadCardFrame(_cardFrameAssets[i]!, card.base);
      }
    } else if (state == RewardAniationState.closing) {
      _opacityBackgroundAnimationController.reverse();
    }
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "packIcon") {
        loadCardIcon(asset, "shop_card_${_pack.id}");
        return true;
      } else if (asset.name.startsWith("cardIcon")) {
        var index = int.parse(asset.name.substring(8));
        _cardIconAssets[index] = asset;
        return true;
      } else if (asset.name.startsWith("cardFrame")) {
        var index = int.parse(asset.name.substring(9));
        _cardFrameAssets[index] = asset;
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
