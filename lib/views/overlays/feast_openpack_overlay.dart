import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class OpenPackFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const OpenPackFeastOverlay({required this.args, super.onClose, super.key})
      : super(type: OverlayType.feastOpenpack);

  @override
  createState() => _OpenPackScreenState();
}

class _OpenPackScreenState extends AbstractOverlayState<OpenPackFeastOverlay>
    with RewardScreenMixin, TickerProviderStateMixin, BackgroundMixin {
  late ShopItem _pack;
  SMIInput<bool>? _heroInput;
  SMIInput<double>? _countInput;
  List<AccountCard> _cards = [];
  late AnimationController _opacityAnimationController;
  late AnimationController _opacityBackgroundAnimationController;
  final Map<int, ImageAsset> _cardIconAssets = {}, _cardFrameAssets = {};

  @override
  void initState() {
    startSFX = "open_card_pack";
    _opacityAnimationController = AnimationController(
        vsync: this, upperBound: 3, duration: const Duration(seconds: 3));
    _opacityBackgroundAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300), value: 1);
    _updateChildren();
    _pack = widget.args["pack"] ??
        accountProvider.account.loadingData.shopItems[ShopSections.card]![0];

    _opacityAnimationController.forward();
    super.initState();

    process(() async {
      _cards = await accountProvider.openPack(context, _pack);
      var maxCards = _cards.first.base.isHero ? 4 : 2;
      if (_cards.first.base.isHero) {
        _heroInput?.value = true;
      }
      var count = _cards.length > maxCards ? 0 : _cards.length;
      if (count == 0) {
        setState(() => _updateChildren());
      }
      _countInput?.value = count.toDouble();
      return _cards;
    });
  }
//   {"base_card_id":515,"type":32}
// {"cards":[{"id":559815886,"last_used_at":0,"power":46,"base_card_id":515,"player_id":8169489}],"gold":10619953,"nectar":783}

  void _updateChildren() {
    children = [
      AnimatedBuilder(
          animation: _opacityBackgroundAnimationController,
          builder: (context, child) => Opacity(
              opacity: _opacityBackgroundAnimationController.value,
              child: backgroundBuilder())),
      animationBuilder("openpack"),
      _cardsList(),
    ];
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    _countInput = controller.findInput<double>("cards");
    _heroInput = controller.findInput<bool>("isHero");
    updateRiveText("packNameText", "shop_card_${_pack.id}".l());
    updateRiveText("packDescriptionText", "shop_card_${_pack.id}_desc".l());
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    print(event);
    super.onRiveEvent(event);
    if (state == RewardAnimationState.started) {
      var count = _cards.length > 2 ? 0 : _cards.length;
      for (var i = 0; i < count; i++) {
        var card = _cards[i];
        updateRiveText("cardNameText$i", "${card.base.fruit.name}_title".l());
        updateRiveText("cardLevelText$i", card.base.rarity.convert());
        updateRiveText("cardPowerText$i", "ˢ${card.power.compact()}");
        loadCardIcon(_cardIconAssets[i]!, card.base.getName());
        loadCardFrame(_cardFrameAssets[i]!, card.base);
      }
    } else if (state == RewardAnimationState.closing) {
      _opacityAnimationController.animateBack(0,
          duration: const Duration(milliseconds: 500));
      _opacityBackgroundAnimationController.reverse();
    }
    if (event.name == "choose") {
      _chooseHero(event.properties["card"].toInt());
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
    return Material(
      color: Colors.transparent,
      child: Container(
          alignment: Alignment.center,
          width: DeviceInfo.size.width * 0.94,
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
          )),
    );
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

  @override
  void dispose() {
    _opacityBackgroundAnimationController.dispose();
    _opacityAnimationController.dispose();
    super.dispose();
  }

  Future<void> _chooseHero(int index) async {
    // _cards = await accountBloc.openPack(context, _pack,
    //     selectedCardId: _cards[index].base.id);
    var result = {
      "achieveCards": [
        {
          "id": 559815886,
          "last_used_at": 0,
          "power": 46,
          "base_card_id": 715,
          "player_id": 8169489
        }
      ]
    };

    process(() async {
      var result = await accountProvider.openPack(context, _pack,
          selectedCardId: _cards[index].base.id);
      return result;
    });
  }
}
