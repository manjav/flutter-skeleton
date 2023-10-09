import 'dart:convert';

import 'package:tcp_socket_connection/tcp_socket_connection.dart';

import '../../blocs/opponents_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/ranking.dart';
import '../../data/core/rpc_data.dart';
import '../../data/core/tribe.dart';
import '../../services/iservices.dart';
import '../../utils/utils.dart';

enum NoobCommand { subscribe, unsubscribe }

extension NoobCommandExtension on NoobCommand {
  String get value => name.toUpperCase();
}

class NoobSocket extends IService {
  List<Function(NoobMessage)> onReceive = [];
  late TcpSocketConnection _socketConnection;

  Tribe? _tribe;
  late Account _account;
  late OpponentsBloc _opponents;
  int _lastMessageReceiveTime = 0;

  String get _secret => "floatint201412bool23string";
  bool get isConnected =>
      DateTime.now().secondsSinceEpoch - _lastMessageReceiveTime < 100;

  @override
  initialize({List<Object>? args}) async {
    super.initialize(args: args);
    _account = args![0] as Account;
    _opponents = args[1] as OpponentsBloc;
    _tribe = _account.get<Tribe?>(AccountField.tribe);
    connect();
  }

  connect() async {
    _socketConnection =
        TcpSocketConnection(LoadingData.chatIp, LoadingData.chatPort);
    // _socketConnection.enableConsolePrint(true);
    await _socketConnection.connect(500, _messageReceived, attempts: 3);
    subscribe("user${_account.get(AccountField.id)}");
    subscribe("tribe${_account.get(AccountField.tribe).id}");
  }

  void _messageReceived(String message) {
    _lastMessageReceiveTime = DateTime.now().secondsSinceEpoch;
    _decodeMessage(message);
  }

  void _decodeMessage(String message) {
    var startIndex = message.indexOf("__JSON__START__");
    var endIndex = message.indexOf("__JSON__END__");
    if (startIndex < 0 || endIndex < 0) {
      return;
    }
    var b64 = utf8.fuse(base64);
    var trimmedMessage = message.substring(startIndex + 15, endIndex);
    trimmedMessage = b64.decode(trimmedMessage.xorDecrypt(secret: _secret));
    print(trimmedMessage);
    var noobMessage = NoobMessage.getProperMessage(
        _account, jsonDecode(trimmedMessage), _tribe);
    _updateStatus(noobMessage);
    for (var method in onReceive) {
      method.call(noobMessage);
    }
    _decodeMessage(message.substring(endIndex + 12));
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
    loopPlayers(List<Rank> list) {
      var index = list.indexWhere((o) => o.id == statusMessage.playerId);
    if (index > -1) {
        list[index].status = statusMessage.status;
        log("${noobMessage.playerId} ==>  ${noobMessage.status}");
      }
    }

    // Update opponent status
    if (_opponents.list != null) {
      loopPlayers(_opponents.list!);
      _opponents.add(SetOpponents(list: _opponents.list!));
    }

    // Update tribe members status
    if (_tribe != null) {
      loopPlayers(_tribe!.members);
    }
  }
}

enum NoobMessages {
  none,
  playerStatus,
  deployCard,
  battleFinished,
  heroAbility,
  help,
  chat,
}

class NoobMessage {
  int id = 0;
  String channel = '';
  static NoobMessage getProperMessage(
      Account account, Map<String, dynamic> map, Tribe? tribe) {
    var message = switch (map["push_message_type"] ?? "") {
      "player_status" => NoobStatusMessage(map),
      "battle_update" => NoobCardMessage(account, map),
      "battle_hero_ability" => NoobAbilityMessage(map),
      "battle_help" => NoobHelpMessage(map),
      "tribe_player_status" => NoobMessage(NoobMessages.none, map),
      "battle_finished" => NoobFineMessage(map),
      "chat" => NoobChatMessage(map, account),
      _ => NoobMessage(NoobMessages.none, map),
    };
    if (message.channel.startsWith("tribe")) {
      tribe?.chat.add(message as NoobChatMessage);
    }
    return message;
  }

  final NoobMessages type;
  NoobMessage(this.type, Map<String, dynamic> map) {
    id = map["id"] ?? 0;
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
  AccountCard? card;
  String ownerName = "";
  int round = 0, teamOwnerId = 0;
  NoobCardMessage(Account account, Map<String, dynamic> map)
      : super(NoobMessages.deployCard, map) {
    round = map["round"];
    teamOwnerId = map["owner_team_id"];
    ownerName = map["card_owner_name"];
    card = map["card"] == null
        ? null
        : AccountCard(account, map["card"],
            ownerId: map["card"]!["player_id"]!);
  }
}

enum Abilities { none, power, lastUsedAt, blessing }

class NoobAbilityMessage extends NoobMessage {
  late int teamOwnerId, ownerId, heroId;
  Abilities ability = Abilities.none;
  Map<String, int> cards = {};
  NoobAbilityMessage(Map<String, dynamic> map)
      : super(NoobMessages.heroAbility, map) {
    heroId = map["hero_id"];
    ownerId = map["hero_owner_id"];
    teamOwnerId = map["owner_team_id"];
    ability = Abilities.values[map["ability_type"]];
    for (var card in map["hero_benefits_info"]["cards"]) {
      cards[card["id"]] = card[ability.name];
    }
  }
}

class NoobHelpMessage extends NoobMessage {
  int ownerId = 0, ownerTribeId = 0, attackerId = 0, defenderId = 0;
  String attackerName = "", defenderName = "";
  NoobHelpMessage(Map<String, dynamic> map) : super(NoobMessages.help, map) {
    ownerId = map["help_owner_id"];
    ownerTribeId = map["help_owner_tribe_id"];
    attackerId = map["attacker_id"];
    defenderId = map["defender_id"];
    attackerName = map["attacker_name"];
    defenderName = map["defender_name"];
  }
}

// battle_id = self.battle_id,
// mainEnemy = mainEnemyID ,
class NoobChatMessage extends NoobMessage {
  bool itsMe = false;
  double timestamp = 0.0;
  String sender = "", text = "";
  int avatarId = 0, creationDate = 0, messageType = 1;
  NoobChatMessage(Map<String, dynamic> map, Account account)
      : super(NoobMessages.chat, map) {
    text = map["text"] ?? "";
    sender = map["sender"] ?? "";
    channel = map["channel"] ?? "";
    avatarId = Utils.toInt(map["avatar_id"]);
    creationDate = Utils.toInt(map["creationDate"]);
    timestamp = map["timestamp"] ?? 0.0;
    messageType = Utils.toInt(map["messageType"]);
    itsMe = sender == account.get(AccountField.name);
  }
}

class NoobFineMessage extends NoobMessage {
  int winnerScore = 0, loserScore = 0, winnerId = 0, loserId = 0;
  String winnerTribe = "", loserTribe = "";
  List<dynamic> opponentsInfo = [];
  NoobFineMessage(Map<String, dynamic> map)
      : super(NoobMessages.battleFinished, map) {
    var result = map["result"];
    winnerScore = result["winner_added_score"];
    loserScore = result["loser_added_score"];
    winnerId = result["winner_id"];
    loserId = result["loser_id"];
    winnerTribe = result["winner_tribe_name"];
    loserTribe = result["loser_tribe_name"];
    opponentsInfo = map["players_info"].values.toList();
  }
}
