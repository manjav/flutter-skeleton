// ignore_for_file: constant_identifier_names

//         -=-=-=-    Fruit    -=-=-=-
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../skeleton/data/result.dart';
import '../../skeleton/mixins/service_finder_mixin.dart';
import '../../skeleton/utils/utils.dart';
import 'account.dart';
import 'building.dart';

class Fruit {
  late String name;
  late int id, maxLevel, minLevel, category;

  List<FruitCard> cards = [];
  bool get isSalable => category < 3;
  bool get isChristmas => category == 1;
  bool get isMonster => category == 2;
  bool get isCrystal => category == 3;
  bool get isHero => category == 4;

  Fruit.initialize(Map<String, dynamic> data) {
    name = data["name"];
    id = Utils.toInt(data["id"]);
    // smallImage = data["smallImage"];
    // description = data["description"];
    maxLevel = Utils.toInt(data["maxLevel"]);
    minLevel = Utils.toInt(data["minLevel"]);
    category = Utils.toInt(data["category"]);
  }

  static Map<int, Fruit> generateMap(Map<String, dynamic> data) {
    Map<int, Fruit> map = {};
    data.forEach((key, value) {
      map[Utils.toInt(key)] = Fruit.initialize(value);
    });
    return map;
  }
}

//         -=-=-=-    Card    -=-=-=-
class FruitCard {
  static const cooldownCostModifier = 0.25;
  static const cooldownIncreaseModifier = 0.2;
  static const veteranCooldownModifier = 0.1;

  late int id,
      power,
      rarity,
      cooldown,
      powerLimit,
      veteranLevel,
      heroType,
      potionLimit;
  Map<HeroAttribute, int> attributes = {};

  double virtualRarity = 1.0;

  final Fruit fruit;
  String name = "";
  bool isHero = false;

  FruitCard.initialize(Map<String, dynamic> data, this.fruit) {
    name = data["name"];
    isHero = data["isHero"] ?? false;
    id = Utils.toInt(data["id"]);
    virtualRarity = data["virtualRarity"].toDouble();
    power = Utils.toInt(data["power"]);
    rarity = Utils.toInt(data["rarity"]);
    heroType = Utils.toInt(data["heroType"], -1);
    cooldown = Utils.toInt(data["cooldown"]);
    powerLimit = Utils.toInt(data["powerLimit"]);
    veteranLevel = Utils.toInt(data["veteran_level"]);

    attributes[HeroAttribute.power] = Utils.toInt(data["powerAttribute"]);
    attributes[HeroAttribute.wisdom] = Utils.toInt(data["wisdomAttribute"]);
    attributes[HeroAttribute.blessing] = Utils.toInt(data["blessingAttribute"]);
    potionLimit = Utils.toInt(data["potion_limit"]);
  }

  String getName() => isHero ? fruit.name : name;

  int get cost {
    const maxEnhanceModifier = 45;
    const priceModifier = 100;
    return ((priceModifier / maxEnhanceModifier) * powerLimit).floor();
  }

  static Map<int, FruitCard> generateMap(
      Map<String, dynamic> data, Map<int, Fruit> fruits) {
    Map<int, FruitCard> map = {};
    for (var entry in data.entries) {
      var fruit = fruits[entry.value['fruitId']]!;
      var card = FruitCard.initialize(entry.value, fruit);
      map[card.id] = card;
      fruit.cards.add(card);
    }
    return map;
  }
}

class AbstractCard with ServiceFinderMixin {
  static double powerToGoldRatio = 8.0;
  static double minPriceRatio = 0.75;
  static double maxPriceRatio = 1.5;
  static double bidStepRatio = 0.05;

  late FruitCard base;
  int id = 0, power = 0, ownerId = 0, lastUsedAt = 0;
  final Map map;
  final Account account;

