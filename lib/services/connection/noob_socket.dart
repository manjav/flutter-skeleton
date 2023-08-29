import 'dart:convert';

import 'package:tcp_socket_connection/tcp_socket_connection.dart';

import '../../blocs/opponents_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/infra.dart';
import '../../data/core/rpc_data.dart';
import '../../services/iservices.dart';
import '../../utils/utils.dart';

enum NoobCommand { subscribe, unsubscribe }

extension NoobCommandExtension on NoobCommand {
  String get value => name.toUpperCase();
}

class NoobSocket extends IService {
  Function(NoobMessage)? onReceive;
  late TcpSocketConnection _socketConnection;

  late Account _account;
  late OpponentsBloc _opponents;

  String get _secret => "floatint201412bool23string";

  @override
  initialize({List<Object>? args}) async {
    super.initialize(args: args);
    _account = args![0] as Account;
    _opponents = args[1] as OpponentsBloc;

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
    var noobMessage =
        NoobMessage.getProperMessage(_account, jsonDecode(message));
    _updateStatus(noobMessage);
    onReceive?.call(noobMessage);
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

  void _updateStatus(NoobMessage noobMessage) {
    if (noobMessage.type != NoobMessages.playerStatus ||
        _opponents.list == null) {
      return;
    }
    var statusMessage = noobMessage as NoobStatusMessage;

    var index =
        _opponents.list!.indexWhere((o) => o.id == statusMessage.playerId);
    if (index > -1) {
      _opponents.list![index].status = statusMessage.status;
      _opponents.add(SetOpponents(list: _opponents.list!));
      log("${noobMessage.playerId} ==>  ${noobMessage.status}");
    }
  }
}

enum NoobMessages { none, playerStatus, deployCard, battleFinished }

class NoobMessage {
  int id = 0;
  static NoobMessage getProperMessage(
      Account account, Map<String, dynamic> map) {
    return switch (map["push_message_type"] ?? "") {
      "battle_update" => NoobCardMessage(account, map),
      "player_status" => NoobStatusMessage(map),
      "battle_finished" => NoobMessage(NoobMessages.battleFinished),
      _ => NoobMessage(NoobMessages.none, map),
    };
  }

  final NoobMessages type;
  NoobMessage(this.type, Map<String, dynamic> map) {
    id = map["id"];
  }
}

class NoobStatusMessage extends NoobMessage {
  late int playerId, status;
  NoobStatusMessage(Map<String, dynamic> map)
      : super(NoobMessages.playerStatus, map) {
    var id = map["player_id"];
    playerId = (id is String) ? int.parse(id) : id;
    status = map["status"];
  }
}

class NoobCardMessage extends NoobMessage {
  late int round, teamOwnerId;
  AccountCard? card;
  NoobCardMessage(Account account, Map<String, dynamic> map)
      : super(NoobMessages.deployCard, map) {
    round = map["round"];
    teamOwnerId = map["owner_team_id"];
    card = map["card"] == null
        ? null
        : AccountCard(account, map["card"],
            ownerId: map["card"]!["player_id"]!);
  }
}
