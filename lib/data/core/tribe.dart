import '../../data/core/building.dart';

class Tribe {
  late int id,
      gold,
      status,
      population,
      donatesCount,
      score,
      weeklyScore,
      rank,
      weeklyRank;
  late String name, description;
  final Map<int, int> levels = {};

  Tribe(Map? map) : super() {
    if (map == null) return;
    id = map["id"];
    gold = map["gold"];
    status = map["status"];
    population = map["member_count"];
    levels[Buildings.offense.id] = map["offense_building_level"];
    levels[Buildings.defense.id] = map["defense_building_level"];
    levels[Buildings.cards.id] = map["cooldown_building_level"];
    levels[Buildings.base.id] = map["mainhall_building_level"];
    donatesCount = map["donates_number"];
    score = map["score"];
    weeklyScore = map["weekly_score"];
    rank = map["rank"];
    weeklyRank = map["weekly_rank"];
    name = map["name"];
    description = map["description"];
  }

  int getOption(int id, [int? level]) =>
      Building.get_benefit(id.toBuildings(), level ?? levels[id]!);
  int getOptionCost(int id, [int? level]) =>
      Building.get_upgradeCost(id.toBuildings(), level ?? levels[id]!);

  static List<Tribe> initAll(List list) {
    var result = <Tribe>[];
    for (var map in list) {
      result.add(Tribe(map));
    }
    return result;
  }
}
