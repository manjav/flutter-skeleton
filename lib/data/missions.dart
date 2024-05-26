class MissionData {
  static List<Missions> missions = [
    //done
    Missions(
      startId: 11,
      finishId: 13,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 12, mission: "select_both_of_your_cards"),
        Mission(doneId: 13, mission: "attack_them"),
      ],
    ),
    //done
    Missions(
      startId: 14,
      finishId: 20,
      level: 1,
      missions: <Mission>[
        Mission(doneId: 20, mission: "cooldown_both_cards"),
      ],
    ),
    //done
    Missions(
      startId: 21,
      finishId: 22,
      level: 2,
      missions: <Mission>[
        Mission(doneId: 22, mission: "enter_shop"),
      ],
    ),
    //done
    Missions(
      startId: 22,
      finishId: 23,
      level: 2,
      missions: <Mission>[
        Mission(doneId: 23, mission: "buy_green_pack"),
      ],
    ),
    //done
    Missions(
      startId: 24,
      finishId: 26,
      level: 2,
      missions: <Mission>[
        Mission(doneId: 26, mission: "go_to_islands_of_death"),
      ],
    ),
    //done
    Missions(
      startId: 26,
      finishId: 301,
      level: 2,
      missions: <Mission>[
        Mission(doneId: 26, mission: "go_to_islands_of_death"),
        Mission(doneId: 300, mission: "go_to_first_island"),
        Mission(doneId: 301, mission: "reach_level_3"),
      ],
    ),
    Missions(
      startId: 302,
      finishId: 320,
      level: 3,
      missions: <Mission>[
        Mission(doneId: 320, mission: "defeat_one_player_opponent"),
      ],
    ),
    //done
    Missions(
      startId: 321,
      finishId: 327,
      level: 3,
      missions: <Mission>[
        Mission(doneId: 327, mission: "enhance_a_card_from_cards_building"),
      ],
    ),
    //done
    Missions(
      startId: 401,
      finishId: 402,
      level: 3,
      missions: <Mission>[
        Mission(doneId: 402, mission: "reach_level_4"),
      ],
    ),
    //checked
    Missions(
      startId: 650,
      finishId: 657,
      level: 6,
      missions: <Mission>[
        Mission(doneId: 657, mission: "evolve_apple_from_cards_building"),
      ],
    ),
  ];
}

class Missions {
  int startId;
  int finishId;
  int level;
  List<Mission> missions;
  Missions({
    required this.startId,
    required this.finishId,
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
