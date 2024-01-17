import 'package:flutter/material.dart';

import '../../../app_export.dart';
import '../loading_overlay.dart';

class Overlays {
  static final _entries = <String, OverlayEntry>{};

  static insert(BuildContext context, AbstractOverlay overlay) {
    if (!_entries.containsKey(overlay.route)) {
      var entry = OverlayEntry(builder: (c) => overlay);
      _entries[overlay.route] = entry;
      Overlay.of(context).insert(entry);
    }
  }

  static remove(AbstractOverlay overlay) {
    if (_entries.containsKey(overlay.route)) {
      _entries[overlay.route]?.remove();
      _entries.remove(overlay.route);
    }
  }

  static void clear() => _entries.clear();
}

class AbstractOverlay extends StatefulWidget {
  final String route;
  final Function(dynamic data)? onClose;

  const AbstractOverlay({this.route = "", this.onClose, super.key});

  @override
  createState() => AbstractOverlayState();
}

class AbstractOverlayState<T extends AbstractOverlay> extends State<T>
    with ILogger, ServiceFinderWidgetMixin {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  void close() {
    Overlays.remove(widget);
  }

  void toast(String message) => Overlays.insert(context, ToastOverlay(message));
}
