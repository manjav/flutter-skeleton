// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:math' as math;

import '../../data/core/rpc_data.dart';
import '../../utils/utils.dart';
import 'building.dart';
import 'card.dart';
import 'infra.dart';
import 'ranking.dart';
import 'tribe.dart';

enum AccountField {
  id,
  name,
  buildings,
  rank,
  league_rank,
  xp,
  weekly_score,
  level,
  def_power,
  league_id,
  gold,
  tribe_permission,
  gold_building_level,
  bank_building_level,
  new_messages,
  restore_key,
  invite_key,
  needs_captcha,
  cooldowns_bought_today,
  total_quests,
  total_battles,
  q,
  bank_account_balance,
  last_gold_collect_at,
  tutorial_id,
  tutorial_index,
  potion_number,
  nectar,
  birth_year,
  gender,
  phone,
  address,
  realname,
  prev_league_id,
  prev_league_rank,
  won_battle_num,
  lost_battle_num,
  mood_id,
  avatar_id,
  updated_at,
  last_load_at,
  medals,
  avatar_slots,
  avatars,
  owned_avatars,
  activity_status,
  has_email,
  cards,
  gold_building_assigned_cards,
  offense_building_assigned_cards,
  defense_building_assigned_cards,
  auction_building_assigned_cards,
  gold_collection_allowed,
  gold_collection_allowed_at,
  gold_collection_extraction,
  collection,
  cards_view,
  tribe,
  achievements,
  achievements_blob,
  now,
  league_remaining_time,
  bonus_remaining_time,
  is_existing_player,
  is_name_temp,
  sale_info,
  available_combo_id_set,
  potion_price,
  nectar_price,
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
  heroes,
  heroitems,
  base_heroitems,
  hero_id,
  hero_id_set,
  hero_max_rarity,
  base_hero_id,
  hero_tutorial_at_first,
  hero_tutorial_at_first_and_selected,
  hero_tutorial_at_first_and_selected_and_animated,
  hero_tutorial_at_level_four,
  hero_tutorial_at_second_quest,
  fall_background,
  unified_gold_icon,
  send_all_tutorial_steps,
  rolling_gold,
  bundles,
  daily_reward,
  coach_info,
  coaching,
  coach_test,
  mobile_number_verified,
  wheel_of_fortune_opens_in,
  wheel_of_fortune,
  latest_app_version,
  latest_app_version_for_notice,
  latest_constants_version,
  modules_version,
  emergency_message,
  update_message,
  delta_time,
  xpboost_created_at,
  pwboost_created_at,
  xpboost_id,
  pwboost_id,
  deadlines,
}

class Account extends StringMap<dynamic> {
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
  static const levelMultiplier = 1.3;
  static const levelExpo = 2.7;
  late LoadingData loadingData;
  static int getXpRequiered(int level) =>
      (math.pow(level, levelExpo) * levelMultiplier).ceil();

  Building? getBuilding(Buildings type) => map['buildings'][type] as Building;
  Map<int, AccountCard> getCards() => map['cards'];
  int get now => DateTime.now().secondsSinceEpoch + map['delta_time'] as int;

