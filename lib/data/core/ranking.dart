import 'dart:convert';

import '../../services/prefs.dart';
import '../../utils/utils.dart';
import 'rpc.dart';

class Ranks {
  static List<T> createList<T extends Rank>(
      Map<String, dynamic> map, int ownerId) {
    var group = T.toString() == "Player" ? "players" : "tribes";
    var result = _add<T>(map["top_$group"], ownerId);
    var list = result.$1;
    if (!result.$2) {
      list.add(make<T>(null, 0));
      list.addAll(_add<T>(map["near_$group"], ownerId).$1);
    }
    return list;
  }

  static (List<T>, bool) _add<T extends Rank>(List list, int ownerId) {
    var hasOwner = false;
    var result = <T>[];
    var index = 0;
    for (var item in list) {
      var rank = make<T>(item as Map<String, dynamic>?, ownerId);
      if (rank.itsMe) hasOwner = true;
      rank.index = index++;
      result.add(rank);
    }
    return (result, hasOwner);
  }

  /// Add factory functions for every Type and every constructor you want to make available to `make`
  static final _factories = <Type, Function>{
    Player: (Map<String, dynamic>? map, int ownerId) =>
        Player.init(map, ownerId),
    TribeRank: (Map<String, dynamic>? map, int ownerId) =>
        TribeRank.init(map, ownerId),
  };

  static T make<T extends Rank>(Map<String, dynamic>? map, int ownerId) {
    return _factories[T]!(map, ownerId);
  }

  static final Map<RpcId, List<Rank>?> lists = {};
}

abstract class Rank {
  int index = 0, id = 0, rank = 0, score = 0;
  String name = "";
  late final bool itsMe;
  Rank.init(Map<String, dynamic>? map, int ownerId) {
    if (map == null) return;
    id = map["id"] ?? 0;
    name = map["name"] ?? "";
    rank = map["rank"] ?? 0;
    itsMe = ownerId == id;
  }
}

class TribeRank extends Rank {
  int memberCount = 0, weeklyScore = 0, weeklyRank = 0;
  String description = "";
  TribeRank.init(Map<String, dynamic>? map, int ownerId)
      : super.init(map, ownerId) {
    if (map == null) return;
    score = map["score"] ?? 0;
    description = map["description"] ?? "";
    memberCount = map["member_count"] ?? 0;
    weeklyScore = map["weekly_score"] ?? 0;
    weeklyRank = map["weekly_rank"] ?? 0;
  }
}

class Player extends Rank {
  String tribeName = "";
  int level = 0, tribeId = 0, avatarId = 0;
  Player.init(Map<String, dynamic>? map, int ownerId)
      : super.init(map, ownerId) {
    if (map == null) return;
    score = map["xp"] ?? 0;
    level = map["level"] ?? 0;
    tribeId = map["tribe_id"] ?? 0;
    tribeName = map["tribe_name"] ?? "";
    avatarId = map["avatar_id"] ?? 0;
  }
}
class LeagueData {
  static const stages = <List<int>>[
    [1],
    [2, 3, 4, 5, 6],
    [7, 8, 9, 10, 11],
    [12, 13, 14, 15, 16],
    [17, 18, 19, 20, 21],
    [22, 23, 24]
  ];

  static (int, int) getIndices(int id) {
    var stageIndex = 1;
    for (var stage in stages) {
      var stepIndex = 1;
      for (var step in stage) {
        if (step == id) {
          return (stageIndex, stepIndex);
        }
        stepIndex++;
      }
      stageIndex++;
    }
    return (0, 0);
  }

}

class Opponent extends Player {
  static int scoutCost = 0;
  static Map<String, dynamic> _attackLogs = {};
  int gold = 0,
      tribePermission = 0,
      defPower = 0,
      status = 0,
      leagueId = 0,
      leagueRank = 0,
      powerRatio = 0;
  bool isRevealed = false;
  int todayAttacksCount = 0;
  Opponent.init(Map<String, dynamic>? map, int ownerId)
      : super.init(map, ownerId) {
    if (map == null) return;
    gold = map["gold"] ?? 0;
    status = map["status"] ?? 0;
    score = map["xp"] ?? 0;
    defPower = map["def_power"] ?? 0;
    leagueId = map["league_id"] ?? 0;
    leagueRank = map["league_rank"] ?? 0;
    powerRatio = map["power_ratio"] ?? 0;
    tribePermission = map["tribe_permission"] ?? 0;
  }

  static List<Opponent> fromMap(Map<String, dynamic> map) {
    scoutCost = map["scout_cost"];
    _attackLogs = Opponent._getAttacksLog();
    var list = <Opponent>[];
    var index = 0;
    for (var player in map["players"]) {
      var opponent = Opponent.init(player, 0);
      opponent.index = index++;
      opponent.todayAttacksCount = (_attackLogs["${opponent.id}"] ?? 0);
      list.add(opponent);
    }
    return list;
  }

  static Map<String, dynamic> _getAttacksLog() {
    var attacks = jsonDecode(Pref.attacks.getString(defaultValue: '{}'));
    var days = DateTime.now().daysSinceEpoch;
    if (attacks["days"] != days) {
      attacks = {"days": days};
    }
    return attacks;
  }

  void increaseAttacksCount() {
    todayAttacksCount++;
    _attackLogs["$id"] = todayAttacksCount;
    Pref.attacks.setString(jsonEncode(_attackLogs));
  }

  int getGoldLevel(int accountLevel) {
    var goldRate = gold / todayAttacksCount;
    if (goldRate < 100 * accountLevel) return 1;
    if (goldRate < 500 * accountLevel) return 2;
    if (goldRate < 1000 * accountLevel) return 3;
    return 4;
  }
}
