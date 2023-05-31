import 'package:flutter/material.dart';
import 'core/iservices.dart';

abstract class GameApisService extends IService {
  connect();
  disconnect();
}

class MainGameApi implements GameApisService {
  @override
  initialize({List<Object>? args}) async {}

  @override
  connect() async {}

  @override
  disconnect() async {}

  @override
  log(log) {
    debugPrint(log);
  }
}
