// ignore_for_file: constant_identifier_names

//         -=-=-=-    Fruit    -=-=-=-
import 'package:flutter/material.dart';

import 'infra.dart';

enum FriutFields {
  id,
  name,
  smallImage,
  maxLevel,
  minLevel,
  category,
  description,
}

class FruitData extends StringMap<dynamic> {
  T get<T>(FriutFields field) => map[field.name] as T;
}

class Fruits extends StringMap<FruitData> {
  @override
  void init(Map<String, dynamic> data, {dynamic args}) {
    data.forEach((key, value) {
      map[key] = FruitData()..init(value);
    });
  }

  FruitData get(String key) => map[key]!;
}

//         -=-=-=-    Card    -=-=-=-
enum CardFields {
  id,
  fruitId,
  fruit,
  power,
  cooldown,
  image,
  rarity,
  powerLimit,
  virtualRarity,
  name,
  veteran_level,
  heroType,
  isHero,
  powerAttribute,
  wisdomAttribute,
  blessingAttribute,
  potion_limit,
}

class CardData extends StringMap<dynamic> {
  @override
  void init(Map<String, dynamic> data, {dynamic args}) {
    super.init(data);
    map['fruit'] = args as FruitData;
    setDefault('heroType', data, 0);
    setDefault('isHero', data, false);
    setDefault('powerAttribute', data, 0);
    setDefault('wisdomAttribute', data, 0);
    setDefault('blessingAttribute', data, 0);
    setDefault('potion_limit', data, 0);
  }

  T get<T>(CardFields field) => map[field.name] as T;
}

class Cards extends StringMap<CardData> {
  @override
  void init(Map<String, dynamic> data, {dynamic args}) {
    var fruits = args as Fruits;
    data.forEach((key, value) {
      map[key] = CardData()
        ..init(value, args: fruits.get("${value['fruitId']}"));
    });
  }

  CardData get(String key) => map[key]!;
}

class AccountCard {
  late int id;
  late int power;
  late CardData base;
  late int lastUsedAt;
  late GlobalKey key;
  AccountCard(Map map, Cards cards) {
    id = map['id'];
    power = map['power'];
    base = cards.get("${map['base_card_id']}");
    lastUsedAt = map['last_used_at'];
    key = GlobalKey();
  }
}

class HeroCard {
  static const attributeMultiplier = 2;
  static const benefitModifier = 0.01;
  static const benefit_BlessingMaxMultiplier = 4.0;
  static const benefit_WisdomMaxMultiplier = 1.1;
  static const benefit_PowerMaxMultiplier = 5.0;
  static const evolveBaseNectar = 0.08;
  static const fakePowerModifier = 0.016666667;
  static const benefitDecreaseModifier = 3.0;

  final int potion;
  final AccountCard card;
  final List<HeroItem> items;
  HeroCard(this.card, this.potion, this.items);

  // returns the gained attributes by hero based on its equipped items.
  // @param baseId, the base id of hero
  Map<String, int> getGainedAttributesByItems() {
    // setups a table for containing the each value.
    var values = <String, int>{};
    values['power'] = 0;
    values['wisdom'] = 0;
    values['blessing'] = 0;

    // setups the default multipliers for each attribute.
    var powerMultiplier = 1;
    var wisdomMultiplier = 1;
    var blessingMultiplier = 1;
    var heroType = card.base.get<int>(CardFields.heroType);
    if (heroType == 0) {
      powerMultiplier = HeroCard.attributeMultiplier;
    } else if (heroType == 1) {
      wisdomMultiplier = HeroCard.attributeMultiplier;
    } else {
      blessingMultiplier = HeroCard.attributeMultiplier;
    }

    // adds the  attributes for each equipped item.
    for (var item in items) {
      values['power'] = item.base.powerAmount * powerMultiplier;
      values['wisdom'] = item.base.wisdomAmount * wisdomMultiplier;
      values['blessing'] = item.base.blessingAmount * blessingMultiplier;
    }
    return values;
  }
}

class HeroItem {
  final int id, state, position; //, usedCount;
  final BaseHeroItem base;
  HeroItem(
      this.id, this.base, this.state, this.position /* , this.usedCount */);
}

class BaseHeroItem {
  final int id;
  final int powerAmount;
  final int wisdomAmount;
  final int blessingAmount;
  final int cost;
  final int unlockLevel;
  final int category;
  final String image;
  BaseHeroItem(
    this.id,
    this.powerAmount,
    this.wisdomAmount,
    this.blessingAmount,
    this.cost,
    this.unlockLevel,
    this.category,
    this.image,
  );
}
