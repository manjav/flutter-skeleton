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
}

class CardData extends StringMap<dynamic> {
  @override
  void init(Map<String, dynamic> data, {dynamic args}) {
    super.init(data);
    map['fruit'] = args as FruitData;
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