  AbstractCard(this.account, this.map) {
    power = map['power'] != null ? map['power'].round() : 0;
    base = account.loadingData.baseCards[map['base_card_id']]!;
  }
  int get basePrice => (power * powerToGoldRatio * minPriceRatio).round();
  int get bidStep => (power * powerToGoldRatio * bidStepRatio).round();
  int get maxPrice => (power * powerToGoldRatio * maxPriceRatio).round();

  int getRemainingCooldown() {
    var benefit = account.tribe != null
        ? account.buildings[Buildings.cards]!.getBenefit()
        : 1.0;
    var delta = account.getTime() - lastUsedAt;
    var cooldownTime = base.cooldown * benefit;
    return (cooldownTime - delta).ceil().min(0);
  }

  Fruit get fruit => base.fruit;
  bool get isUpgradable => base.rarity < fruit.maxLevel;

  bool get isMonster {
    return switch (base.id) {
      (>= 310 && <= 319) || (>= 330 && <= 344) || (>= 815 && <= 819) => true,
      _ => false,
    };
  }

/* returns the gold cost for purchasing the cooldown of this card, takes into
     account the bonuses that the player's tribe might include and also the number of
     cooldowns the player has purchased within the past day
 */
  int cooldownTimeToCost(int time) {
    num cooldownPrice = 0;
    var veteranLevel = base.veteranLevel;
    if (veteranLevel > 0) {
      var benefit = account.tribe != null
          ? account.buildings[Buildings.cards]!.getBenefit()
          : 1.0;
      cooldownPrice = _cooldownTimeToCost(base.cooldown) *
          FruitCard.veteranCooldownModifier *
          benefit *
          veteranLevel;
    } else {
      // the tribe building benefit is already calculated in remaining time
      cooldownPrice = _cooldownTimeToCost(time);
    }
    return cooldownPrice.ceil();
  }

  num _cooldownTimeToCost(int time) {
    var cooldownsBoughtToday = account.cooldowns_bought_today + 1;
    return time *
        (cooldownsBoughtToday * FruitCard.cooldownIncreaseModifier).ceil() *
        FruitCard.cooldownCostModifier;
  }
}

class AuctionCard extends AbstractCard {
  int cardId = 0,
      bidCount = 0,
      maxBid = 0,
      maxBidderId = 0,
      createdAt = 0,
      activityStatus = 0,
      lastBidderId = 0,
      lastBidderGold = 0;
  String ownerName = "", maxBidderName = "";
  bool ownerIsMe = false, winnerIsMe = false, loserIsMe = false;

  AuctionCard(super.account, super.map) {
    id = map["id"];
    ownerId = map["owner_id"];
    cardId = map["card_id"];
    bidCount = map["bid_count"];
    maxBid = map["max_bid"];
    maxBidderId = Utils.toInt(map["max_bidder_id"]);
    maxBidderName = map["max_bidder_name"];
    ownerName = map["owner_name"];
    createdAt = map["created_at"];
    activityStatus = map["activity_status"];
    lastBidderId = Utils.toInt(map["last_bidder_id"]);
    lastBidderGold = Utils.toInt(map["last_bidder_gold"]);
    ownerIsMe = account.id == ownerId;
    winnerIsMe = account.id == maxBidderId;
    loserIsMe = account.id == lastBidderId;
  }

  static Map<int, AuctionCard> getList(Account account, list) {
    var result = <int, AuctionCard>{};
    for (var map in list) {
      result[map["id"]] = AuctionCard(account, map);
    }
    return result;
  }
}

class AccountCard extends AbstractCard {
  bool isDeployed = false;
  AccountCard(super.account, super.map, {int? ownerId}) {
    id = map['id'] ?? -1;
    this.ownerId = ownerId ?? account.id;
    lastUsedAt = map['last_used_at'] ?? 0;
  }

