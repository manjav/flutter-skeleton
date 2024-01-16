import 'package:flutter/material.dart';

import '../../../app_export.dart';
import '../loading_overlay.dart';

enum OverlayType {
  none,
  loading,
  chatOptions,
  confirm,
  member,
  outcome,
  toast,
  waiting,

  feastAttack,
  feastEvolve,
  feastLevelup,
  feastEnhance,
  feastOpenpack,
  feastPurchase,
  feastUpgrade,
  feastUpgradeCard,
}

extension Overlays on OverlayType {
  static AbstractOverlay getWidget(
    String routeName, {
    dynamic args,
    Function(dynamic data)? onClose,
  }) {
    //todo: check routes here
    return switch (routeName) {
      "/loading" => const LoadingOverlay(),
      "/confirm" => ConfirmOverlay(
          args["message"],
          args["acceptLabel"] ?? "accept_l".l(),
          args["declineLabel"] ?? "decline_l".l(),
          args["onAccept"],
          barrierDismissible: args["barrierDismissible"] ?? true),
      "/toast" => ToastOverlay(args as String),
      "/waiting" => ToastOverlay(args as String),
      _ => const AbstractOverlay(),
    };
  }

  String get routeName => "/$name";

  static final _entries = <OverlayType, OverlayEntry>{};
  static insert(BuildContext context, OverlayType type,
      {dynamic args, Function(dynamic)? onClose}) {
    if (!_entries.containsKey(type)) {
      _entries[type] = OverlayEntry(
          builder: (c) =>
              getWidget(type.routeName, args: args, onClose: onClose));
      Overlay.of(context).insert(_entries[type]!);
    }
  }

  static remove(OverlayType type) {
    if (_entries.containsKey(type)) {
      _entries[type]?.remove();
      _entries.remove(type);
    }
  }

  static void clear() => _entries.clear();
}

class AbstractOverlay extends StatefulWidget {
  final OverlayType type;
  final Function(dynamic data)? onClose;
  const AbstractOverlay(
      {this.type = OverlayType.none, this.onClose, super.key});

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
    Overlays.remove(widget.type);
  }

  void toast(String message) =>
      Overlays.insert(context, OverlayType.toast, args: message);
}
