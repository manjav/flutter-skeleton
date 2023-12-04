import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/fruit.dart';
import '../../data/core/result.dart';
import '../../services/localization.dart';
import '../../utils/assets.dart';
import '../route_provider.dart';
import '../screens/iscreen.dart';
import '../widgets.dart';
import '../widgets/loaderwidget.dart';

enum RewardAniationState { none, waiting, started, shown, closed }

mixin RewardScreenMixin<T extends AbstractScreen> on State<T> {
  late Artboard _artboard;
  RewardAniationState state = RewardAniationState.none;
  SMITrigger? startInput, skipInput, closeInput;
  SMINumber? _colorInput;
  List<Widget> children = [];
  dynamic result;

  List<Widget> appBarElementsLeft() => [];

  Widget contentFactory() {
    return Widgets.button(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: Stack(children: children),
        onPressed: () {
          if (state.index <= RewardAniationState.waiting.index) return;
          if (state == RewardAniationState.started) {
            skipInput?.value = true;
          } else if (state == RewardAniationState.shown) {
            closeInput?.value = true;
          }
        });
  }

  Widget backgrounBuilder({int color = 0, bool animated = true}) {
    return LoaderWidget(AssetType.animation, "background_pattern",
        fit: BoxFit.fitWidth, onRiveInit: (Artboard artboard) {
      var controller =
          StateMachineController.fromArtboard(artboard, "State Machine 1");
      controller?.findInput<bool>("move")?.value = animated;
      _colorInput = controller?.findInput<double>("color") as SMINumber;
      changeBackgroundColor(color);
      artboard.addController(controller!);
    });
  }

  void changeBackgroundColor(int color) =>
      _colorInput?.value = color.toDouble();

  Widget animationBuilder(String fileName, {String? stateMachinName}) {
    return LoaderWidget(AssetType.animation, "feast_$fileName",
        riveAssetLoader: onRiveAssetLoad,
        onRiveInit: (artboard) =>
            onRiveInit(artboard, stateMachinName ?? "State Machine 1"));
  }

  StateMachineController onRiveInit(Artboard artboard, String stateMachinName) {
    _artboard = artboard;
    var controller =
        StateMachineController.fromArtboard(artboard, stateMachinName)!;
    startInput = controller.findInput<bool>("start") as SMITrigger;
    skipInput = controller.findInput<bool>("skip") as SMITrigger;
    closeInput = controller.findInput<bool>("close") as SMITrigger;
    updateRiveText("commentText", "tap_close".l());
    controller.addEventListener(onRiveEvent);
    artboard.addController(controller);
    return controller;
  }

  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "cardIcon") {
        loadCardIcon(asset, "");
        return true;
      } else if (asset.name == "cardFrame") {
        loadCardFrame(asset, null);
        return true;
      }
    }
    if (asset is FontAsset) {
      loadFont(asset);
      return true;
    }
    return false; // load the default embedded asset
  }

  void updateRiveText(String name, String value) {
    _artboard.component<TextValueRun>(name)?.text = value;
    _artboard.component<TextValueRun>("${name}_stroke")?.text = value;
    _artboard.component<TextValueRun>("${name}_shadow")?.text = value;
  }

  void onRiveEvent(RiveEvent event) {
    state = switch (event.name) {
      "waiting" => RewardAniationState.waiting,
      "started" => RewardAniationState.started,
      "shown" => RewardAniationState.shown,
      "closed" || "close" => RewardAniationState.closed,
      _ => RewardAniationState.none,
    };
    if (state == RewardAniationState.waiting) {
      if (result != null) {
        startInput?.value = true;
      }
    } else if (state == RewardAniationState.closed) {
      WidgetsBinding.instance.addPostFrameCallback((t) => close());
    }
  }

  Future<void> loadCardIcon(ImageAsset asset, String name) async =>
      asset.image = await loadImage(name, subFolder: "cards");

  Future<void> loadCardFrame(ImageAsset asset, FruitCard? card) async {
    if (card == null) return;
    var levelString = card.fruit.category == 0 ? "_${card.rarity}" : "";
    var bytes = await rootBundle.load(
        'assets/images/card_frame_${card.fruit.category}$levelString.webp');
    asset.image = await ImageAsset.parseBytes(bytes.buffer.asUint8List());
  }

  Future<ui.Image?> loadImage(String name, {String? subFolder}) async {
    var loader =
        await LoaderWidget.load(AssetType.image, name, subFolder: subFolder);
    while (loader.metadata == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    var image = await ImageAsset.parseBytes(loader.metadata as Uint8List);
    return image;
  }

  Future<void> loadFont(FontAsset asset) async {
    var bytes = await rootBundle.load('assets/fonts/${asset.name}');
    var font = await FontAsset.parseBytes(bytes.buffer.asUint8List());
    asset.font = font;
  }

  process(Future<dynamic> Function() callback) async {
    try {
      result = await callback.call();
      if (state == RewardAniationState.waiting) {
        startInput?.value = true;
      }
    } on RpcException catch (e) {
      if (context.mounted) {
        close();
        await Future.delayed(const Duration(milliseconds: 10));
        if (mounted) {
          Navigator.pushNamed(context, Routes.popupMessage.routeName,
              arguments: {
                "title": "Error",
                "message": "error_${e.statusCode.value}".l()
              });
        }
      }
    }
  }

  void close() => Navigator.pop(context);
}