  Future<void> coolOff(BuildContext context) async {
    try {
      var data = await getService<HttpConnection>(context)
          .tryRpc(context, RpcId.coolOff, params: {RpcParams.card_id.name: id});
      lastUsedAt = 0;
      if (context.mounted) {
        getAccountProvider(context).update(context, data);
      }
    } on SkeletonException catch (e) {
      if (e.statusCode == StatusCode.C178_CARD_ALREADY_COOL) {
        lastUsedAt = 0;
      }
    }
  }

  FruitCard? findNextLevel() {
    var nextLevel = base.rarity + 1;
    for (var e in account.loadingData.baseCards.entries) {
      if (e.value.fruit.id == base.fruit.id && e.value.rarity == nextLevel) {
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
      var firstBasePower = base.power;
      var secondBasePower = second != null ? second.base.power : 0;
      var nextPower = nextLevelCard.power;
      var diffs = (power - firstBasePower) + (secondPower - secondBasePower);
      diffs *= evolveEnhancePowerModifier;
      var finalPower = nextPower + diffs;

      // Soften Monster's power after adding 6th level of monsters
      if (base.fruit.isMonster) {
        if (base.rarity >= monsterEvolveMinRarity) {
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
          "base_card_id": base.id,
          "last_used_at": lastUsedAt,
        },
        ownerId: ownerId);
  }
}

enum HeroAttribute { power, wisdom, blessing }

extension HeroAttributesExtesion on HeroAttribute {
  String get benefit {
    return switch (this) {
      HeroAttribute.wisdom => "cooldown",
      HeroAttribute.blessing => "gold",
      _ => name,
    };
  }
}

class HeroCard with ServiceFinderMixin {
  static const attributeMultiplier = 2;
  static const benefitModifier = 0.01;
  static const benefit_maxMultipliers = {
    HeroAttribute.power: 5.0,
    HeroAttribute.wisdom: 1.1,
    HeroAttribute.blessing: 4.0,
  };
  static const evolveBaseNectar = 0.08;
  static const fakePowerModifier = 0.016666667;
  static const benefitDecreaseModifier = 3.0;

  int potion = 0;
  final AccountCard card;
  List<HeroItem> items = [];
  HeroCard(this.card, this.potion);

  // returns the gained attributes by hero based on its equipped items.
  // @param base.id, the base id of hero
  Map<HeroAttribute, int> getGainedAttributesByItems() {
    // setups a table for containing the each value.
    var values = <HeroAttribute, int>{
      HeroAttribute.power: 0,
      HeroAttribute.wisdom: 0,
      HeroAttribute.blessing: 0
    };

    // setups the default multipliers for each attribute.
    var multipliers = <HeroAttribute, int>{
      HeroAttribute.power: 1,
      HeroAttribute.wisdom: 1,
      HeroAttribute.blessing: 1
    };

    var heroType = card.base.heroType;
    if (heroType == 0) {
      multipliers[HeroAttribute.power] = HeroCard.attributeMultiplier;
    } else if (heroType == 1) {
      multipliers[HeroAttribute.wisdom] = HeroCard.attributeMultiplier;
    } else {
      multipliers[HeroAttribute.blessing] = HeroCard.attributeMultiplier;
    }

    // adds the  attributes for each equipped item.
    concatItemAttribute(HeroAttribute attribute, HeroItem item) {
      values[attribute] = values[attribute]! +
          item.base.attributes[attribute]! * multipliers[attribute]!;
    }

    for (var item in items) {
      concatItemAttribute(HeroAttribute.power, item);
      concatItemAttribute(HeroAttribute.wisdom, item);
      concatItemAttribute(HeroAttribute.blessing, item);
    }
    return values;
  }

  Map<HeroAttribute, int> getNextLevelAttributes() {
    // setups a table for containing the each value.
    var values = <HeroAttribute, int>{
      HeroAttribute.power: 0,
      HeroAttribute.wisdom: 0,
      HeroAttribute.blessing: 0,
    };
    var nextLevelCard = card.findNextLevel();
    if (nextLevelCard == null) {
      return values;
    }

    diff(HeroAttribute f) =>
        nextLevelCard.attributes[f]! - card.base.attributes[f]!;
    values[HeroAttribute.power] = diff(HeroAttribute.power);
    values[HeroAttribute.wisdom] = diff(HeroAttribute.wisdom);
    values[HeroAttribute.blessing] = diff(HeroAttribute.blessing);
    return values;
  }

  fillPotion(BuildContext context, int value) async {
    var params = {RpcParams.hero_id.name: card.base.id};
    if (value > 0) {
      params[RpcParams.potion.name] = value;
    }
    try {
      var data = await getService<HttpConnection>(context)
          .tryRpc(context, RpcId.potionize, params: params);
      if (!context.mounted) return;
      data["hero_id"] = card.id;
      getAccountProvider(context).update(context, data);
    } finally {}
  }

  HeroCard clone() => HeroCard(card, potion)..items = List.from(items);
  Map<String, dynamic> getResult() {
    var items = [];
    for (var item in this.items) {
      items.add({"base_heroitem_id": item.base.id, "position": item.position});
    }
    return {"hero_id": card.base.id, "items": items};
  }
}

class HeroItem {
  final int id, state;
  final BaseHeroItem base;
  int position = 0;
  HeroItem(this.id, this.base, this.state);
}

class BaseHeroItem {
  Map<HeroAttribute, int> attributes = {};
  int id = 0,
      itemType = 0,
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
        ..cost = item["cost"]
        ..unlockLevel = item["unlock_level"]
        ..category = item["category"]
        ..compatibility = item["compatibility"]
        ..image = item["image"]
        ..attributes = {
          HeroAttribute.power: item["powerAmount"],
          HeroAttribute.wisdom: item["wisdomAmount"],
          HeroAttribute.blessing: item["blessingAmount"],
        };
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
        ..type = item["type"]
        ..cost = item["cost"]
        ..fruit = item["fruit"]
        ..level = item["level"]
        ..count = item["count"]
        ..power = item["power"]
        ..benefit = item["benefit"]
        ..icon = item["smallImage"]);
    }
    return result;
  }
}

