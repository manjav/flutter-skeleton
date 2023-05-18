import 'package:flutter/material.dart';
import 'core/iservices.dart';

abstract class GameApisService extends IService {
  connect();
  disconnect();
}

class MainAPI implements GameApisService {
  @override
  initialize({List<Object>? args}) async {
    // var serverData = {"gold": 12, "nektar": 3};
    return true;
  }

  @override
  connect() async {
    // var serverData = {"gold": 1, "nektar": 1};
    await Future.delayed(const Duration(seconds: 1));
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
