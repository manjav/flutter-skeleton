class Tribe {
  late int id,
      gold,
      status,
      population,
      baseLevel,
      cooldownLevel,
      defenseLevel,
      offenseLevel,
      donatesCount,
      score,
      weeklyScore,
      rank,
      weeklyRank;
  late String name, description;

  Tribe(Map? map) {
    if (map == null) return;
    id = map["id"];
    gold = map["gold"];
    status = map["status"];
    population = map["member_count"];
    baseLevel = map["mainhall_building_level"];
    cooldownLevel = map["cooldown_building_level"];
    defenseLevel = map["defense_building_level"];
    offenseLevel = map["offense_building_level"];
    donatesCount = map["donates_number"];
    score = map["score"];
    weeklyScore = map["weekly_score"];
    rank = map["rank"];
    weeklyRank = map["weekly_rank"];
    name = map["name"];
    description = map["description"];
  }

  int get capacity => 15;

  static List<Tribe> initAll(List list) {
    var result = <Tribe>[];
    for (var map in list) {
      result.add(Tribe(map));
    }
    return result;
  }
}
