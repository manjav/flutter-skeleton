class MissionData {
  static List<Missions> missions = [
    Missions(
      startIndex: 1500,
      finishIndex: 1504,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 1501, mission: "select_both_of_your_cards"),
        Mission(doneId: 1502, mission: "attack_them"),
      ],
    ),
    Missions(
      startIndex: 1500,
      finishIndex: 1504,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 1501, mission: "cooldown_both_cards"),
      ],
    ),
    Missions(
      startIndex: 1500,
      finishIndex: 1504,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 1501, mission: "enter_shop"),
      ],
    ),
    Missions(
      startIndex: 1500,
      finishIndex: 1504,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 1501, mission: "buy_green_pack"),
      ],
    ),
    Missions(
      startIndex: 1500,
      finishIndex: 1504,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 1501, mission: "go_to_islands_of_death"),
      ],
    ),
    Missions(
      startIndex: 1500,
      finishIndex: 1504,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 1501, mission: "go_to_islands_of_death"),
        Mission(doneId: 1501, mission: "go_to_first_island"),
        Mission(doneId: 1501, mission: "reach_level_3"),
      ],
    ),
    Missions(
      startIndex: 1500,
      finishIndex: 1504,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 1501, mission: "defeat_one_player_opponent"),
      ],
    ),
    Missions(
      startIndex: 1500,
      finishIndex: 1504,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 1501, mission: "enhance_a_card_from_cards_building"),
      ],
    ),
    Missions(
      startIndex: 1500,
      finishIndex: 1504,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 1501, mission: "reach_level_4"),
      ],
    ),
    Missions(
      startIndex: 1500,
      finishIndex: 1504,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 1501, mission: "evolve_apple_from_cards_building"),
      ],
    ),
  ];
}

class Missions {
  int startIndex;
  int finishIndex;
  int level;
  List<Mission> missions;
  Missions({
    required this.startIndex,
    required this.finishIndex,
    required this.level,
    required this.missions,
  });
}

class Mission {
  int doneId;
  String mission;
  Mission({
    required this.doneId,
    required this.mission,
  });
}
