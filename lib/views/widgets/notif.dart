import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class Notif extends StatefulWidget {
  final NotifData message;
  final VoidCallback? onClose;
  final VoidCallback? onTap;
  final double bottom;

  const Notif({
    required this.message,
    required this.bottom,
    this.onTap,
    this.onClose,
    super.key,
  });

  @override
  State<Notif> createState() => NotifState();
}

class NotifState extends State<Notif> with SingleTickerProviderStateMixin {
  RxBool isMinimize = true.obs;
  double bottom = 0;
  double size = 0;

  Artboard? _artboard;
  SMITrigger? _closeTrigger;
  SMIBool? _minimizeInput;
  SMINumber? _timerInput;
  SMINumber? _modeInput;

  late final AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );

  NoobMessage get message => widget.message.message;

  @override
  void initState() {
    bottom = widget.bottom;
    controller.forward();
    initData();
    super.initState();
  }

  void initData() async {
    widget.message.remainingTime.listen((value) {
      _timerInput?.value = value.toDouble();

      if (value == 0) {
        if (_timerInput != null) {
          _closeTrigger?.fire();
        }
      }
    });
  }

  changePosition(double newPosition) {
    setState(() {
      bottom = newPosition;
    });
  }

  hide() {
    setState(() {
      isMinimize.value = true;
      widget.message.isMinimize = true;
      _minimizeInput!.value = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    isMinimize.value = widget.message.isMinimize;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      right: Localization.isRTL ? null : size,
      left: Localization.isRTL ? size : null,
      bottom: bottom,
      child: SizeTransition(
        sizeFactor: Tween<double>(begin: 0.0, end: 1.0).animate(controller),
        axis: Axis.vertical,
        axisAlignment: -1,
        child: GestureDetector(
          onTap: () {
            if (_minimizeInput == null) {
              return;
            }
            if (isMinimize.value == true) {
              isMinimize.value = false;
              widget.message.isMinimize = false;
              _minimizeInput!.value = false;
              return;
            }
            if (widget.onTap != null) widget.onTap!();
          },
          child: Widgets.rect(
            width: 487.d,
            height: 150.d,
            margin: const EdgeInsets.only(bottom: 10),
            child: LoaderWidget(
              AssetType.animation,
              "toast_message",
              fit: BoxFit.cover,
              riveAssetLoader: onRiveAssetLoad,
              onRiveInit: (artboard) => onRiveInit(artboard, "State Machine 1"),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is FontAsset) {
      loadFont(asset);
      return true;
    }
    return false;
  }

  Future<void> loadFont(FontAsset asset) async {
    var bytes = await rootBundle.load('assets/fonts/${asset.name}');
    var font = await FontAsset.parseBytes(bytes.buffer.asUint8List());
    asset.font = font;
  }

  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    _artboard = artboard;
    var controller =
        StateMachineController.fromArtboard(artboard, stateMachineName)!;

    _closeTrigger = controller.findInput<bool>("close") as SMITrigger;
    _minimizeInput = controller.findInput<bool>("minimize") as SMIBool;
    _timerInput = controller.findInput<double>("timer") as SMINumber;
    _modeInput = controller.findInput<double>("mode") as SMINumber;

    updateRiveText("titleText", widget.message.title);
    updateRiveText("captionText", widget.message.caption);

    _modeInput?.value = (widget.message.mode ?? 0).toDouble();
    _minimizeInput?.value = widget.message.isMinimize;

    controller.addEventListener(_riveEventsListener);
    artboard.addController(controller);
    return controller;
  }

  void updateRiveText(String name, String value) {
    if (_artboard == null) return;
    _artboard!.component<TextValueRun>(name)?.text = value;
  }

  void _riveEventsListener(RiveEvent event) {
    if (event.name == "closed") {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    }
  }
}
