import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/fruit.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets/loaderwidget.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'iscreen.dart';

class LevelupScreen extends AbstractScreen {
  LevelupScreen({required super.args, super.key}) : super(Routes.levelup);

  @override
  createState() => _LevelupScreenState();
}

class _LevelupScreenState extends AbstractScreenState<LevelupScreen>
    with RewardScreenMixin {
  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];
  int _gold = 0;
  AccountCard? _card;

  @override
  void initState() {
    super.initState();
    getService<Sounds>().play("levelup");
    _gold = widget.args["levelup_gold_added"] ?? 100;
    _card = widget.args["gift_card"] ?? accountBloc.account!.cards.values.last;
  }

  @override
  Widget contentFactory() {
    return Widgets.button(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: Stack(children: [
          backgrounBuilder(),
          LoaderWidget(AssetType.animation, "levelup",
              onRiveInit: _onRiveInit, riveAssetLoader: _onRiveAssetLoad),
        ]),
        onPressed: () {
          if (readyToClose) {
            closeInput?.value = true;
          } else {
            skipInput?.value = true;
          }
        });
  }

  _onRiveInit(Artboard artboard) {
    text(String name, String value) {
      artboard.component<TextValueRun>(name)?.text = value;
      artboard.component<TextValueRun>("${name}_stroke")?.text = value;
      artboard.component<TextValueRun>("${name}_shadow")?.text = value;
    }

    text("goldText", "$_gold");
    text("levelText", "${widget.args["level"] ?? 123}");
    text("cardNameText", "${_card!.base.fruit.name}_t".l());
    text("cardLevelText", "${_card!.base.rarity}");
    text("cardPowerText", "ˢ${_card!.power.compact()}");
    text("commentText", "tap_close".l());

    var controller = StateMachineController.fromArtboard(artboard, "Levelup")!;
    controller.addEventListener(_onRiveEvent);
    skipInput = controller.findInput<bool>("skip") as SMITrigger;
    closeInput = controller.findInput<bool>("close") as SMITrigger;
    artboard.addController(controller);
  }

  _onRiveEvent(RiveEvent event) async {
    if (event.name == "ready") {
      readyToClose = true;
    } else if (event.name == "close") {
      WidgetsBinding.instance
          .addPostFrameCallback((t) => Navigator.pop(context));
    }
  }

  Future<bool> _onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "cardIcon") {
        _loadCardIcon(asset);
        return true;
      } else if (asset.name == "cardFrame") {
        _loadCardFrame(asset);
        return true;
      }
    }
    if (asset is FontAsset) {
      _loadFont(asset);
      return true;
    }
    return false; // load the default embedded asset
  }

  Future<void> _loadCardIcon(ImageAsset asset) async {
    var loader = await LoaderWidget.load(AssetType.image, _card!.base.getName(),
        subFolder: "cards");
    while (loader.metadata == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    var image = await ImageAsset.parseBytes(loader.metadata as Uint8List);
    asset.image = image;
  }

  Future<void> _loadCardFrame(ImageAsset asset) async {
    var category = _card!.base.fruit.category;
    var level = category == 0 ? "_${_card!.base.rarity}" : "";
    var bytes =
        await rootBundle.load('assets/images/card_frame_$category$level.webp');
    var image = await ImageAsset.parseBytes(bytes.buffer.asUint8List());
    asset.image = image;
  }

  Future<void> _loadFont(FontAsset asset) async {
    var bytes = await rootBundle.load('assets/fonts/${asset.name}');
    var font = await FontAsset.parseBytes(bytes.buffer.asUint8List());
    asset.font = font;
  }
}

mixin RewardScreenMixin<T extends AbstractScreen> on State<T> {
  bool readyToClose = false;
  SMITrigger? skipInput, closeInput;
  Widget backgrounBuilder() {
    return LoaderWidget(AssetType.animation, "background_pattern",
        onRiveInit: (Artboard artboard) {
      var controller = StateMachineController.fromArtboard(artboard, "Pattern");
      // controller.findInput<bool>("move")?.value = true;
      artboard.addController(controller!);
    });
  }
}
