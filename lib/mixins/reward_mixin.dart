import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../view/overlays/ioverlay.dart';
import '../blocs/services_bloc.dart';
import '../data/core/fruit.dart';
import '../data/core/result.dart';
import '../services/deviceinfo.dart';
import '../services/localization.dart';
import '../services/sounds.dart';
import '../utils/assets.dart';
import '../view/route_provider.dart';
import '../view/widgets.dart';
import '../view/widgets/loaderwidget.dart';

enum RewardAniationState {
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
  late Artboard _artboard;
  List<Widget> children = [];
  String waitingSFX = "waiting", startSFX = "levelup";
  SMITrigger? startInput, skipInput, closeInput;
  RewardAniationState state = RewardAniationState.none;
  final ValueNotifier<bool> _progressbarNotifier = ValueNotifier(true);

  List<Widget> appBarElementsLeft() => [];

  @override
  void initState() {
    if (waitingSFX.isNotEmpty) {
      BlocProvider.of<ServicesBloc>(context)
          .get<Sounds>()
          .play(waitingSFX, channel: "reward");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    items.addAll(children);
    items.add(_progressbarBuilder());
    return Widgets.button(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        width: DeviceInfo.size.width,
        height: DeviceInfo.size.height,
        child: Stack(children: items),
        onPressed: () {
          if (state.index <= RewardAniationState.waiting.index) return;
          if (state == RewardAniationState.started) {
            skipInput?.value = true;
          } else if (state == RewardAniationState.shown) {
            onRiveEvent(const RiveEvent(
                name: "closing", secondsDelay: 0, properties: {}));
            closeInput?.value = true;
          }
        });
  }

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
    var state = switch (event.name) {
      "waiting" => RewardAniationState.waiting,
      "started" => RewardAniationState.started,
      "shown" => RewardAniationState.shown,
      "closing" => RewardAniationState.closing,
      "closed" => RewardAniationState.closed,
      _ => RewardAniationState.none,
    };
    if (state == RewardAniationState.none) return;
    this.state = state;
    if (state == RewardAniationState.waiting) {
      if (result != null) {
        startInput?.value = true;
      }
    } else if (state == RewardAniationState.started) {
      BlocProvider.of<ServicesBloc>(context).get<Sounds>().stop("reward");
      BlocProvider.of<ServicesBloc>(context).get<Sounds>().play(startSFX);
      WidgetsBinding.instance
          .addPostFrameCallback((t) => _progressbarNotifier.value = false);
    } else if (state == RewardAniationState.closed) {
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
      if (state == RewardAniationState.waiting) {
        startInput?.value = true;
      }
    } on RpcException catch (e) {
      if (context.mounted) {
        dismiss();
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

  void dismiss() {
    if (state.index < RewardAniationState.disposed.index) {
      Overlays.remove(widget.type);
      state = RewardAniationState.disposed;
    }
  }

  Widget _progressbarBuilder() => ValueListenableBuilder(
      valueListenable: _progressbarNotifier,
      builder: (context, value, child) {
        if (value) {
          return Align(
              alignment: const Alignment(0, 0.65),
              child: LoaderWidget(AssetType.animation, "progressbar",
                  width: 128.d, height: 128.d));
        }
        return const SizedBox();
      });
}
