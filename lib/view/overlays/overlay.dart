import 'package:flutter/material.dart';

import '../../mixins/logger.dart';
import '../../mixins/service_provider.dart';
import '../../services/localization.dart';
import '../../view/overlays/confirm_overlay.dart';
import 'chat_options_overlay.dart';
import 'feast_attack_overlay.dart';
import 'feast_enhance_overlay.dart';
import 'feast_evolve_overlay.dart';
import 'feast_levelup_overlay.dart';
import 'feast_openpack_overlay.dart';
import 'feast_purchase_overlay.dart';
import 'feast_upgrade_card_overlay.dart';
import 'loading_overlay.dart';
import 'member_details_overlay.dart';
import 'toast_overlay.dart';

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
  feastUpgradeCard,
}

extension Overlays on OverlayType {
  static AbstractOverlay getWidget(
    String routeName, {
    dynamic args,
    Function(dynamic data)? onClose,
  }) {
    return switch (routeName) {
      "/loading" => const LoadingOverlay(),
      "/chatOptions" =>
        ChatOptionsOverlay(y: args[0], options: args[1], onSelect: args[2]),
      "/confirm" => ConfirmOverlay(
          args["message"],
          args["acceptLabel"] ?? "accept_l".l(),
          args["declineLabel"] ?? "decline_l".l(),
          args["onAccept"]),
      "/member" => MemberOverlay(args[0], args[1], args[2]),
      "/toast" => ToastOverlay(args as String),
      "/waiting" => ToastOverlay(args as String),
      "/feastAttack" => AttackFeastOverlay(args: args ?? {}, onClose: onClose),
      "/feastLevelup" =>
        LevelupFeastOverlay(args: args ?? {}, onClose: onClose),
      "/feastOpenpack" =>
        OpenPackFeastOverlay(args: args ?? {}, onClose: onClose),
      "/feastEnhance" =>
        EnhanceFeastOverlay(args: args ?? {}, onClose: onClose),
      "/feastEnhancemax" =>
        PurchaseFeastOverlay(args: args ?? {}, onClose: onClose),
      "/feastEvolve" => EvolveFeastOverlay(args: args ?? {}, onClose: onClose),
      "/feastPurchase" =>
        PurchaseFeastOverlay(args: args ?? {}, onClose: onClose),
      "/feastUpgradeCard" =>
        UpgradeCardFeastOverlay(args: args ?? {}, onClose: onClose),
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
    }
    Overlay.of(context).insert(_entries[type]!);
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
  final Function(dynamic data)? onClose;
  const AbstractOverlay(
      {this.type = OverlayType.none, this.onClose, super.key});

  @override
  createState() => AbstractOverlayState();
}

class AbstractOverlayState<T extends AbstractOverlay> extends State<T>
    with ILogger, ServiceProviderMixin {
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