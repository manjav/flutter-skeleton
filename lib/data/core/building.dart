// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unused_local_variable

import 'package:flutter_skeleton/data/core/account.dart';
import 'package:flutter_skeleton/data/core/card.dart';
import 'package:flutter_skeleton/utils/utils.dart';

import 'infra.dart';

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
  static const goldMinePowerModifier1 = 0.7; //per hour
  static const goldMinePowerModifier2 = 3.0; //per hour
  static const offensePowerModifier = 0.1;
  static const defensePowerModifier = 0.1;
  static const maxLevels = 10;

  int get level => map['level'];
  Buildings get type => map['type'];
  List<int> get cards => map['cards'];

  T get<T>(BuildingField fieldName) => map[fieldName.name] as T;
}
}
