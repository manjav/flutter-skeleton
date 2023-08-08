// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unused_local_variable

import 'dart:math' as math;

import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../utils/utils.dart';
import 'infra.dart';

enum Buildings {
  base,
  cards,
  defense,
  message,
  mine,
  offense,
  shop,
  treasury,
  tribe,
  quest,
  auction,
}

extension BuildingExtension on Buildings {
  int get id {
    return switch (this) {
      Buildings.mine => 1001,
      Buildings.offense => 1002,
      Buildings.defense => 1003,
      Buildings.cards => 1004,
      Buildings.base => 1005,
      Buildings.treasury => 1007,
      _ => 1000,
    };
  }
}

enum BuildingField {
  type,
  cards,
  level,
  // Tribe fields
  id,
  name,
  description,
  score,
  rank,
  gold,
  member_count,
  defense_building_level,
  offense_building_level,
  cooldown_building_level,
  mainhall_building_level,
  donates_number,
  status,
  weekly_score,
  weekly_rank,
}

class Building extends StringMap<dynamic> {
  static const goldMinePowerModifier1 = 0.7; //per hour
  static const goldMinePowerModifier2 = 3.0; //per hour
  static const offensePowerModifier = 0.1;
  static const defensePowerModifier = 0.1;
  static const maxLevels = 10;

  int get level => map['level'];
  Buildings get type => map['type'];
  List<AccountCard?> get cards => map['cards'];
  T get<T>(BuildingField fieldName) => map[fieldName.name] as T;

  @override
  void init(Map<String, dynamic> data, {args}) {
    super.init(data, args: args);
    var account = args['account']! as Account;
    var cards = List.generate(
        4,
        (i) => i < args['cards'].length
            ? account.getCards()[args['cards'][i]['id']]
            : null);
    map['cards'] = cards;
  }

  int get maxLevel {
    return switch (type) {
      Buildings.treasury => 7,
      Buildings.mine => 8,
      _ => 0
    };
  }

  int get upgradeCost {
    var values = <Buildings, List<int>>{};
    values[Buildings.mine] = [0, 20, 40, 80, 300, 1500, 3500, 9000];
    values[Buildings.offense] = [
      20,
      50,
      75,
      110,
      170,
      250,
      380,
      570,
      850,
      1300,
      2000,
      4000,
      8000,
      16000,
      32000,
      64000,
      128000,
      256000,
      400000,
      500000,
      600000,
      700000,
      800000,
      900000,
      1000000,
      1200000,
      1400000,
      1600000,
      1800000,
      2000000,
      2500000,
      3000000,
      3500000,
      4000000,
      4700000,
      5400000,
      6100000,
      6800000,
      7500000,
      8400000,
      9300000,
      10400000,
      11500000,
      13000000
    ];
    values[Buildings.defense] = [
      0,
      40,
      60,
      90,
      135,
      200,
      300,
      455,
      680,
      1025,
      1800,
      3600,
      7200,
      14400,
      28800,
      32000,
      64000,
      128000,
      256000,
      400000,
      500000,
      600000,
      700000,
      800000,
      900000,
      1000000,
      1200000,
      1400000,
      1600000,
      1800000,
      2100000,
      2400000,
      2700000,
      3200000,
      3700000,
      4200000,
      4700000,
      5400000,
      6100000,
      6800000,
      7600000,
      8400000,
      9200000,
      10000000
    ];
    values[Buildings.cards] = [
      15,
      40,
      60,
      90,
      135,
      200,
      300,
      450,
      680,
      1025,
      1250,
      1500,
      1750,
      2000,
      2250,
      2500,
      2750,
      3000,
      3500,
      4000,
      4500,
      5000,
      6000,
      7000,
      8000,
      9000,
      10000,
      12000,
      15000,
      20000,
      50000,
      100000,
      300000,
      500000,
      1000000,
      1500000,
      3000000,
      4500000,
      9000000,
      12500000
    ];
    values[Buildings.base] = [0, 30, 80, 120, 180, 270, 400, 1350];
    values[Buildings.treasury] = [0, 2, 5, 30, 100, 250, 1000];

    return values[type]![(values[type]!.length - 1).max(level)] * 1000;
  }

