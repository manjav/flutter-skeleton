import 'dart:convert';

import '../../skeleton/services/prefs.dart';
import '../../skeleton/utils/utils.dart';
import 'fruit.dart';
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
    Record: (Map<String, dynamic>? map, int ownerId) =>
        Record.initialize(map, ownerId),
    TribeRank: (Map<String, dynamic>? map, int ownerId) =>
        TribeRank.initialize(map, ownerId),
    LeagueRank: (Map<String, dynamic>? map, int ownerId) =>
        LeagueRank.initialize(map, ownerId),
  };

  static T make<T extends Rank>(Map<String, dynamic>? map, int ownerId) {
    return _factories[T]!(map, ownerId);
  }

  static final Map<RpcId, List<Rank>?> lists = {};
}

abstract class Rank {
  String name = "";
  late final bool itsMe;
  int index = 0, id = 0, rank = 0, score = 0, status = 0;
  Rank.initialize(Map<String, dynamic>? map, int ownerId) {
    if (map == null) return;
    name = map["name"] ?? "";
    id = Utils.toInt(map["id"]);
    if (map.containsKey("total_rank")) {
      rank = Utils.toInt(map["total_rank"]);
    } else {
      rank = Utils.toInt(map["rank"]);
    }
    score = Utils.toInt(map["score"]);
    itsMe = ownerId == id;
  }
}

class TribeRank extends Rank {
  String description = "";
  int memberCount = 0, weeklyScore = 0, weeklyRank = 0;
  TribeRank.initialize(Map<String, dynamic>? map, int ownerId)
      : super.initialize(map, ownerId) {
    if (map == null) return;
    description = map["description"] ?? "";
    memberCount = Utils.toInt(map["member_count"]);
    weeklyScore = Utils.toInt(map["weekly_score"]);
    weeklyRank = Utils.toInt(map["weekly_rank"]);
  }
}

class Record extends Rank {
  String tribeName = "";
  int level = 1, tribeId = 0, avatarId = 1;
  Record.initialize(Map<String, dynamic>? map, int ownerId)
      : super.initialize(map, ownerId) {
    if (map == null) return;
    level = Utils.toInt(map["level"]);
    tribeId = Utils.toInt(map["tribe_id"]);
    tribeName = map["tribe_name"] ?? "";
    avatarId = Utils.toInt(map["avatar_id"], 1);
  }
}

class LeagueRank extends Record {
  int weeklyScore = 0;
  LeagueRank.initialize(Map<String, dynamic>? map, int ownerId)
      : super.initialize(map, ownerId) {
    if (map == null) return;
    rank = Utils.toInt(map["league_rank"]);
    score = Utils.toInt(map["overall_score"]);
    weeklyScore = Utils.toInt(map["weekly_score"]);
  }
}

class LeagueHistory {
  Map<String, List<LeagueRank>> lists = {};
  LeagueHistory.initialize(Map<String, dynamic>? map, int round, int ownerId) {
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
        var rank = LeagueRank.initialize(r, ownerId);
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
  num rewardAvgCardPower = 0.0;

  List<List<int>> winnerRanges = [];
  List<LeagueRank> list = [];
  LeagueData.initialize(Map<String, dynamic>? map, int ownerId) {
    if (map == null) return;
    var w = map["winner_ranges"];
    id = Utils.toInt(w["league_id"]);
    leagueRank = Utils.toInt(map["league_rank"]);
    risingRank = Utils.toInt(map["league_rising_rank"]);
    fallingRank = Utils.toInt(map["league_falling_rank"]);
    currentBonus = Utils.toInt(map["current_league_bonus"]);
    nextBonus = Utils.toInt(map["next_league_bonus"]);
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

enum WarriorSide { friends, opposites }

enum TribePosition { none, member, elder, owner }

class Opponent extends Record {
  static Opponent create(int id, String name, [int? ownerId]) =>
      Opponent.initialize({"id": id, "name": name}, ownerId ?? id);

  static int scoutCost = 0;
  static Map<String, dynamic> _attackLogs = {};
  int gold = 0,
      xp = 0,
      defPower = 0,
      leagueId = 0,
      leagueRank = 0,
      powerRatio = 0,
      todayAttacksCount = 0;
  bool isRevealed = false, pokeStatus = false;
  TribePosition tribePosition = TribePosition.none;
  Opponent.initialize(Map<String, dynamic>? map, int ownerId)
      : super.initialize(map, ownerId) {
    if (map == null) return;
    gold = Utils.toInt(map["gold"]);
    status = Utils.toInt(map["status"]);
    xp = Utils.toInt(map["xp"]);
    defPower = Utils.toInt(map["def_power"]);
    leagueId = Utils.toInt(map["league_id"]);
    leagueRank = Utils.toInt(map["league_rank"]);
    powerRatio = Utils.toInt(map["power_ratio"]);
    pokeStatus = map["poke_status"] ?? false;
    if (map.containsKey("tribe_position")) {
      TribePosition.values[map["tribe_position"]];
    } else {
      tribePosition = TribePosition.values[map["tribe_permission"] ?? 1];
    }
  }

  static List<Opponent> fromMap(Map<String, dynamic> map, int ownerId) {
    scoutCost = map["scout_cost"];
    _attackLogs = Opponent._getAttacksLog();
    return createList(map["players"], ownerId);
  }

  static List<Opponent> createList(List list, int ownerId) {
    var index = 0;
    var result = <Opponent>[];
    for (var player in list) {
      var opponent = Opponent.initialize(player, ownerId);
      opponent.index = index++;
      opponent.todayAttacksCount = Utils.toInt(_attackLogs["${opponent.id}"]);
      result.add(opponent);
    }
    return result;
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

class LiveWarrior {
  bool won = false;
  final Opponent base;
  String tribeName = "";
  final int teamOwnerId;
  final WarriorSide side;
  Map<String, dynamic> map = {};
  int gold = 0, xp = 0, power = 0, score = 0;
  Map<String, int> heroBenefits = {"power": 0, "gold": 0, "cooldown": 0};
  final SelectedCards cards = SelectedCards([null, null, null, null, null]);

  LiveWarrior(this.side, this.teamOwnerId, this.base);
  void addResult(Map<String, dynamic> map) {
    this.map = map;
    xp = map["added_xp"];
    power = map["power"];
    gold = map["added_gold"];
    var benefits = map["hero_benefits_info"];
    if (benefits.length > 0) {
      heroBenefits["power"] = Utils.toInt(benefits["power_benefit"]);
      heroBenefits["gold"] = Utils.toInt(benefits["gold_benefit"]);
      heroBenefits["cooldown"] = Utils.toInt(benefits["cooldown_benefit"]);
    }
  }
}
