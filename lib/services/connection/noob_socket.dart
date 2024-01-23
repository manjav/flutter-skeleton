import 'dart:convert';

import 'package:tcp_socket_connection/tcp_socket_connection.dart';

import '../../app_export.dart';

enum NoobCommand { subscribe, unsubscribe }

extension NoobCommandExtension on NoobCommand {
  String get value => name.toUpperCase();
}

class NoobSocket extends IService {
  List<Function(NoobMessage)> onReceive = [];
  late TcpSocketConnection _socketConnection;
  late Account _account;
  late OpponentsProvider _opponents;
  int _lastMessageReceiveTime = 0;
  String _messageStream = "";

  String get _secret => "floatint201412bool23string";
  bool get isConnected =>
      DateTime.now().secondsSinceEpoch - _lastMessageReceiveTime < 60;

  @override
  initialize({List<Object>? args}) async {
    super.initialize(args: args);
    _account = args![0] as Account;
    _opponents = args[1] as OpponentsProvider;
    connect();
  }

  connect() async {
    _socketConnection =
        TcpSocketConnection(LoadingData.chatIp, LoadingData.chatPort);
    // _socketConnection.enableConsolePrint(true);
    await _socketConnection.connect(500, _messageReceived, attempts: 3);
    _lastMessageReceiveTime = DateTime.now().secondsSinceEpoch;
    subscribe("user${_account.id}");
    if (_account.tribe != null) subscribe("tribe${_account.tribe?.id}");
  }

  void _messageReceived(String message) {
    _lastMessageReceiveTime = DateTime.now().secondsSinceEpoch;
    _messageStream += message;
    _decodeMessage();
  }

  void _decodeMessage() {
    var startIndex = _messageStream.indexOf("__JSON__START__");
    var endIndex = _messageStream.indexOf("__JSON__END__");
    if (startIndex < 0 || endIndex < 0) {
      return;
    }
    try {
      var b64 = utf8.fuse(base64);
      var trimmedMessage = _messageStream.substring(startIndex + 15, endIndex);
      trimmedMessage = b64.decode(trimmedMessage.xorDecrypt(secret: _secret));

      var noobMessage =
          NoobMessage.getProperMessage(_account, jsonDecode(trimmedMessage));
      if (noobMessage.type == Noobs.chat) {
        _account.tribe?.chat.add(noobMessage as NoobChatMessage);
      }
      // if (noobMessage.type != Noobs.playerStatus) log(trimmedMessage);
      _updateStatus(noobMessage);
      dispatchMessage(noobMessage);
      _messageStream = _messageStream.substring(endIndex + 12);
      _decodeMessage();
    } catch (e) {
      log(e.toString());
    }
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
  publish(String message) async {
    if (!isConnected) {
      await connect();
    }
    var b64 = utf8.fuse(base64);
    var cmdMessage =
        "__JSON__START__${b64.encode(message).xorEncrypt(secret: _secret)}__JSON__END__";
    _socketConnection.sendMessage(cmdMessage);
  }

  bool _loopPlayers(List<Rank> list, NoobStatusMessage message) {
    var index = list.indexWhere((o) => o.id == message.playerId);
    if (index > -1) {
      list[index].status = message.status;
      log("${message.playerId} ==>  ${message.status}");
      return true;
    }
    return false;
  }

  void _updateStatus(NoobMessage noobMessage) {
    if (noobMessage.type != Noobs.playerStatus) {
      return;
    }

    // Update opponent status
    if (_loopPlayers(_opponents.list, noobMessage as NoobStatusMessage)) {
      _opponents.update();
    }

    // Update tribe members status
    if (_account.tribe != null) {
      _loopPlayers(_account.tribe!.members.value, noobMessage);
    }
  }

  void dispatchMessage(NoobMessage noobMessage) {
    for (var method in onReceive) {
      method.call(noobMessage);
    }
  }
}

enum Noobs {
  none,
  playerStatus,
  deployCard,
  battleEnd,
  battleJoin,
  battleRequest,
  heroAbility,
  help,
  chat,
  auctionBid,
  auctionSold,
}

class NoobMessage {
  int id = 0;
  String channel = "";
  static NoobMessage getProperMessage(
      Account account, Map<String, dynamic> map) {
    var message = switch (map["push_message_type"] ?? "") {
      "player_status" || "tribe_player_status" => NoobStatusMessage(map),
      "battle_update" => NoobCardMessage(account, map),
      "battle_request" => NoobRequestBattleMessage(map),
      "battle_join" => NoobJoinBattleMessage(account, map),
      "battle_hero_ability" => NoobAbilityMessage(map),
      "battle_help" => NoobHelpMessage(map),
      "battle_finished" => NoobEndBattleMessage(map, account),
      "chat" => NoobChatMessage(map, account),
      "auction_bid" => NoobAuctionMessage(Noobs.auctionBid, map, account),
      "auction_sold" => NoobAuctionMessage(Noobs.auctionSold, map, account),
      _ => NoobMessage(Noobs.none, map),
    };
    return message;
  }

