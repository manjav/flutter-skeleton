import 'package:flutter/material.dart';

abstract class IService {
  bool isInitialized = false;
  initialize({List<Object>? args}) {
    isInitialized = true;
    log("initialized.");
  }

  static String accumulatedLog = "";
  void log(dynamic log) {
    slog(this, log);
  }

  static void slog(source, log) {
    accumulatedLog += "\n[$source]: $log";
    debugPrint(log);
  }
}