  @override
  void init(Map<String, dynamic> data, {dynamic args}) {
    loadingData = args as LoadingData;
    super.init(data);
    map['delta_time'] = map['now'] - DateTime.now().secondsSinceEpoch;

    var accountCards = <int, AccountCard>{};
    for (var card in map['cards']) {
      accountCards[card['id']] = AccountCard(this, card);
    }
    map['cards'] = accountCards;

    // Organize deadlines
    _parse(AccountField.xpboost_id);
    _parse(AccountField.pwboost_id);
    _parse(AccountField.xpboost_created_at);
    _parse(AccountField.pwboost_created_at);
    _addDeadline(map, AccountField.xpboost_created_at, AccountField.xpboost_id);
    _addDeadline(map, AccountField.pwboost_created_at, AccountField.pwboost_id);

    map['buildings'] = <Buildings, Building>{};
    _addBuilding(Buildings.auction, 1, map['auction_building_assigned_cards']);
    _addBuilding(Buildings.base);
    _addBuilding(Buildings.cards);
    _addBuilding(Buildings.defense, 0, map['defense_building_assigned_cards']);
    _addBuilding(Buildings.offense, 0, map['offense_building_assigned_cards']);
    map['buildings'][Buildings.mine] = Mine();
    _addBuilding(Buildings.mine, map['gold_building_level'],
        map['gold_building_assigned_cards']);
    _addBuilding(Buildings.treasury, map['bank_building_level']);

    // Tribe
    installTribe(map['tribe']);

    // Heroes
    map['base_heroitems'] = loadingData.baseHeroItems;

    var heroitems = <int, HeroItem>{};
    for (var item in map["heroitems"]) {
      var heroitem = HeroItem(item['id'],
          loadingData.baseHeroItems[item['base_heroitem_id']]!, item['state']);
      heroitem.position = item['position'];
      heroitems[item['id']] = heroitem;
    }
    map["heroitems"] = heroitems;

    var heroes = <int, HeroCard>{};
    if (map['hero_id_set'] != null) {
      for (var h in map['hero_id_set']) {
        var hero = HeroCard(accountCards[h['id']]!, h['potion']);
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
    map['heroes'] = heroes;

    for (var id in map["available_combo_id_set"]) {
      loadingData.comboHints[id].isAvailable = true;
    }
  }

  void _parse(AccountField key) {
    if (map.containsKey(key.name)) map[key.name] = int.parse(map[key.name]);
  }

  bool contains(AccountField field) => map.containsKey(field.name);
  T get<T>(AccountField field) => map[field.name] as T;

/*  Returns total power of the given cards array, taking into account any offensive tribe bonuses that the player might have 
 @param player Player whose cards you are evaluating
 @param cards An array of cards
 */
  int calculatePower(List<AccountCard?> cards) {
    var totalPower = 0.0;
    for (var card in cards) {
      totalPower += card != null ? card.power : 0;
    }
    Building offense = map['buildings'][Buildings.offense];
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
    var offense = getBuilding(Buildings.offense)!;
    totalPower *= offense.getBenefit();
    totalPower += offense.getCardsBenefit(this);
    return totalPower.floor();
  }

  int calculateMaxCooldown() {
    var cooldown = 0;
    var origin = getCards().values.toList();
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
    var origin = getCards().values.toList();
    var cards = <AccountCard>[];
    inBuilding(AccountCard card, List<Buildings> exceptions) {
      for (var exception in exceptions) {
        if (getBuilding(exception)!.cards.contains(card)) return true;
      }
      return false;
    }

    for (var card in origin) {
      if (removeHeroes && card.base.isHero) continue;
      if (removeMaxLevels && !card.isUpgradable) continue;
      if (removeCooldowns && card.getRemainingCooldown() > 0) continue;
      if (inBuilding(card, exceptions)) continue;
      cards.add(getCard(card));
    }
    cards.sort((AccountCard a, AccountCard b) =>
        a.power * (b.base.isHero ? 1 : -1) -
        b.power * (a.base.isHero ? 1 : -1));
    return cards;
  }

  void _addBuilding(Buildings type, [int level = 0, List? cards]) {
    cards = cards ?? [];
    if (!map['buildings'].containsKey(type)) {
      map['buildings'][type] = Building();
    }
    map['buildings'][type].init({"type": type, "level": level},
        args: {"account": this, "cards": cards});
  }

  void installTribe(dynamic data) {
    if (data == null) return;
    var tribe = map['tribe'] = Tribe(data);
    var types = [
      Buildings.base,
      Buildings.cards,
      Buildings.defense,
      Buildings.offense
    ];
    for (var type in types) {
      getBuilding(type)?.map['level'] = tribe.levels[type.id];
    }
  }

  Map<String, dynamic> update(Map<String, dynamic> data) {
    if (data.containsKey("player_gold")) {
      data["gold"] = data["player_gold"];
    }
    if (data.containsKey("player_potion")) {
      data["potion_number"] = data["player_potion"];
    }
    if (data.containsKey("potion")) {
      data["potion_number"] = data["potion"];
    }
    for (var field in AccountField.values) {
      if (data.containsKey(field.name)) {
        map[field.name] = data[field.name];
      }
    }
    if (data.containsKey("attack_cards")) {
      for (var attackCard in data["attack_cards"]) {
        getCards()[attackCard['id']]?.lastUsedAt = attackCard["last_used_at"];
      }
    }
    var tribe = get<Tribe?>(AccountField.tribe);
    if (tribe != null && data.containsKey("tribe_gold")) {
      tribe.gold = data["tribe_gold"];
    }

    if (!data.containsKey("gold")) {
      map["gold"] = map["gold"] + (data["added_gold"] ?? 0);
    }

    if (!data.containsKey("nectar")) {
      map["nectar"] = map["nectar"] + (data["added_nectar"] ?? 0);
    }

    if (!data.containsKey("potion_number")) {
      map["potion_number"] = map["potion_number"] + (data["added_potion"] ?? 0);
    }

    if (data.containsKey("hero_potion")) {
      var heroes = get<Map<int, HeroCard>>(AccountField.heroes);
      if (heroes.containsKey(data["hero_id"])) {
        heroes[data["hero_id"]]!.potion = data["hero_potion"];
      }
    }

    var cards = <AccountCard>[];
    if (data.containsKey("achieveCards")) {
      for (var card in data["achieveCards"]) {
        var accountCard = AccountCard(this, card);
        getCards()[card['id']] = accountCard;
        cards.add(accountCard);
      }
    }
    data["achieveCards"] = cards;

    if (data.containsKey("card")) {
      var newCard = data["card"];
      var card = getCards()[newCard["id"]];
      if (card == null) {
        map['cards'][newCard["id"]] = card = AccountCard(this, newCard);
      } else {
        card.power = newCard["power"];
        card.lastUsedAt = newCard["last_used_at"];
        card.base = loadingData.baseCards.get("${newCard['base_card_id']}");
      }
      data["card"] = card;
    }

    _addDeadline(
        data, AccountField.xpboost_created_at, AccountField.xpboost_id);
    _addDeadline(
        data, AccountField.pwboost_created_at, AccountField.pwboost_id);
    return data;
  }

  void _addDeadline(
      Map<String, dynamic> data, AccountField startAt, AccountField id) {
    if (!data.containsKey(startAt.name)) return;
    var deadline = get<int>(startAt) + ShopData.boostDeadline;
    if (deadline <= now) return;

    List<Deadline> deadlines = map["deadlines"] ?? [];
    var boost = loadingData.shopItems[ShopSections.boost]!
        .firstWhere((item) => item.id == get<int>(id));
    deadlines.add(Deadline(deadline, boost));
    map["deadlines"] = deadlines;

    if (id == AccountField.pwboost_id) {
      var cards = getCards().entries;
      for (var card in cards) {
        card.value.power = (card.value.power * boost.ratio).round();
      }
    }
  }

  Opponent toOpponent() {
    return Opponent.init(map, map["id"]);
  }

  int getValue(Values type) => switch (type) {
        _ => 0,
      };
}

class Deadline {
  final int time;
  final ShopItem boost;
  Deadline(this.time, this.boost);
}