  int get benefit {
    if (level == 0) return 0;
    if (type == Buildings.base) {
      return level.max(10) * 5 + 10;
    }
    var values = <Buildings, List<int>>{};

    values[Buildings.mine] = [
      0,
      200,
      1000,
      3000,
      10000,
      40000,
      100000,
      300000,
      500000
    ];
    values[Buildings.offense] = values[Buildings.defense] = [
      0,
      5,
      10,
      15,
      20,
      25,
      30,
      35,
      40,
      45,
      50,
      55,
      60,
      65,
      70,
      75,
      77,
      82,
      84,
      85,
      86,
      87,
      88,
      89,
      90,
      91,
      92,
      93,
      94,
      95,
      96,
      97,
      98,
      99,
      100,
      101,
      102,
      103,
      104,
      105,
      106,
      107,
      108,
      110
    ];
    values[Buildings.cards] = [
      0,
      5,
      9,
      13,
      17,
      19,
      22,
      24,
      26,
      28,
      30,
      31,
      32,
      33,
      34,
      35,
      36,
      37,
      38,
      39,
      40,
      41,
      42,
      43,
      44,
      45,
      46,
      47,
      48,
      49,
      50,
      49,
      48,
      47,
      46,
      45,
      44,
      43,
      42,
      41,
      40
    ];
    values[Buildings.treasury] = [
      0,
      1000,
      5000,
      10000,
      30000,
      100000,
      250000,
      1000000
    ];
    return values[type]![(values[type]!.length - 1).max(level)];
  }

  int isAvailableCardHolder(int index) {
    if (type == Buildings.offense || type == Buildings.defense) {
      return switch (level) { < 1 => 1, < 2 => 3, < 3 => 6, _ => 10 };
    }
    if (type == Buildings.mine) {
      return index + 1;
    }
    return 1;
  }

  int get maxCards {
    if (type == Buildings.offense || type == Buildings.defense) {
      return switch (level) { < 1 => 0, < 3 => 1, < 6 => 2, < 10 => 3, _ => 4 };
    }
    if (type == Buildings.mine) {
      return level.max(4);
    }
    return 4;
  }

  double getBenefit() {
    if (type == Buildings.offense || type == Buildings.defense) {
      return 1 + benefit / 100;
    }
    if (type == Buildings.cards) {
      return 1 - benefit / 100;
    }
    return benefit.toDouble();
  }

  int getCardsBenefit(Account account) {
    var totalPower = 0.0;
    // a table for storing the hero cards benefits.
    var heroCardBenefits = <CardData, Map<String, int>>{};
    var heros = account.get<Map<int, HeroCard>>(AccountField.heroes);

    for (var card in cards) {
      if (card == null) continue;
      totalPower += card.power;

      // stores the gained attributes of items for hero cards.
      if (card.base.isHero) {
        heroCardBenefits[card.base] =
            heros[card.id]!.getGainedAttributesByItems();
      }
    }

    if (type == Buildings.mine) {
      var blessingBenefit = 0.0; // default benefit of blessing value

      // adds benefit(blessing items + base blessing) of each assigned hero
      for (var e in heroCardBenefits.entries) {
        blessingBenefit +=
            e.value['blessing']! + e.key.get<int>(CardFields.blessingAttribute);
      }

      // modifies the final blessing benefit with related modifiers.
      blessingBenefit *= HeroCard.benefitModifier *
          HeroCard.benefit_BlessingMaxMultiplier /
          HeroCard.benefitDecreaseModifier;

      // Applies blessing benefit to total power if(there is blessing benefit.
      if (blessingBenefit > 0) {
        totalPower += (totalPower * blessingBenefit);
      }

      return (math.pow(totalPower, goldMinePowerModifier1) *
              goldMinePowerModifier2)
          .floor();
    } else {
      var buildingPowerModifier = 0.0;
      if (type == Buildings.offense) {
        buildingPowerModifier = offensePowerModifier;
      } else if (type == Buildings.defense) {
        buildingPowerModifier = defensePowerModifier;
      }

      var powerBenefit = 0.0; // default benefit of blessing value
      // adds blessing benefit( blessing from items + base blessing) of each assigned hero

      for (var e in heroCardBenefits.entries) {
        powerBenefit +=
            e.value['power']! + e.key.get<int>(CardFields.powerAttribute);
      }

      // modifies the final blessing benefit with related modifiers.
      powerBenefit *= HeroCard.benefitModifier *
          HeroCard.benefit_PowerMaxMultiplier /
          HeroCard.benefitDecreaseModifier;

      // Applies blessing benefit to total power if(there is blessing benefit.
      if (powerBenefit > 0) {
        totalPower += (totalPower * powerBenefit);
      }
      return (totalPower * buildingPowerModifier).floor();
    }
  }
}
