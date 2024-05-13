import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_export.dart';

class Overlays {
  static final _entries = <String, OverlayEntry>{};

  static insert(BuildContext context, AbstractOverlay overlay) {
    if (!_entries.containsKey(overlay.route)) {
      var entry = OverlayEntry(builder: (c) => overlay);
      _entries[overlay.route] = entry;
      Overlay.of(Get.overlayContext!).insert(entry);
    }
  }

  static remove(String route) {
    if (_entries.containsKey(route)) {
      _entries[route]?.remove();
      _entries.remove(route);
    }
  }

  static closeAll({String except = ""}) {
    _entries.forEach((key, value) {
      if (key != except) {
        _entries[key]?.remove();
        _entries[key]?.dispose();
      }
    });
    _entries.removeWhere((key, value) => key != except);
  }

  static void clear() => _entries.clear();

  static int get count => _entries.length;
}

class AbstractOverlay extends StatefulWidget {
  final String route;
  final Function(dynamic data)? onClose;

  const AbstractOverlay({this.route = "", this.onClose, super.key});

  @override
  createState() => AbstractOverlayState();
}

class AbstractOverlayState<T extends AbstractOverlay> extends State<T>
    with ILogger, ServiceFinderWidgetMixin, ClassFinderWidgetMixin {
  @override
  void initState() {
    serviceLocator<TutorialManager>().onFinish.listen((data) {
      onTutorialFinish(data);
    });
    serviceLocator<TutorialManager>().onStepChange.listen((data) {
      onTutorialStep(data);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  bool get isTutorial =>
      serviceLocator.get<TutorialManager>().isTutorial(widget.route);

  checkTutorial() {
    serviceLocator<TutorialManager>().checkToturial(context, widget.route);
  }

  void onTutorialFinish(dynamic data) {}
  void onTutorialStep(dynamic data) {}

  void close() {
    Overlays.remove(widget.route);
  }

  void toast(String message) => Overlays.insert(context, ToastOverlay(message));
}
