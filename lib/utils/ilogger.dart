import 'package:flutter/material.dart';

mixin ILogger {
  static String accumulatedLog = "";
  void log(dynamic log) {
    slog(this, log);
  }

  static void slog(source, log) {
    accumulatedLog += "\n[$source]: $log";
    debugPrint(log);
  }
}
