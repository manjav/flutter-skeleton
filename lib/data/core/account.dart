// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:math' as math;

import '../../services/localization.dart';
import '../../utils/utils.dart';
import 'adam.dart';
import 'building.dart';
import 'fruit.dart';
import 'infra.dart';
import 'rpc_data.dart';
import 'tribe.dart';

class Player extends Opponent {
  late int gender,
      birthYear,
      wonBattlesCount,
      lostBattlesCount,
      moodId,
      updatedAt,
      lastLoadAt,
      tribeRanklastLoadAt,
      tribeRank,
      prevLeagueId,
      prevLeagueRank;

  late String realname, address, phone, tribe_name;
  Map<int, int> medals = {};

  Player.initialize(Map<String, dynamic> map, int ownerId)
      : super.initialize(map, ownerId) {
    moodId = Utils.toInt(map["mood_id"]);
    gender = Utils.toInt(map["gender"]);
    birthYear = Utils.toInt(map["birth_year"]);
    updatedAt = Utils.toInt(map["updated_at"]);
    lastLoadAt = Utils.toInt(map["last_load_at"]);
    tribeRank = Utils.toInt(map["tribe_rank"]);
    prevLeagueId = Utils.toInt(map["prev_league_id"]);
    prevLeagueRank = Utils.toInt(map["prev_league_rank"]);
    wonBattlesCount = Utils.toInt(map["won_battle_num"]);
    lostBattlesCount = Utils.toInt(map["lost_battle_num"]);

    phone = map["phone"] ?? "";
    address = map["address"] ?? "";
    realname = map["realname"] ?? "";

    if (map.containsKey("medals") && map["medals"].isNotEmpty) {
      for (var e in map["medals"].entries) {
        medals[int.parse(e.key)] = e.value;
      }
    }
  }
}

class Account extends Player {
  Account() : super.initialize({}, 0);
  static const Map<String, int> availablityLevels = {
    'ads': 4,
    'name': 4,
    'bank': 5,
    'tribe': 6,
    'league': 8,
    'liveBattle': 9,
    'combo': 15,
    'tribeChange': 150,
  };
  static const levelExpo = 2.7;
  static const levelMultiplier = 1.3;

  static int getXpRequiered(int level) =>
      (math.pow(level, levelExpo) * levelMultiplier).ceil();
  late LoadingData loadingData;

  late String restoreKey,
      inviteKey,
      emergency_message,
      update_message,
      latest_app_version,
      latest_app_version_for_notice;

  late int q,
      potion,
      nectar,
      weekly_score,
      activity_status,
      new_messages,
      cooldowns_bought_today,
      total_quests,
      total_battles,
      bank_account_balance,
      last_gold_collect_at,
      tutorial_id,
      tutorial_index,
      avatar_slots,
      gold_collection_allowed_at,
      gold_collection_extraction,
      cards_view,
      league_remaining_time,
      bonus_remaining_time,
      potionPrice,
      nectarPrice,
      hero_id,
      hero_max_rarity,
      base_hero_id,
      wheel_of_fortune_opens_in,
      latest_constants_version,
      deltaTime,
      xpboostCreatedAt,
      pwboostCreatedAt,
      xpboostId,
      pwboostId;

  late bool needs_captcha,
      has_email,
      gold_collection_allowed,
      is_existing_player,
      is_name_temp,
      better_vitrin_promotion,
      can_use_vitrin,
      can_watch_advertisment,
      purchase_deposits_to_bank,
      better_choose_deck,
      better_quest_map,
      better_battle_outcome_navigation,
      better_tutorial_background,
      better_tutorial_steps,
      more_xp,
      better_gold_pack_multiplier,
      better_gold_pack_ratio,
      better_gold_pack_ratio_on_price,
      better_league_tutorial,
      better_enhance_tutorial,
      better_mine_building_status,
      is_mine_building_limited,
      retouched_tutorial,
      better_card_graphic,
      durable_buildings_name,
      show_task_until_levelup,
      better_restore_button_label,
      better_quest_tutorial,
      hero_tutorial_at_first,
      hero_tutorial_at_first_and_selected,
      hero_tutorial_at_first_and_selected_and_animated,
      hero_tutorial_at_level_four,
      hero_tutorial_at_second_quest,
      fall_background,
      unified_gold_icon,
      send_all_tutorial_steps,
      rolling_gold,
      coach_test,
      mobile_number_verified,
      wheel_of_fortune;

  dynamic avatars,
      owned_avatars,
      achievements,
      achievements_blob,
      sale_info,
      bundles,
      dailyReward,
      coach_info,
      coaching,
      modules_version,
      available_combo_id_set;

