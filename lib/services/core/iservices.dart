import 'package:flutter/material.dart';

abstract class IService {
  bool isInitialized = false;
  initialize({List<Object>? args}) => isInitialized = true;

  String accumulatedLog = "";
  void log(dynamic log) {
    accumulatedLog += "\n[$this]: $log";
    debugPrint(log);
  }
}
