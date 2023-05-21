import 'package:flutter/material.dart';
import 'core/iservices.dart';

abstract class GameApisService extends IService {
  connect();
  disconnect();
}

class MainGameApi implements GameApisService {
  @override
  initialize({List<Object>? args}) async {
    await Future.delayed(const Duration(seconds: 2));
    debugPrint("game api init");
  }

  @override
  connect() async {
    await Future.delayed(const Duration(seconds: 5));
    return true;
  }

  @override
  disconnect() async {
    // var serverData = {"gold": 2, "nektar": 2};
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  log(log) {
    debugPrint(log);
  }
}