  Tribe? tribe;
  Map<Buildings, Building> buildings = {};
  Map<int, AccountCard> cards = {};
  List<int> collection = [];
  List<Deadline> deadlines = [];
  Map<int, HeroCard> heroes = {};
  Map<int, HeroItem> heroitems = {};

  int get now => DateTime.now().secondsSinceEpoch + deltaTime;

  Account.initialize(Map<String, dynamic> map, this.loadingData)
      : super.initialize(map, map["id"]) {
    deltaTime = map['now'] - DateTime.now().secondsSinceEpoch;

    // Integers
    q = Utils.toInt(map["q"]);
    xp = Utils.toInt(map["xp"]);
    nectar = Utils.toInt(map["nectar"]);
    potion = Utils.toInt(map["potion_number"]);
    activity_status = Utils.toInt(map["activity_status"]);
    weekly_score = Utils.toInt(map["weekly_score"]);
    new_messages = Utils.toInt(map["new_messages"]);
    cooldowns_bought_today = Utils.toInt(map["cooldowns_bought_today"]);
    total_quests = Utils.toInt(map["total_quests"]);
    total_battles = Utils.toInt(map["total_battles"]);
    bank_account_balance = Utils.toInt(map["bank_account_balance"]);
    last_gold_collect_at = Utils.toInt(map["last_gold_collect_at"]);
    tutorial_id = Utils.toInt(map["tutorial_id"]);
    tutorial_index = Utils.toInt(map["tutorial_index"]);
    avatar_slots = Utils.toInt(map["avatar_slots"]);
    gold_collection_allowed_at = Utils.toInt(map["gold_collection_allowed_at"]);
    gold_collection_extraction = Utils.toInt(map["gold_collection_extraction"]);
    cards_view = Utils.toInt(map["cards_view"]);
    league_remaining_time = Utils.toInt(map["league_remaining_time"]);
    bonus_remaining_time = Utils.toInt(map["bonus_remaining_time"]);
    potionPrice = Utils.toInt(map["potion_price"]);
    nectarPrice = Utils.toInt(map["nectar_price"]);
    hero_id = Utils.toInt(map["hero_id"]);
    hero_max_rarity = Utils.toInt(map["hero_max_rarity"]);
    base_hero_id = Utils.toInt(map["base_hero_id"]);
    wheel_of_fortune_opens_in = Utils.toInt(map["wheel_of_fortune_opens_in"]);
    latest_constants_version = Utils.toInt(map["latest_constants_version"]);
    deltaTime = Utils.toInt(map["delta_time"]);
    xpboostCreatedAt = Utils.toInt(map["xpboost_created_at"]);
    pwboostCreatedAt = Utils.toInt(map["pwboost_created_at"]);
    xpboostId = Utils.toInt(map["xpboost_id"]);
    pwboostId = Utils.toInt(map["pwboost_id"]);

// Booleans
    needs_captcha = map["needs_captcha"];
    has_email = map["has_email"];
    gold_collection_allowed = map["gold_collection_allowed"];
    is_existing_player = map["is_existing_player"];
    is_name_temp = map["is_name_temp"];
    better_vitrin_promotion = map["better_vitrin_promotion"];
    can_use_vitrin = map["can_use_vitrin"];
    can_watch_advertisment = map["can_watch_advertisment"];
    purchase_deposits_to_bank = map["purchase_deposits_to_bank"];
    better_choose_deck = map["better_choose_deck"];
    better_quest_map = map["better_quest_map"];
    better_battle_outcome_navigation = map["better_battle_outcome_navigation"];
    better_tutorial_background = map["better_tutorial_background"];
    better_tutorial_steps = map["better_tutorial_steps"];
    more_xp = map["more_xp"];
    better_gold_pack_multiplier = map["better_gold_pack_multiplier"];
    better_gold_pack_ratio = map["better_gold_pack_ratio"];
    better_gold_pack_ratio_on_price = map["better_gold_pack_ratio_on_price"];
    better_league_tutorial = map["better_league_tutorial"];
    better_enhance_tutorial = map["better_enhance_tutorial"];
    better_mine_building_status = map["better_mine_building_status"];
    is_mine_building_limited = map["is_mine_building_limited"];
    retouched_tutorial = map["retouched_tutorial"];
    better_card_graphic = map["better_card_graphic"];
    durable_buildings_name = map["durable_buildings_name"];
    show_task_until_levelup = map["show_task_until_levelup"];
    better_restore_button_label = map["better_restore_button_label"];
    better_quest_tutorial = map["better_quest_tutorial"];
    available_combo_id_set = map["available_combo_id_set"];
    hero_tutorial_at_first = map["hero_tutorial_at_first"];
    hero_tutorial_at_first_and_selected =
        map["hero_tutorial_at_first_and_selected"];
    hero_tutorial_at_first_and_selected_and_animated =
        map["hero_tutorial_at_first_and_selected_and_animated"];
    hero_tutorial_at_level_four = map["hero_tutorial_at_level_four"];
    hero_tutorial_at_second_quest = map["hero_tutorial_at_second_quest"];
    fall_background = map["fall_background"];
    unified_gold_icon = map["unified_gold_icon"];
    send_all_tutorial_steps = map["send_all_tutorial_steps"];
    rolling_gold = map["rolling_gold"];
    coach_test = map["coach_test"];
    mobile_number_verified = map["mobile_number_verified"];
    wheel_of_fortune = map["wheel_of_fortune"];

// Strings
    name = map["name"];
    restoreKey = map["restore_key"];
    inviteKey = map["invite_key"];
    emergency_message = map["emergency_message"];
    update_message = map["update_message"];
    latest_app_version = map["latest_app_version"];
    latest_app_version_for_notice = map["latest_app_version_for_notice"];

    for (var card in map['cards']) {
      cards[card['id']] = AccountCard(this, card);
    }

    collection = List.castFrom(map["collection"]);
    _addDeadline(map, xpboostCreatedAt, xpboostId);
    _addDeadline(map, pwboostCreatedAt, pwboostId);

    buildings = {};
    _addBuilding(Buildings.auction, 1, map['auction_building_assigned_cards']);
    _addBuilding(Buildings.base);
    _addBuilding(Buildings.cards);
    _addBuilding(Buildings.defense, 0, map['defense_building_assigned_cards']);
    _addBuilding(Buildings.offense, 0, map['offense_building_assigned_cards']);
    buildings[Buildings.mine] = Mine();
    _addBuilding(Buildings.mine, map['gold_building_level'],
        map['gold_building_assigned_cards']);
    _addBuilding(Buildings.treasury, map['bank_building_level']);

    // Tribe
    installTribe(map['tribe']);

    // Heroes
    heroitems = {};
    for (var item in map["heroitems"]) {
      var heroitem = HeroItem(item['id'],
          loadingData.baseHeroItems[item['base_heroitem_id']]!, item['state']);
      heroitem.position = item['position'];
      heroitems[item['id']] = heroitem;
    }

    heroes = {};
    if (map['hero_id_set'] != null) {
      for (var h in map['hero_id_set']) {
        var hero = HeroCard(cards[h['id']]!, h['potion']);
        hero.items = <HeroItem>[];
        for (var item in h['items']) {
          var heroItem = heroitems[item["id"]! as int];
          if (heroItem != null) {
            hero.items.add(heroItem);
          }
        }
        heroes[h['id']] = hero;
      }
    }

    for (var id in map["available_combo_id_set"]) {
      loadingData.comboHints[id].isAvailable = true;
    }
  }

/*  Returns total power of the given cards array, taking into account any offensive tribe bonuses that the player might have 
 @param player Player whose cards you are evaluating
 @param cards An array of cards
 */
  int calculatePower(List<AccountCard?> cards) {
    var totalPower = 0.0;
    for (var card in cards) {
      totalPower += card != null ? card.power : 0;
    }
    var offense = buildings[Buildings.offense]!;
    totalPower *= offense.getBenefit();
    totalPower += offense.getCardsBenefit(this);
    return totalPower.floor();
  }