class SelectedCards extends ValueNotifier<List<AccountCard?>> {
  SelectedCards(super.value);
  double get count => value.length.toDouble();
  setAtCard(int index, AccountCard? card, {bool toggleMode = true}) {
    value[index] = toggleMode && value[index] == card ? null : card;
    notifyListeners();
  }

  getIds() =>
      "[${value.map((c) => c?.id).where((id) => id != null).join(',')}]";

  bool setCard(AccountCard card, {int exception = -1, int? length}) {
    var index = value.indexOf(card);
    if (index > -1) {
      setAtCard(index, null);
      return true;
    }

    var len = length ?? value.length;
    for (var i = 0; i < len; i++) {
      if (i != exception && value[i] == null) {
        setAtCard(i, card);
        return true;
      }
    }

    var weakest = double.infinity;
    var weakestPosition = 3;
    for (var i = 0; i < len; i++) {
      if (i != exception && value[i]!.power < weakest) {
        weakest = value[i]!.power.toDouble();
        weakestPosition = i;
      }
    }
    setAtCard(weakestPosition, card);
    return false;
  }

  void addCard(AccountCard card) {
    if (value.contains(card)) {
      value.remove(card);
    } else {
      value.add(card);
    }
    notifyListeners();
  }

  void clear({bool setNull = false}) {
    if (setNull) {
      for (var i = 0; i < value.length; i++) {
        value[i] = null;
      }
    } else {
      value.clear();
    }
    notifyListeners();
  }

  void remove(AccountCard card) {
    value.remove(card);
    notifyListeners();
  }

  void removeWhere(bool Function(AccountCard?) test) {
    value.removeWhere(test);
    notifyListeners();
  }
}
