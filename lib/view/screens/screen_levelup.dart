import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/fruit.dart';
import '../../services/localization.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets/loaderwidget.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/skinnedtext.dart';
import 'iscreen.dart';

class LevelupScreen extends AbstractScreen {
  LevelupScreen({required super.args, super.key}) : super(Routes.levelup);

  @override
  createState() => _LevelupScreenState();
}

class _LevelupScreenState extends AbstractScreenState<LevelupScreen> {
  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];
  late AnimationController _animationController;
  int _gold = 0;
  AccountCard? _card;

  @override
  void initState() {
    super.initState();
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
        ]),
        onPressed: () {
          if (_animationController.isCompleted) {
            Navigator.pop(context);
          }
        });
  }

  _onRiveInit(Artboard artboard) {
    String level = "${widget.args["level"] ?? 123}";
    artboard.component<TextValueRun>('text_level')!.text = level;
    artboard.component<TextValueRun>('text_level_stroke')!.text = level;
    artboard.component<TextValueRun>('text_level_shadow')!.text = level;
    var controller = StateMachineController.fromArtboard(artboard, "Levelup")!;
    controller.addEventListener(_onRiveEvent);
    artboard.addController(controller);
  }
  _onRiveEvent(RiveEvent event) async {

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