  int calculateMaxPower() {
    var cards = getReadyCards(removeCooldowns: true);
    var index = 0;
    var totalPower = 0.0;
    for (var card in cards) {
      if (index > 3) break;
      totalPower += card.power;
      index++;
    }
    var offense = buildings[Buildings.offense]!;
    totalPower *= offense.getBenefit();
    totalPower += offense.getCardsBenefit(this);
    return totalPower.floor();
  }

  int calculateMaxCooldown() {
    var cooldown = 0;
    var origin = cards.values.toList();
    for (var card in origin) {
      var c = card.getRemainingCooldown();
      if (c > cooldown) cooldown = c;
    }
    return cooldown;
  }

  List<AccountCard> getReadyCards({
    List<Buildings>? exceptions,
    bool removeCooldowns = false,
    bool removeMaxLevels = false,
    bool removeHeroes = false,
    bool isClone = false,
  }) {
    getCard(AccountCard card) => isClone ? card.clone() : card;
    exceptions = exceptions ??
        [
          Buildings.defense,
          Buildings.mine,
          Buildings.auction,
          Buildings.offense,
          Buildings.cards,
          Buildings.base
        ];
    var origin = cards.values.toList();
    var myCards = <AccountCard>[];
    inBuilding(AccountCard card, List<Buildings> exceptions) {
      for (var exception in exceptions) {
        if (buildings[exception]!.cards.contains(card)) return true;
      }
      return false;
    }

    for (var card in origin) {
      if (removeHeroes && card.base.isHero) continue;
      if (removeMaxLevels && !card.isUpgradable) continue;
      if (removeCooldowns && card.getRemainingCooldown() > 0) continue;
      if (inBuilding(card, exceptions)) continue;
      myCards.add(getCard(card));
    }
    myCards.sort((AccountCard a, AccountCard b) =>
        a.power * (b.base.isHero ? 1 : -1) -
        b.power * (a.base.isHero ? 1 : -1));
    return myCards;
  }

