import 'package:flutter/material.dart';

import '../../utils/ilogger.dart';
import '../../view/overlays/loading_overlay.dart';

enum OverlayType {
  none,
  loading,
  outcome,
}

extension Overlays on OverlayType {
  static AbstractOverlay getWidget(String routeName, {List<Object>? args}) {
    return switch (routeName) {
      "/loading" => const LoadingOverlay(),
      _ => const AbstractOverlay(),
    };
  }

  String get routeName => "/$name";

  static final _entries = <OverlayType, OverlayEntry>{};
  static insert(BuildContext context, OverlayType type, {List<Object>? args}) {
    if (!_entries.containsKey(type)) {
      _entries[type] =
          OverlayEntry(builder: (c) => getWidget(type.routeName, args: args));
      Overlay.of(context).insert(_entries[type]!);
    }
  }

  static remove(OverlayType type) {
    if (_entries.containsKey(type)) {
      _entries[type]?.remove();
      _entries.remove(type);
    }
  }
}

class AbstractOverlay extends StatefulWidget {
  final OverlayType type;
  const AbstractOverlay({this.type = OverlayType.none, super.key});

  @override
  createState() => AbstractOverlayState();
}

class AbstractOverlayState<T extends AbstractOverlay> extends State<T>
    with ILogger {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  void close() {
    Overlays.remove(widget.type);
  }
}
