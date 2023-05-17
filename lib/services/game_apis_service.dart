import 'package:flutter/material.dart';

import '../models/game_api_model.dart';
import 'core/iservices.dart';

abstract class GameApisService extends IService {
  Future<GameApi> connect();
  Future<GameApi> disconnect();
}

class MainAPI implements GameApisService {
  @override
  Future<GameApi> initialize({List<Object>? args}) async {
    // var serverData = {"gold": 12, "nektar": 3};
    await Future.delayed(const Duration(seconds: 1));
    return GameApi(data: {"gold": 1});
  }

  @override
  Future<GameApi> connect() async {
    var serverData = {"gold": 1, "nektar": 1};
    await Future.delayed(const Duration(seconds: 1));
    return GameApi(data: serverData);
  }

  @override
  Future<GameApi> disconnect() async {
    var serverData = {"gold": 2, "nektar": 2};
    await Future.delayed(const Duration(seconds: 1));
    return GameApi(data: serverData);
  }

  @override
  log(log) {
    debugPrint(log);
  }
}
