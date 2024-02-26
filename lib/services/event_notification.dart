import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../app_export.dart';

class EventNotification extends IService {
  @override
  initialize({List<Object>? args}) {}

  Map<GlobalKey<NotifState>, OverlayEntry> notifications = {};
  List<String> onlines = [];

  void showNotif(NotifData data, BuildContext context) {
    var key = GlobalKey<NotifState>();
    var notif = Notif(
      key: key,
      message: data,
      bottom: 400.d,
      onClose: () {
        notifications[key]?.remove();
        notifications.remove(key);
        _animateNotifications();
      },
      onTap: data.onTap,
    );
    var entry = OverlayEntry(
      builder: (ctx) => notif,
    );

    notifications[key] = entry;

    Overlay.of(context).insert(entry);
    _animateNotifications();
  }

  void _animateNotifications() {
    int index = 0;
    for (var entry in notifications.keys) {
      var add = ((notifications.length - 1 - index) * 150.d);
      var bottom = 400.d + add;
      entry.currentState?.changePosition(bottom);
      index++;
    }
  }

  void hideNotif(NoobMessage data) {
    var notif = notifications.keys
        .firstWhereOrNull((element) => element.currentState?.message == data);
    notifications[notif]?.remove();
    notif?.currentState?.hide();
  }

  void hideAllNotif() {
    for (var entry in notifications.keys) {
      notifications[entry]?.remove();
      entry.currentState?.hide();
    }
  }

  void addStatus(String playerName, BuildContext context) async {
    onlines.add(playerName);
    if (onlines.length > 1) return;

    _showStatus(context);
  }

  void _showStatus(BuildContext context) async {
    if (onlines.isEmpty) return;

    OverlayEntry? entry;
    String title = onlines.first;
    var status = OnlineStatus(
      text: title,
      onClose: () {
        entry?.remove();
        onlines.removeAt(0);
        // ignore: use_build_context_synchronously
        _showStatus(context);
      },
    );

    entry = OverlayEntry(
      builder: (ctx) => status,
    );

    Overlay.of(context).insert(entry);
  }
}
