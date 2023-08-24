import 'dart:convert';

import 'package:tcp_socket_connection/tcp_socket_connection.dart';

import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/rpc_data.dart';
import '../../services/iservices.dart';
import '../../utils/utils.dart';

enum NoobCommand { subscribe, unsubscribe }

extension NoobCommandExtension on NoobCommand {
  String get value => name.toUpperCase();
}

class NoobSocket extends IService {
  Function(NoobMessage)? onMessageReceive;
  late TcpSocketConnection _socketConnection;

  late Account _account;
  String get _secret => "floatint201412bool23string";

  @override
  initialize({List<Object>? args}) async {
    super.initialize(args: args);
    _account = args![0] as Account;

    _socketConnection =
        TcpSocketConnection(LoadingData.chatIp, LoadingData.chatPort);
    // _socketConnection.enableConsolePrint(true);
    await _socketConnection.connect(500, _messageReceived, attempts: 3);
    subscribe("user${_account.get(AccountField.id)}");
  }

  void _messageReceived(String message) {
    var startIndex = message.indexOf("__JSON__START__");
    var endIndex = message.indexOf("__JSON__END__");
    if (startIndex < 0 || endIndex < 0) {
      return;
    }
    var b64 = utf8.fuse(base64);
    message = message.substring(startIndex + 15, endIndex);
    message = b64.decode(message.xorDecrypt(secret: _secret));
    // if (!message.contains("player_status")) print(message);
    // var nm = NoobMessage(jsonDecode(message));
    // var o = Opponent.list.where((o) => o.id == nm.playerId);
    // log("${o.length}");
    onMessageReceive
        ?.call(NoobMessage.getProperMessage(_account, jsonDecode(message)));
  }

  void _run(NoobCommand command, String message) {
    var b64 = utf8.fuse(base64);
    var cmdMessage =
        "__${command.value}__${b64.encode(message).xorEncrypt(secret: _secret)}__END${command.value}__";
    log(cmdMessage);
    _socketConnection.sendMessage(cmdMessage);
  }

  void subscribe(String channel) => _run(NoobCommand.subscribe, channel);
  void unsubscribe(String channel) => _run(NoobCommand.unsubscribe, channel);
}

enum NoobMessages { playerStatus, battleUpdate }

class NoobMessage {
  static NoobMessage getProperMessage(
      Account account, Map<String, dynamic> map) {
    return switch (map["push_message_type"] ?? "") {
      "battle_update" => NoobBattleMessage(account, map),
      _ => NoobStatusMessage(account, map),
    };
  }

  late NoobMessages type;
  NoobMessage();
}

class NoobStatusMessage extends NoobMessage {
  late int playerId, status;
  NoobStatusMessage(Account account, Map<String, dynamic> map) {
    type = NoobMessages.playerStatus;
    var id = map["player_id"];
    playerId = (id is String) ? int.parse(id) : id;
    status = map["status"];
  }
}

class NoobBattleMessage extends NoobMessage {
  late int id, round, ownerTeamId;
  AccountCard? card;
  NoobBattleMessage(Account account, Map<String, dynamic> map) {
    type = NoobMessages.battleUpdate;
    id = map["id"];
    round = map["round"];
    ownerTeamId = map["owner_team_id"];
    card = map["card"] == null ? null : AccountCard(account, map["card"]);
  }
}
