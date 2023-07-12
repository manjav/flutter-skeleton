
enum Buildings {
  base,
  cards,
  defence,
  message,
  mine,
  offence,
  shop,
  treasury,
  tribe,
  quest,
  auction,
}

enum BuildingField { type, cards, level }

class Building extends StringMap<dynamic> {
  static const Building_GoldMinePowerModifier1 = 0.7; //per hour
  static const Building_GoldMinePowerModifier2 = 3.0; //per hour
  static const Building_OffensePowerModifier = 0.1;
  static const Building_DefensePowerModifier = 0.1;
  static const maxLevels = 10;

  int get level => map['level'];
  Buildings get type => map['type'];
  List<int> get cards => map['cards'];

}
}
