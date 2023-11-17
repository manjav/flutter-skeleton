import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../utils/assets.dart';
import '../screens/iscreen.dart';
import '../widgets/loaderwidget.dart';

mixin RewardScreenMixin<T extends AbstractScreen> on State<T> {
  late Artboard _artboard;
  bool readyToClose = false;
  SMITrigger? skipInput, closeInput;
  SMINumber? _colorInput;

  List<Widget> appBarElementsLeft() => [];
  List<Widget> appBarElementsRight() => [];

  Widget backgrounBuilder({int color = 0, bool animated = true}) {
    return LoaderWidget(AssetType.animation, "background_pattern",
        onRiveInit: (Artboard artboard) {
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
    skipInput = controller.findInput<bool>("skip") as SMITrigger;
    closeInput = controller.findInput<bool>("close") as SMITrigger;
    controller.findInput<double>("cards")?.value = 6.0;
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
        loadCardFrame(asset, 0, "");
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
    if (event.name == "ready") {
      readyToClose = true;
    } else if (event.name == "close") {
      WidgetsBinding.instance
          .addPostFrameCallback((t) => Navigator.pop(context));
    }
  }

  Future<void> loadCardIcon(ImageAsset asset, String name) async {
    var loader =
        await LoaderWidget.load(AssetType.image, name, subFolder: "cards");
    while (loader.metadata == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    asset.image = await ImageAsset.parseBytes(loader.metadata as Uint8List);
  }

  Future<void> loadCardFrame(
      ImageAsset asset, int category, String level) async {
    var bytes =
        await rootBundle.load('assets/images/card_frame_$category$level.webp');
    asset.image = await ImageAsset.parseBytes(bytes.buffer.asUint8List());
  }

  Future<void> loadFont(FontAsset asset) async {
    var bytes = await rootBundle.load('assets/fonts/${asset.name}');
    var font = await FontAsset.parseBytes(bytes.buffer.asUint8List());
    asset.font = font;
  }
}
