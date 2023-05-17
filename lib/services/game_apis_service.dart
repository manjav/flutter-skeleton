import '../models/game_api_model.dart';
import 'core/iservices.dart';

abstract class GameApisService extends IService {
  // Future<GameApi> initialize();
  Future<GameApi> connect();
  Future<GameApi> disconnect();
  printTest();
}

class MainAPI implements GameApisService {
  @override
  printTest() {
    print("game api print");
  }

  @override
  Future<GameApi> initialize() async {
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
}
