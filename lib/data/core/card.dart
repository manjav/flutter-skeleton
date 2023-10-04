// ignore_for_file: constant_identifier_names

//         -=-=-=-    Fruit    -=-=-=-
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../utils/utils.dart';
import 'account.dart';
import 'building.dart';
import 'infra.dart';
import 'result.dart';
import 'tribe.dart';

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
  List<CardData> cards = [];
  T get<T>(FriutFields field) => map[field.name] as T;
  bool get isMonster => get<int>(FriutFields.category) == 2;
  bool get isCrystal => get<int>(FriutFields.category) == 3;
  bool get isHero => get<int>(FriutFields.category) == 4;
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

  String get name => map["fruit"].map["name"];

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

  bool contains(CardFields field) => map.containsKey(field.name);
  T get<T>(CardFields field) => map[field.name] as T;
  FruitData get fruit => get<FruitData>(CardFields.fruit);
  int get cost {
    const maxEnhanceModifier = 45;
    const priceModifier = 100;
    return ((priceModifier / maxEnhanceModifier) *
            get<int>(CardFields.powerLimit))
        .floor();
  }

  bool get isHero => fruit.isHero;
}

class Cards extends StringMap<CardData> {
  @override
  void init(Map<String, dynamic> data, {dynamic args}) {
    var fruits = args as Fruits;
    for (var entry in data.entries) {
      var fruit = fruits.get("${entry.value['fruitId']}");
      map[entry.key] = CardData()..init(entry.value, args: fruit);
      fruit.cards.add(map[entry.key]!);
    }
  }

  CardData get(String key) => map[key]!;
}

class AbstractCard {
  late CardData base;
  int id = 0, power = 0, ownerId = 0, lastUsedAt = 0;
  final Map map;
  final Account account;

  AbstractCard(this.account, this.map) {
    power = map['power'].round() ?? 0;
    base = account.loadingData.baseCards.get("${map['base_card_id']}");
  }

  int getRemainingCooldown() {
    var tribe = account.get<Tribe?>(AccountField.tribe);
    var benefit = tribe != null
        ? account.getBuilding(Buildings.cards)!.getBenefit()
        : 1.0;
    var delta = account.now - lastUsedAt;
    var cooldownTime = base.get<int>(CardFields.cooldown) * benefit;
    return (cooldownTime - delta).ceil().min(0);
  }

  FruitData get fruit => base.get<FruitData>(CardFields.fruit);
  bool get isUpgradable =>
      base.get<int>(CardFields.rarity) < fruit.get<int>(FriutFields.maxLevel);

