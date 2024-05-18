import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class OpenPackFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const OpenPackFeastOverlay({required this.args, super.onClose, super.key})
      : super(route: OverlaysName.feastOpenPack);

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
  }

  Future<void> getData() async {
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
      backgroundBuilder(),
      animationBuilder("openpack"),
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
    getData();
    return controller;
  }

  @override
  void onScreenTouched() {
    if (state == RewardAnimationState.shown &&
        !_heroSelected &&
        _cards[0].base.isHero) {
      return;
    }
    super.onScreenTouched();
  }

  @override
  Widget closeButton() {
    if (_cards.isNotEmpty && _cards[0].base.isHero) {
      closeButtonController = null;
      return const SizedBox();
    }
    return super.closeButton();
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == RewardAnimationState.started) {
      for (var i = 0; i < _cards.length; i++) {
        var card = _cards[i];
        updateRiveText("cardNameText$i", "${card.base.fruit.name}_title".l());
        updateRiveText("cardLevelText$i", card.base.rarity.convert());
        updateRiveText("cardPowerText$i", "ˢ${card.base.power.compact()}");
        loadCardIcon(_cardIconAssets[i]!, card.base.getName());
        loadCardFrame(_cardFrameAssets[i]!, card.base);
        if (card.base.isHero) {
          var heroText = "";
          switch (card.base.heroType) {
            case 0:
              heroText = "power";
              break;
            case 1:
              heroText = "wisdom";
              break;
            case 2:
              heroText = "blessing";
              break;
          }
          updateRiveText("cardCaptionText$i", "${heroText}_title".l());
          updateRiveText("benefitCooldownText$i",
              card.base.attributes[HeroAttribute.wisdom].toString().convert());
          updateRiveText(
              "benefitGoldText$i",
              card.base.attributes[HeroAttribute.blessing]
                  .toString()
                  .convert());
          updateRiveText("benefitPowerText$i",
              card.base.attributes[HeroAttribute.power].toString().convert());
        }
      }
      if (_cards[0].base.isHero) {
        updateRiveText("commentText", "select a hero".l());
      } else {
        updateRiveText("commentText", "tap_close".l());
      }
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
    return false;
  }

  @override
  void dispose() {
    _opacityBackgroundAnimationController.dispose();
    _opacityAnimationController.dispose();
    super.dispose();
  }

  Future<void> _chooseHero(int index) async {
    process(() async {
      var result = await accountProvider.openPack(context, _pack,
          selectedCardId: _cards[index].base.id);
      return result;
    });
  }
}