  final Noobs type;
  final Map<String, dynamic> map;
  NoobMessage(this.type, this.map) {
    id = map["id"] ?? 0;
  }
}

class NoobBattleMessage extends NoobMessage {
  int teamOwnerId = 0;
  NoobBattleMessage(super.type, super.map) {
    teamOwnerId = map["owner_team_id"] ?? 0;
  }
}

class NoobStatusMessage extends NoobMessage {
  late int playerId, status;
  NoobStatusMessage(Map<String, dynamic> map) : super(Noobs.playerStatus, map) {
    var id = map["player_id"];
    playerId = (id is String) ? int.parse(id) : id;
    status = map["status"];
  }
}

class NoobRequestBattleMessage extends NoobBattleMessage {
  late int attackerId;
  late String attackerName, attackerTribeName;
  NoobRequestBattleMessage(Map<String, dynamic> map)
      : super(Noobs.battleRequest, map) {
    id = map["battle_id"];
    attackerTribeName = map["tribe_name"];
    attackerId = map["attacker_id"];
    attackerName = map["attacker_name"];
  }
}

class NoobJoinBattleMessage extends NoobBattleMessage {
  late int warriorId;
  late String warriorName;
  NoobJoinBattleMessage(Account account, Map<String, dynamic> map)
      : super(Noobs.battleJoin, map) {
    warriorId = map["player_id"];
    warriorName = map["player_name"];
  }
}

class NoobCardMessage extends NoobBattleMessage {
  int round = 0;
  AccountCard? card;
  String ownerName = "";
  NoobCardMessage(Account account, Map<String, dynamic> map)
      : super(Noobs.deployCard, map) {
    round = map["round"];
    ownerName = map["card_owner_name"];
    card = map["card"] == null
        ? null
        : AccountCard(account, map["card"],
            ownerId: map["card"]!["player_id"]!);
  }
}

enum Abilities { none, power, lastUsedAt, blessing }

extension AbilitiesExtrension on Abilities {
  String get value => switch (this) {
        Abilities.lastUsedAt => "last_used_at",
        _ => name,
      };
}

class NoobAbilityMessage extends NoobBattleMessage {
  late int ownerId, heroId;
  Abilities ability = Abilities.none;
  Map<String, int> cards = {};
  NoobAbilityMessage(Map<String, dynamic> map) : super(Noobs.heroAbility, map) {
    heroId = map["hero_id"];
    ownerId = map["hero_owner_id"];
    ability = Abilities.values[map["ability_type"]];
    for (var card in map["hero_benefits_info"]["cards"]) {
      cards[card["id"]] = card[ability.value];
    }
  }
}

class NoobHelpMessage extends NoobMessage {
  int ownerId = 0, ownerTribeId = 0, attackerId = 0, defenderId = 0;
  String attackerName = "", defenderName = "";
  NoobHelpMessage(Map<String, dynamic> map) : super(Noobs.help, map) {
    ownerId = map["help_owner_id"];
    ownerTribeId = map["help_owner_tribe_id"];
    attackerId = map["attacker_id"];
    defenderId = map["defender_id"];
    attackerName = map["attacker_name"];
    defenderName = map["defender_name"];
  }
  bool get isAttacker => ownerId == attackerId;
}

// battle_id = self.battle_id,
// mainEnemy = mainEnemyID ,
class NoobChatMessage extends NoobMessage {
  Message? base;
  int timestamp = 0;
  bool itsMe = false;
  String sender = "", text = "";
  int avatarId = 0, creationDate = 0;
  Messages messageType = Messages.none;
  NoobChatMessage(Map<String, dynamic> map, Account account)
      : super(Noobs.chat, map) {
    text = map["text"] ?? "";
    sender = map["sender"] ?? "";
    channel = map["channel"] ?? "";
    avatarId = Convert.toInt(map["avatar_id"]);
    creationDate = Convert.toInt(map["creationDate"]);
    timestamp = Convert.toInt(map["timestamp"]);
    messageType = Messages.values[Convert.toInt(map["messageType"], 1)];
    itsMe = sender == account.name;
  }
}

class NoobEndBattleMessage extends NoobMessage {
  int winnerScore = 0, loserScore = 0, winnerId = 0, loserId = 0;
  String winnerTribe = "", loserTribe = "";
  List<dynamic> opponentsInfo = [];
  NoobEndBattleMessage(Map<String, dynamic> map, Account account)
      : super(Noobs.battleEnd, map) {
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

class NoobAuctionMessage extends NoobMessage {
  late AuctionCard card;
  NoobAuctionMessage(super.type, super.map, Account account) {
    card = AuctionCard(account, super.map);
  }
}