  bool get isMonster {
    var baseId = base.get(CardFields.id);
    if ((baseId >= 310 && baseId <= 319) ||
        (baseId >= 330 && baseId <= 344) ||
        (baseId >= 815 && baseId <= 819)) {
      return true;
    }
    return false;
  }

/* returns the gold cost for purchasing the cooldown of this card, takes into
     account the bonuses that the player's tribe might include and also the number of
     cooldowns the player has purchased within the past day
 */
  int cooldownTimeToCost(int time) {
    num cooldownPrice = 0;
    var veteranLevel = base.get<int>(CardFields.veteran_level);
    if (veteranLevel > 0) {
      var tribe = account.get<Tribe?>(AccountField.tribe);
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

class AuctionCard extends AbstractCard {
  int cardId = 0,
      bidCount = 0,
      maxBid = 0,
      maxBidderId = 0,
      createdAt = 0,
      activityStatus = 0;
  String ownerName = "", maxBidderName = "";
  AuctionCard(super.account, super.map) {
    id = map["id"];
    ownerId = map["owner_id"];
    cardId = map["card_id"];
    bidCount = map["bid_count"];
    maxBid = map["max_bid"];
    maxBidderId = map["max_bidder_id"];
    maxBidderName = map["max_bidder_name"];
    ownerName = map["owner_name"];
    createdAt = map["created_at"];
    activityStatus = map["activity_status"];
  }

  static List<AuctionCard> getList(Account account, list) {
    var result = <AuctionCard>[];
    for (var map in list) {
      result.add(AuctionCard(account, map));
      print(map["base_card_id"]);
    }
    return result;
  }
}

class AccountCard extends AbstractCard {
  bool isDeployed = false;
  AccountCard(super.account, super.map, {int? ownerId}) {
    id = map['id'] ?? -1;
    this.ownerId = ownerId ?? account.get(AccountField.id);
    lastUsedAt = map['last_used_at'] ?? 0;
  }

  Future<void> coolOff(BuildContext context) async {
    try {
      var data = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.coolOff, params: {RpcParams.card_id.name: id});
      lastUsedAt = 0;
      account.update(data);
      if (context.mounted) {
        BlocProvider.of<AccountBloc>(context).add(SetAccount(account: account));
      }
    } on RpcException catch (e) {
      if (e.statusCode == StatusCode.C178_COOL_ENOUGH) {
        lastUsedAt = 0;
      }
    }
  }

  CardData? findNextLevel() {
    var nextLevel = base.get<int>(CardFields.rarity) + 1;
    for (var e in account.loadingData.baseCards.map.entries) {
      if (e.value.get<int>(CardFields.fruitId) ==
              base.get<int>(CardFields.fruitId) &&
          e.value.get<int>(CardFields.rarity) == nextLevel) {
        return e.value;
      }
    }
    return null;
  }

  int getNextLevelPower([AccountCard? second]) {
    const evolveEnhancePowerModifier = 1;
    const monsterEvolveMinRarity = 5;
    const monsterEvolveMaxPower = 300000000;
    const monsterEvolvePowerModifier = 100000000;

    var nextLevelCard = findNextLevel();
    if (nextLevelCard != null) {
      var secondPower = second != null ? second.power : 0;
      var firstBasePower = base.get<int>(CardFields.power);
      var secondBasePower =
          second != null ? second.base.get<int>(CardFields.power) : 0;
      var nextPower = nextLevelCard.get<int>(CardFields.power);
      var diffs = (power - firstBasePower) + (secondPower - secondBasePower);
      diffs *= evolveEnhancePowerModifier;
      var finalPower = nextPower + diffs;

      // Soften Monster's power after adding 6th level of monsters
      if (base.fruit.isMonster) {
        if (base.get<int>(CardFields.rarity) >= monsterEvolveMinRarity) {
          if (finalPower > monsterEvolveMaxPower) {
            finalPower -= monsterEvolvePowerModifier;
          }
        }
      }
      return finalPower;
    }
    return 0;
  }

  AccountCard clone() {
    return AccountCard(
        account,
        {
          "id": id,
          "power": power,
          "last_used_at": lastUsedAt,
          "base_card_id": base.get<int>(CardFields.id),
        },
        ownerId: ownerId);
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

  int potion = 0;
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

  Map<String, int> getNextLevelAttributes() {
    // setups a table for containing the each value.
    var values = <String, int>{};
    values['power'] = 0;
    values['wisdom'] = 0;
    values['blessing'] = 0;
    var nextLevel = card.findNextLevel();
    if (nextLevel == null) {
      return values;
    }

    diff(CardFields f) => nextLevel.get<int>(f) - card.base.get<int>(f);
    values['power'] = diff(CardFields.powerAttribute);
    values['wisdom'] = diff(CardFields.wisdomAttribute);
    values['blessing'] = diff(CardFields.blessingAttribute);
    return values;
  }

  fillPotion(BuildContext context, int value) async {
    var params = {RpcParams.hero_id.name: card.base.get(CardFields.id)};
    if (value > 0) {
      params[RpcParams.potion.name] = value;
    }
    try {
      var data = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.potionize, params: params);
      if (!context.mounted) return;
      data["hero_id"] = card.id;
      var accountBloc = BlocProvider.of<AccountBloc>(context);
      accountBloc.account!.update(data);
      accountBloc.add(SetAccount(account: accountBloc.account!));
    } finally {}
  }

  HeroCard clone() => HeroCard(card, potion)..items = List.from(items);
  Map<String, dynamic> getResult() {
    var items = [];
    for (var item in this.items) {
      items.add({"base_heroitem_id": item.base.id, "position": item.position});
    }
    return {"hero_id": card.base.get<int>(CardFields.id), "items": items};
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

  HeroItem? getUsage(Iterable<HeroItem> items) =>
      items.firstWhereOrNull((item) => item.base.id == id);

  HeroCard? getHost(List<HeroCard> heroes) {
    for (var hero in heroes) {
      for (var item in hero.items) {
        if (item.base.id == id) return hero;
      }
    }
    return null;
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
