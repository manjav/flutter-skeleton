import 'package:flutter/material.dart';

abstract class IService {
  bool isInitialized = false;
  initialize({List<Object>? args}) => isInitialized = true;

  String accumulatedLog = "";
  void log(dynamic log) {
    serviceLog(this, log);
  }

  void serviceLog(IService source, log) {
    accumulatedLog += "\n[$source]: $log";
    log(log);
  }
}
