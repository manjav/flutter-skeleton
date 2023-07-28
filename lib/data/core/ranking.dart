import 'dart:convert';

import '../../services/prefs.dart';
import '../../utils/utils.dart';
import 'rpc.dart';
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
