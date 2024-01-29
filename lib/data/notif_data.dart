import 'dart:async';
import 'package:get/get.dart';

import '../app_export.dart';

class NotifData {
  final NoobMessage message;
  final String title;
  final String caption;
  final int? mode;
  bool isMinimize;
  RxInt remainingTime = 100.obs;
  late Timer _timer;

  NotifData({
    required this.message,
    required this.title,
    required this.caption,
    this.mode,
    this.isMinimize = true,
  }) {
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      remainingTime.value--;

      if (remainingTime.value == 0) {
        timer.cancel();
        _timer.cancel();
      }
    });
  }
}
