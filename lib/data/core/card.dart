// ignore_for_file: constant_identifier_names

//         -=-=-=-    Fruit    -=-=-=-
import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import 'account.dart';
import 'building.dart';
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
  static const cooldownCostModifier = 0.25;
  static const cooldownIncreaseModifier = 0.2;
  static const veteranCooldownModifier = 0.1;

  @override
  void init(Map<String, dynamic> data, {dynamic args}) {
    super.init(data);
    map['fruit'] = args as FruitData;
    setDefault('heroType', data, -1);
    setDefault('isHero', data, false);
    setDefault('powerAttribute', data, 0);
    setDefault('wisdomAttribute', data, 0);
    setDefault('blessingAttribute', data, 0);
    setDefault('potion_limit', data, 0);
  }

  T get<T>(CardFields field) => map[field.name] as T;

  int get cost {
    const maxEnhanceModifier = 45;
    const priceModifier = 100;
    return ((priceModifier / maxEnhanceModifier) *
            get<int>(CardFields.powerLimit))
        .floor();
  }

  bool get isMonster =>
      get<FruitData>(CardFields.fruit).get<int>(FriutFields.category) == 2;
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
  final Account account;
  late GlobalKey key;
  AccountCard(this.account, Map map, Cards cards) {
    id = map['id'] ?? -1;
    power = map['power'];
    base = cards.get("${map['base_card_id']}");
    lastUsedAt = map['last_used_at'] ?? 0;
    key = GlobalKey();
  }

  int getRemainingCooldown() {
    var currentTime = DateTime.now().secondsSinceEpoch +
        account.get<int>(AccountField.delta_time);
    var tribe = account.getBuilding(Buildings.tribe);
    var benefit = tribe != null
        ? account.getBuilding(Buildings.cards)!.getBenefit()
        : 1.0;
    var delta = currentTime - lastUsedAt;
    var cooldownTime = base.get<int>(CardFields.cooldown) * benefit;
    return (cooldownTime - delta).ceil().min(0);
  }

  bool get isMonster {
    var baseId = base.get(CardFields.id);
    if ((baseId >= 310 && baseId <= 319) ||
        (baseId >= 330 && baseId <= 344) ||
        (baseId >= 815 && baseId <= 819)) {
      return true;
    }
    return false;
  }

  bool get isHero => base.get(CardFields.isHero);

/* returns the gold cost for purchasing the cooldown of this card, takes into
     account the bonuses that the player's tribe might include and also the number of
     cooldowns the player has purchased within the past day
 */
  int cooldownTimeToCost(int time) {
    num cooldownPrice = 0;
    var veteranLevel = base.get<int>(CardFields.veteran_level);
    if (veteranLevel > 0) {
      var tribe = account.getBuilding(Buildings.tribe);
      var benefit = tribe != null
          ? account.getBuilding(Buildings.cards)!.getBenefit()
          : 1.0;
      cooldownPrice = _cooldownTimeToCost(base.get<int>(CardFields.cooldown)) *
          CardData.veteranCooldownModifier *
          benefit *
          veteranLevel;
    } else {
      // the tribe building benefit is already calculated in remaining time
      cooldownPrice = _cooldownTimeToCost(time);
    }
    return cooldownPrice.ceil();
  }

  num _cooldownTimeToCost(int time) {
    var cooldownsBoughtToday =
        account.get<int>(AccountField.cooldowns_bought_today) + 1;
    return time *
        (cooldownsBoughtToday * CardData.cooldownIncreaseModifier).ceil() *
        CardData.cooldownCostModifier;
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
  List<HeroItem> items = [];
  HeroCard(this.card, this.potion);

  // returns the gained attributes by hero based on its equipped items.
  // @param baseId, the base id of hero
  Map<String, int> getGainedAttributesByItems() {
    // setups a table for containing the each value.
    var values = <String, int>{};
    values['power'] = 0;
    values['wisdom'] = 0;
    values['blessing'] = 0;

    // setups the default multipliers for each attribute.
    var powerMultiplier = 1, wisdomMultiplier = 1, blessingMultiplier = 1;
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
      values['power'] =
          values['power']! + item.base.powerAmount * powerMultiplier;
      values['wisdom'] =
          values['wisdom']! + item.base.wisdomAmount * wisdomMultiplier;
      values['blessing'] =
          values['blessing']! + item.base.blessingAmount * blessingMultiplier;
    }
    return values;
  }
}

class HeroItem {
  final int id, state;
  final BaseHeroItem base;
  int position = 0;
  HeroItem(this.id, this.base, this.state);
}

class BaseHeroItem {
  int id = 0,
      itemType = 0,
      powerAmount = 0,
      wisdomAmount = 0,
      blessingAmount = 0,
      cost = 0,
      unlockLevel = 0,
      compatibility = 0,
      category = 0;
  String image = "";
  static Map<int, BaseHeroItem> init(List<dynamic> data) {
    var result = <int, BaseHeroItem>{};
    for (var item in data) {
      result[item["id"]] = BaseHeroItem()
        ..id = item["id"]
        ..itemType = item["itemType"]
        ..powerAmount = item["powerAmount"]
        ..wisdomAmount = item["wisdomAmount"]
        ..blessingAmount = item["blessingAmount"]
        ..cost = item["cost"]
        ..unlockLevel = item["unlock_level"]
        ..category = item["category"]
        ..compatibility = item["compatibility"]
        ..image = item["image"];
    }
    return result;
  }
}

class ComboHint {
  int id = 0,
      fruit = 0,
      benefit = 0,
      type = 0,
      cost = 0,
      level = 0,
      count = 0,
      power = 0;
  String icon = "";
  bool isAvailable = false;
  static List<ComboHint> init(List<dynamic> data) {
    var result = <ComboHint>[ComboHint()];
    for (var item in data) {
      result.add(ComboHint()
        ..id = item["id"]
        ..fruit = item["fruit"]
        ..benefit = item["benefit"]
        ..type = item["type"]
        ..cost = item["cost"]
        ..level = item["level"]
        ..count = item["count"]
        ..power = item["power"]
        ..icon = item["smallImage"]);
    }
    return result;
  }
}
