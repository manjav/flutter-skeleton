import 'dart:convert';

import '../../services/prefs.dart';
import '../../utils/utils.dart';
import 'rpc.dart';

class Ranks {
  static List<T> createList<T extends Rank>(
      Map<String, dynamic> map, int ownerId) {
    var group = T.toString() == "TribeRank" ? "tribes" : "players";
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
    LeagueRank: (Map<String, dynamic>? map, int ownerId) =>
        LeagueRank.init(map, ownerId),
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

class LeagueRank extends Player {
  int weeklyScore = 0;
  LeagueRank.init(Map<String, dynamic>? map, int ownerId)
      : super.init(map, ownerId) {
    if (map == null) return;
    rank = map["league_rank"] ?? 0;
    score = map["overall_score"] ?? 0;
    weeklyScore = map["weekly_score"] ?? 0;
  }
}

class LeagueHistory {
  Map<String, List<LeagueRank>> lists = {};
  LeagueHistory.init(Map<String, dynamic>? map, int round, int ownerId) {
    for (var e in map!["player_ranking"]["$round"].entries) {
      lists[e.key] = [];
      var index = 0;
      for (Map<String, dynamic> r in e.value) {
        r.remove("xp");
        r.remove("level");
        r.remove("tribe_id");
        r["id"] = r["player_id"];
        r["league_rank"] = r["rank"] = int.parse(r["rank"]);
        r["weekly_score"] = int.parse(r["weekly_score"]);
        var rank = LeagueRank.init(r, ownerId);
        rank.index = index++;
        lists[e.key]!.add(rank);
      }
    }
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
  int leagueRank = 0,
      id = 0,
      risingRank = 0,
      fallingRank = 0,
      currentBonus = 0,
      nextBonus = 0;
  double rewardAvgCardPower = 0.0;

  List<List<int>> winnerRanges = [];
  List<LeagueRank> list = [];
  LeagueData.init(Map<String, dynamic>? map, int ownerId) {
    if (map == null) return;
    var w = map["winner_ranges"];
    id = w["league_id"];
    leagueRank = map["league_rank"] ?? 0;
    risingRank = map["league_rising_rank"] ?? 0;
    fallingRank = map["league_falling_rank"] ?? 0;
    currentBonus = map["current_league_bonus"] ?? 0;
    nextBonus = map["next_league_bonus"] ?? 0;
    rewardAvgCardPower = map["reward_avg_card_power"] ?? 0.0;

    winnerRanges = [];
    winnerRanges.add(_getTops(1, w["second_min"] - 1));
    winnerRanges.add(_getTops(w["second_min"], w["second_max"]));
    winnerRanges.add(_getTops(w["third_min"], w["third_max"]));

    list = Ranks.createList<LeagueRank>(map, ownerId);
  }

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

  List<int> _getTops(int from, to) {
    var result = <int>[from];
    if (to > from) result.add(to);
    return result;
  }
}

enum OpponentMode { allise, axis }

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
