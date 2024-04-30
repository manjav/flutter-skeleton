import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../app_export.dart';

class EventNotification extends IService {
  @override
  initialize({List<Object>? args}) {}

  Map<GlobalKey<NotifState>, OverlayEntry> notifications = {};
  List<String> onlines = [];

  void showNotif(NotifData data, BuildContext context,
      {bool isTutorial = false}) {
    var key = GlobalKey<NotifState>();
    var notif = Notif(
      key: key,
      message: data,
      bottom: isTutorial ? 800.d : 400.d,
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
    notif?.currentState?.hide();
    notifications[notif]?.remove();
    notifications.remove(notif);
  }

  void hideAllNotif() {
    for (var entry in notifications.keys) {
      entry.currentState?.hide();
      notifications[entry]?.remove();
    }
    notifications.clear();
  }

  void openAllNotif() {
    for (var entry in notifications.keys) {
      entry.currentState?.show();
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
        _showStatus(context);
      },
    );

    entry = OverlayEntry(
      builder: (ctx) => status,
    );

    Overlay.of(context).insert(entry);
  }
}
