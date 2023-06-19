import '../../blocs/player_bloc.dart';
import '../../services/core/infra.dart';
import 'http_connection.dart';

class FakeConnector extends HttpConnection {
  @override
  Future<Result<T>> rpc<T>(RpcId id, {Map? params}) async {
    if (id == RpcId.playerLoad) {
      return Result<T>(Responses.success, 'Player loaded.',
          PlayerData(id: "fs_sdf_123msdf", name: "Player Name") as T);
    }
    return await super.rpc(id, params: params);
  }
}
