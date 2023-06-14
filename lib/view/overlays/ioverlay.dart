import 'package:flutter/material.dart';
import 'package:flutter_skeleton/view/overlays/loading_overlay.dart';

enum OverlayType {
  none,
  loading,
  outcome,
}

extension Overlays on OverlayType {
  static AbstractOverlay getWidget(String routeName, {List<Object>? args}) {
    return switch (routeName) {
      "/loading" => const LoadingOverlay(),
      _ => const AbstractOverlay(type: OverlayType.none),
    };
  }

  String get name {
    return switch (this) {
      OverlayType.loading => "loading",
      OverlayType.outcome => "outcome",
      _ => "none",
    };
  }

  String get routeName => "/$name";

  static final _entries = <OverlayType, OverlayEntry>{};
  static insert(BuildContext context, OverlayType type, {List<Object>? args}) {
    if (!_entries.containsKey(type.name)) {
      _entries[type] =
          OverlayEntry(builder: (c) => getWidget(type.routeName, args: args));
      Overlay.of(context).insert(_entries[type]!);
    }
  }

  static remove(OverlayType overlay) {
    if (_entries.containsKey(overlay.name)) {
      _entries[overlay.name]?.remove();
      _entries.remove(overlay.name);
    }
  }
}

class AbstractOverlay extends StatefulWidget {
  final OverlayType type;
  const AbstractOverlay({this.type = OverlayType.none, super.key});

  @override
  createState() => AbstractOverlayState();
}

class AbstractOverlayState<T extends AbstractOverlay> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  void close() {
    Overlays.remove(widget.type);
  }
}
