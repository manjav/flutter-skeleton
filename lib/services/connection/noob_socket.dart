import 'dart:convert';

import 'package:tcp_socket_connection/tcp_socket_connection.dart';

import '../../blocs/opponents_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/rpc_data.dart';
import '../../services/iservices.dart';
import '../../utils/utils.dart';
import '../../view/widgets/card_holder.dart';

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
    if (noobMessage.type != NoobMessages.playerStatus) log(message);
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

enum NoobMessages {
  none,
  playerStatus,
  deployCard,
  battleFinished,
  heroAbility,
}

class NoobMessage {
  int id = 0;
  static NoobMessage getProperMessage(
      Account account, Map<String, dynamic> map) {
    return switch (map["push_message_type"] ?? "") {
      "player_status" => NoobStatusMessage(map),
      "battle_update" => NoobCardMessage(account, map),
      "battle_hero_ability" => NoobAbilityMessage(map),
      "battle_finished" => NoobFineMessage(map),
      _ => NoobMessage(NoobMessages.none, map),
    };
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

enum Abilities { none, power, last_used_at, blessing }

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
class NoobFineMessage extends NoobMessage {
  List<OpponentResult> opponents = [];
  int winnerScore = 0, loserScore = 0, winnerId = 0, loserId = 0;
  String winnerTribe = "", loserTribe = "";

  late Map<int, LiveCardsData> slots;
  late OpponentResult alliseOwner, axisOwner;
  List<OpponentResult> allies = [], axis = [];
  bool get won => alliseOwner.id == winnerId;
  NoobFineMessage(Map<String, dynamic> map)
      : super(NoobMessages.battleFinished, map) {
    for (var entry in map["players_info"].entries) {
      opponents.add(OpponentResult(entry.value));
    }
    var result = map["result"];
    winnerScore = result["winner_added_score"];
    loserScore = result["loser_added_score"];
    winnerId = result["winner_id"];
    loserId = result["loser_id"];
    winnerTribe = result["winner_tribe_name"];
    loserTribe = result["loser_tribe_name"];
  }

  void addBattleData(int alliseId, int axisId, Map<int, LiveCardsData> slots) {
    this.slots = slots;
    for (var opponent in opponents) {
      if (opponent.ownerTeamId == alliseId) {
        if (opponent.id == alliseId) {
          opponent.score = opponent.id == winnerId ? winnerScore : loserScore;
          alliseOwner = opponent;
        } else {
          allies.add(opponent);
        }
      } else {
        if (opponent.id == axisId) {
          opponent.score = opponent.id == winnerId ? winnerScore : loserScore;
          axisOwner = opponent;
        } else {
          axis.add(opponent);
        }
      }
    }
  }
}

class OpponentResult {
  int score = 0;
  String name = "";
  final Map<String, dynamic> map;
  late int power, cooldown, id, gold, xp, level, leagueRank, ownerTeamId;
  Map<String, int> heroBenefits = {"power": 0, "gold": 0, "cooldown": 0};

  OpponentResult(this.map) {
    ownerTeamId = map["owner_team_id"];
    id = map["id"];
    name = map["name"];
    level = map["level"];
    power = map["power"];
    cooldown = map["cooldown"];
    leagueRank = map["league_rank"];
    xp = map["added_xp"];
    gold = map["added_gold"];
    var benefits = map["hero_benefits_info"];
    if (benefits.length > 0) {
      heroBenefits["power"] = benefits["power_benefit"] ?? 0;
      heroBenefits["gold"] = benefits["gold_benefit"] ?? 0;
      heroBenefits["cooldown"] = benefits["cooldown_benefit"] ?? 0;
    }
}
}
