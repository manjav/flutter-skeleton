import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../app_export.dart';

enum RewardAnimationState {
  none,
  waiting,
  started,
  shown,
  closing,
  closed,
  disposed
}

mixin RewardScreenMixin<T extends AbstractOverlay> on State<T> {
  dynamic result;
  Artboard? _artboard;
  List<Widget> children = [];
  String waitingSFX = "waiting", startSFX = "levelup";
  SMITrigger? startInput, skipInput, closeInput;
  RewardAnimationState state = RewardAnimationState.none;
  final ValueNotifier<bool> progressbarNotifier = ValueNotifier(true);
  AnimationController? closeButtonController;

  List<Widget> appBarElementsLeft() => [];

  @override
  void initState() {
    if (waitingSFX.isNotEmpty) {
      serviceLocator<Sounds>().play(waitingSFX, channel: "reward");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    items.addAll(children);
    items.add(_progressbarBuilder());
    items.add(closeButton());
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
    startInput = controller.findInput<bool>("start") as SMITrigger?;
    skipInput = controller.findInput<bool>("skip") as SMITrigger?;
    closeInput = controller.findInput<bool>("close") as SMITrigger?;
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
    if (_artboard == null) return;
    _artboard!.component<TextValueRun>(name)?.text = value;
    _artboard!.component<TextValueRun>("${name}_stroke")?.text = value;
    _artboard!.component<TextValueRun>("${name}_shadow")?.text = value;
  }

  void onRiveEvent(RiveEvent event) {
    var state = switch (event.name) {
      "waiting" => RewardAnimationState.waiting,
      "started" => RewardAnimationState.started,
      "shown" => RewardAnimationState.shown,
      "closing" => RewardAnimationState.closing,
      "closed" => RewardAnimationState.closed,
      _ => RewardAnimationState.none,
    };
    if (state == RewardAnimationState.none) return;
    this.state = state;
    if (state == RewardAnimationState.waiting) {
      if (result != null) {
        startInput?.value = true;
      }
    } else if (state == RewardAnimationState.started) {
      // serviceLocator<Sounds>().stop("reward");
      if (startSFX.isNotEmpty) {
        serviceLocator<Sounds>().play(startSFX);
      }
      WidgetsBinding.instance
          .addPostFrameCallback((t) => progressbarNotifier.value = false);
    } else if (state == RewardAnimationState.closed) {
      WidgetsBinding.instance.addPostFrameCallback((t) => dismiss());
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
      if (state == RewardAnimationState.waiting) {
        startInput?.value = true;
      }
    } on SkeletonException catch (e) {
      if (context.mounted) {
        await Future.delayed(const Duration(milliseconds: 10));
        dismiss();
        await serviceLocator<RouteService>().to(
          Routes.popupMessage,
          args: {"title": "error".l(), "message": "error_${e.statusCode}".l()},
        );
      }
    }
  }

  void dismiss() {
    widget.onClose?.call(result);
    if (state.index < RewardAnimationState.disposed.index) {
      Overlays.remove(widget.route);
      state = RewardAnimationState.disposed;
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  Widget _progressbarBuilder() => ValueListenableBuilder(
      valueListenable: progressbarNotifier,
      builder: (context, value, child) {
        if (value) {
          return Align(
              alignment: const Alignment(0, 0.65),
              child: LoaderWidget(AssetType.animation, "progressbar",
                  width: 128.d, height: 128.d));
        }
        return const SizedBox();
      });

  void onScreenTouched() {
    if (state.index <= RewardAnimationState.waiting.index) return;
    if (state == RewardAnimationState.started) {
      skipInput?.value = true;
    } else if (state == RewardAnimationState.shown) {
      onRiveEvent(
          const RiveEvent(name: "closing", secondsDelay: 0, properties: {}));
      closeInput?.value = true;
      closeButtonController?.reverse();
    }
  }

  Widget closeButton() {
    return Positioned(
      right: 100.d,
      top: 250.d,
      child: GestureDetector(
        onTap: () {
          onRiveEvent(const RiveEvent(
              name: "closing", secondsDelay: 0, properties: {}));
          closeInput?.value = true;
          closeButtonController?.reverse();
        },
        child: Asset.load<Image>("close", height: 56.d, width: 56.d),
      )
          .animate(
            onInit: (controller) => closeButtonController = controller,
          )
          .fade(duration: 300.ms, delay: 500.ms),
    );
  }
}
