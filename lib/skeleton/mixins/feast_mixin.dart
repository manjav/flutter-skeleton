import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

enum FeastState { none, waiting, started, shown, closing, closed, disposed }

mixin FeastMixin<T extends StatefulWidget> on State<T> {
  dynamic result;
  Artboard? _artboard;
  List<Widget> children = [];
  String waitingSFX = "waiting", startSFX = "levelup";
  SMITrigger? startInput, skipInput, closeInput;
  FeastState state = FeastState.none;
  final ValueNotifier<bool> _progressbarNotifier = ValueNotifier(true);

  List<Widget> appBarElementsLeft() => [];

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    items.addAll(children);
    items.add(_progressbarBuilder());
    return Widgets.button(context,
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        width: DeviceInfo.size.width,
        height: DeviceInfo.size.height,
        child: Stack(alignment: Alignment.center, children: items),
        onPressed: onScreenTouched);
  }

  Widget animationBuilder(String fileName, {String? stateMachineName}) {
    return LoaderWidget(AssetType.animation, "feast_$fileName",
        fit: BoxFit.cover,
        riveAssetLoader: onRiveAssetLoad,
        onRiveInit: (artboard) =>
            onRiveInit(artboard, stateMachineName ?? "State Machine 1"));
  }

  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    _artboard = artboard;
    var controller =
        StateMachineController.fromArtboard(artboard, stateMachineName)!;
    startInput = controller.findInput<bool>("start") as SMITrigger;
    skipInput = controller.findInput<bool>("skip") as SMITrigger;
    closeInput = controller.findInput<bool>("close") as SMITrigger;
    controller.addEventListener(onRiveEvent);
    artboard.addController(controller);
    return controller;
  }

  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    // if (asset is ImageAsset) {
    //   if (asset.name == "cardIcon") {
    //     loadCardIcon(asset, "");
    //     return true;
    //   } else if (asset.name == "cardFrame") {
    //     // loadCardFrame(asset, null);
    //     return true;
    //   }
    // }
    if (asset is FontAsset) {
      loadFont(asset);
      return true;
    }
    return false; // load the default embedded asset
  }

  void updateRiveText(String name, String value) {
    name += "Text";
    if (_artboard == null) return;
    _artboard!.component<TextValueRun>(name)?.text = value;
    // _artboard!.component<TextValueRun>("${name}_stroke")?.text = value;
    // _artboard!.component<TextValueRun>("${name}_shadow")?.text = value;
  }

  void onRiveEvent(RiveEvent event) {
    var state = switch (event.name) {
      "waiting" => FeastState.waiting,
      "started" => FeastState.started,
      "shown" => FeastState.shown,
      "closing" => FeastState.closing,
      "closed" => FeastState.closed,
      _ => FeastState.none,
    };
    if (state == FeastState.none) return;
    this.state = state;
    if (state == FeastState.waiting) {
      if (result != null) {
        startInput?.value = true;
      }
    } else if (state == FeastState.started) {
      // serviceLocator<Sounds>().stop("reward");
      // serviceLocator<Sounds>().play(startSFX);
      WidgetsBinding.instance
          .addPostFrameCallback((t) => _progressbarNotifier.value = false);
    } else if (state == FeastState.closed) {
      WidgetsBinding.instance.addPostFrameCallback((t) => dismiss());
    }
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
    var bytes = await rootBundle.load('assets/fonts/dnd_vazir_round_bold.ttf');
    var font = await FontAsset.parseBytes(bytes.buffer.asUint8List());
    asset.font = font;
  }

  process(Future<dynamic> Function() callback) async {
    try {
      result = await callback.call();
      if (state == FeastState.waiting) {
        startInput?.value = true;
      }
    } on SkeletonException {
      if (context.mounted) {
        await Future.delayed(const Duration(milliseconds: 10));
        rethrow;
      }
      dismiss();
    }
  }

  void dismiss() {
    if (state.index < FeastState.disposed.index) {
      state = FeastState.disposed;
    }
  }

  Widget _progressbarBuilder() => ValueListenableBuilder(
      valueListenable: _progressbarNotifier,
      builder: (context, value, child) {
        if (value) {
          return Container(
            width: 128.d,
            height: 128.d,
            alignment: const Alignment(0, 0.65),
            child: Asset.load<RiveAnimation>(
              "progressbar",
              fit: BoxFit.cover,
              onRiveInit: (Artboard artboard) {
                final controller = StateMachineController.fromArtboard(
                    artboard, "State Machine 1");
                artboard.addController(controller!);
              },
            ),
          );
        }
        return const SizedBox();
      });

  void onScreenTouched() {
    if (state.index <= FeastState.waiting.index) return;
    if (state == FeastState.started) {
      skipInput?.value = true;
    } else if (state == FeastState.shown) {
      onRiveEvent(
          const RiveEvent(name: "closing", secondsDelay: 0, properties: {}));
      closeInput?.value = true;
    }
  }
}
