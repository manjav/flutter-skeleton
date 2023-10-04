import 'package:flutter/material.dart';

import '../../utils/ilogger.dart';
import 'loading_overlay.dart';
import 'member_details_overlay.dart';
import 'toast_overlay.dart';

enum OverlayType {
  none,
  loading,
  member,
  outcome,
  toast,
  waiting,
}

extension Overlays on OverlayType {
  static AbstractOverlay getWidget(String routeName, {dynamic args}) {
    return switch (routeName) {
      "/loading" => const LoadingOverlay(),
      "/member" => MemberOverlay(args[0], args[1], args[2]),
      "/toast" => ToastOverlay(args as String),
      "/waiting" => ToastOverlay(args as String),
      _ => const AbstractOverlay(),
    };
  }

  String get routeName => "/$name";

  static final _entries = <OverlayType, OverlayEntry>{};
  static insert(BuildContext context, OverlayType type, {dynamic args}) {
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