  void _addBuilding(Buildings type, [int level = 0, List? cards]) {
    cards = cards ?? [];
    if (!buildings.containsKey(type)) {
      buildings[type] = Building();
    }
    buildings[type]!.initialize({"type": type, "level": level},
        args: {"account": this, "cards": cards});
  }

  void installTribe(dynamic data) {
    if (data == null) return;
    tribe = Tribe(data);
    var types = [
      Buildings.base,
      Buildings.cards,
      Buildings.defense,
      Buildings.offense
    ];
    for (var type in types) {
      buildings[type]?.map['level'] = tribe!.levels[type.id];
    }
  }

  Map<String, dynamic> update(Map<String, dynamic> data) {
    if (data.containsKey("gold")) {
      gold += Utils.toInt(data["gold"]);
    } else {
      if (data.containsKey("player_gold")) {
        gold = Utils.toInt(data["player_gold"]);
      }
      gold += Utils.toInt(data["added_gold"]);
    }

    if (data.containsKey("nectar")) {
      nectar = Utils.toInt(data["nectar"]);
    } else {
      nectar += Utils.toInt(data["added_nectar"]);
    }

    if (data.containsKey("potion_number")) {
      potion = Utils.toInt(data["potion_number"]);
    } else {
      if (data.containsKey("player_potion")) {
        potion = Utils.toInt(data["player_potion"]);
      }
      if (data.containsKey("potion")) {
        potion = Utils.toInt(data["potion"]);
      }
      potion += Utils.toInt(data["added_potion"]);
    }
    // for (var field in AccountField.values) {
    //   if (data.containsKey(field.name)) {
    //     map[field.name] = data[field.name];
    //   }
    // }
    if (data.containsKey("attack_cards")) {
      for (var attackCard in data["attack_cards"]) {
        cards[attackCard['id']]?.lastUsedAt = attackCard["last_used_at"];
      }
    }
    if (data.containsKey("tribe_gold")) {
      tribe?.gold = Utils.toInt(data["tribe_gold"]);
    }

    if (data.containsKey("hero_potion")) {
      if (heroes.containsKey(data["hero_id"])) {
        heroes[data["hero_id"]]!.potion = data["hero_potion"];
      }
    }

    var achieveCards = <AccountCard>[];
    if (data.containsKey("achieveCards")) {
      for (var card in data["achieveCards"]) {
        var accountCard = AccountCard(this, card);
        cards[card['id']] = accountCard;
        achieveCards.add(accountCard);
      }
    }
    data["achieveCards"] = achieveCards;

    if (data.containsKey("card")) {
      var newCard = data["card"];
      var card = cards[newCard["id"]];
      if (card == null) {
        cards[newCard["id"]] = card = AccountCard(this, newCard);
      } else {
        card.power = newCard["power"];
        card.lastUsedAt = newCard["last_used_at"];
        card.base = loadingData.baseCards[newCard['base_card_id']]!;
      }
      data["card"] = card;
    }

    _addDeadline(data, xpboostCreatedAt, xpboostId);
    _addDeadline(data, pwboostCreatedAt, pwboostId);
    return data;
  }

  void _addDeadline(Map<String, dynamic> data, int startAt, int id) {
    if (startAt <= 0) return;
    var deadline = startAt + ShopData.boostDeadline;
    if (deadline <= now) return;

    var boost = loadingData.shopItems[ShopSections.boost]!
        .firstWhere((item) => item.id == id);
    deadlines.add(Deadline(deadline, boost));

    if (id == pwboostId) {
      for (var card in cards.entries) {
        card.value.power = (card.value.power * boost.ratio).round();
      }
    }
  }

  int getValue(Values type) => switch (type) {
        Values.gold => gold,
        Values.leagueRank => leagueRank,
        Values.nectar => nectar,
        Values.potion => potion,
        Values.rank => rank,
        _ => 0,
      };
}

class Deadline {
  final int time;
  final ShopItem boost;
  Deadline(this.time, this.boost);
}
