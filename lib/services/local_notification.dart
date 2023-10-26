// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/core/account.dart';
import '../services/iservices.dart';
import '../services/localization.dart';
import '../utils/ilogger.dart';

class LocalNotification extends IService {
  static bool granted = false;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  initialize({List<Object>? args}) async {
    final StreamController<String?> selectNotificationStream = StreamController<
        String?>.broadcast(); // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project

    // Android
    const androidSettings = AndroidInitializationSettings('app_icon');

    // mac and iOS
    const darwinNotificationCategoryPlain = 'plainCategory';
    const navigationActionId = 'id_3';
    @pragma('vm:entry-point')
    void notificationTapBackground(NotificationResponse notificationResponse) {
      log('notification(${notificationResponse.id}) action tapped:  ${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
      if (notificationResponse.input?.isNotEmpty ?? false) {
        log('notification action tapped with input: ${notificationResponse.input}');
      }
    }

    final darwinNotificationCategories = <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text('id_1', 'Awesome',
              buttonTitle: 'Ok', placeholder: 'Are you ready?'),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];

    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        // didReceiveLocalNotificationStream.add(ReceivedNotification(
        //     id: id, title: title, body: body, payload: payload));
      },
      notificationCategories: darwinNotificationCategories,
    );

    // Linux
    final linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );

    var initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }
            break;
        }
      },
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    await _requestPermissions();
    skedule(args![0] as Account);
  }

  _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    } else if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      granted = await androidImplementation?.requestPermission() ?? false;
    }
  }

  void skedule(Account account) async {
    int nextDailyGiftAt = 0, maxCooldown = 0;
    if (account.dailyReward != null) {
      nextDailyGiftAt = account.dailyReward["next_reward_at"];
    }
    maxCooldown = account.calculateMaxCooldown();

    tz.initializeTimeZones();
    // Set localation
    var now = DateTime.now();
    var locations = tz.timeZoneDatabase.locations.values;
    var tzo = now.timeZoneOffset.inMilliseconds;
    for (var l in locations) {
      if (l.currentTimeZone.offset == tzo) tz.setLocalLocation(l);
    }

    // Sleep message
    var sleep = tz.TZDateTime.from(
        DateTime(now.year, now.month, now.day, 23), tz.local);

    // Weekend message
    var date = DateTime(now.year, now.month, now.day, 10);
    while (date.weekday != 6 || date.isBefore(now)) {
      date = date.add(const Duration(days: 1));
    }
    var weekend = tz.TZDateTime.from(date, tz.local);

    // Message map
    var messages = <_MSG>[];
    const hourSeconds = 3600;
    for (var h = 1; h <= 3; h++) {
      var title = "${_r(h)}";
      messages.add(_MSG(title, _getTime(h * 8 * hourSeconds)));
    }
    for (var d = 1; d < 7; d++) {
      messages.add(_MSG("${_r(d)}", _getTime(d * 24 * hourSeconds)));
    }
    for (var d = 10; d < 22; d += 3) {
      messages.add(_MSG("${_r(d)}", _getTime(d * 24 * hourSeconds)));
    }
    if (maxCooldown > 0) {
      messages.add(_MSG("cooldown", _getTime(maxCooldown)));
    }
    if (nextDailyGiftAt > 0) {
      messages.add(_MSG("daily", _getTime(nextDailyGiftAt)));
    }
    if (sleep.millisecondsSinceEpoch > now.millisecondsSinceEpoch) {
      messages.add(_MSG("sleep", sleep));
    }
    messages.add(_MSG("weekend", weekend));

    // Schedule
    var index = 0;
    const details = AndroidNotificationDetails('reminder', 'Reminder');
    await _flutterLocalNotificationsPlugin.cancelAll();
    for (var msg in messages) {
      var title = "${"notif_${msg.key}_head".l()} ${_getRandomFruit()}";
      var body = "notif_${msg.key}_body".l();
      await _flutterLocalNotificationsPlugin.zonedSchedule(index, title, body,
          msg.time, const NotificationDetails(android: details),
          // androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
      log("${msg.key} index $index title $title body: $body time ${msg.time}");
      ++index;
    }
  }

  static tz.TZDateTime _getTime(int seconds) {
    return tz.TZDateTime.from(DateTime.now(), tz.local)
        .add(Duration(seconds: seconds));
  }

  static Future<dynamic> onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    ILogger.slog(
        LocalNotification, "Noti: title $title body $body payload: $payload");
  }

  static Future<dynamic> onSelectNotification(String? payload) async {
    if (payload != null) {
      ILogger.slog(LocalNotification, 'Noti: notification payload: $payload');
    }
  }

  static _r(int i) => (i % 4);

  String _getRandomFruit() {
    var fruits = [
      "🍓",
      "🍒",
      "🍎",
      "🍉",
      "🍑",
      "🍊",
      "🥭",
      "🍍",
      "🍌",
      "🥥",
      "🍇",
      "🫐",
      "🫒",
      "🥝",
      "🍐",
      "🍏",
      "🍈",
      "🍋",
      "🍅",
      "🌶️",
      "🫚",
      "🥕",
      "🍠",
      "🧅",
      "🌽",
      "🥦",
      "🥒",
      "🌰",
      "🫘",
      "🥔",
      "🧄",
      "🍆",
      "🥑",
      "🫑",
      "🫛",
      "🥬"
    ];
    var string = "";
    for (var i = 0; i < 3; i++) {
      string += fruits[math.Random().nextInt(fruits.length)];
    }
    return string;
  }
}

class _MSG {
  final String key;
  final tz.TZDateTime time;
  _MSG(this.key, this.time);
}
