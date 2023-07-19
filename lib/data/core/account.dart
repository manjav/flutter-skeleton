// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:math' as math;

import '../../services/prefs.dart';
import '../../utils/utils.dart';
import 'building.dart';
import 'card.dart';
import 'infra.dart';

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
  delta_time
}

class Account extends StringMap<dynamic> {
  static const levelMultiplier = 1.3;
  static const levelExpo = 2.7;
  static int getXpRequiered(int level) =>
      (math.pow(level, levelExpo) * levelMultiplier).ceil();

  Building? getBuilding(Buildings type) => map['buildings'][type] as Building;
  Map<int, AccountCard> getCards() => map['cards'];

  @override
  void init(Map<String, dynamic> data, {dynamic args}) {
    var baseCards = args as Cards;
    super.init(data);
    map['delta_time'] = map['now'] - DateTime.now().secondsSinceEpoch;

    var accountCards = <int, AccountCard>{};
    for (var card in map['cards']) {
      accountCards[card['id']] = AccountCard(this, card, baseCards);
    }
    map['cards'] = accountCards;

    map['buildings'] = <Buildings, Building>{};
    _addBuilding(Buildings.auction, 1, map['auction_building_assigned_cards']);
    _addBuilding(Buildings.base, map['tribe']?['mainhall_building_level']);
    _addBuilding(Buildings.cards, map['tribe']?['cooldown_building_level']);
    _addBuilding(Buildings.defense, map['tribe']?['defense_building_level'],
        map['defense_building_assigned_cards']);
    _addBuilding(Buildings.message);
    _addBuilding(Buildings.mine, map['gold_building_level'],
        map['gold_building_assigned_cards']);
    _addBuilding(Buildings.offense, map['tribe']?['offense_building_level'],
        map['offense_building_assigned_cards']);
    _addBuilding(Buildings.shop);
    _addBuilding(Buildings.treasury, map['bank_building_level']);
    _addBuilding(Buildings.quest);
    _addBuilding(Buildings.tribe, 1);
    if (map['tribe'] != null) {
      map['buildings'][Buildings.tribe].init(map['tribe']);
    }

    // Heroes
    var baseHeroitems = <int, BaseHeroItem>{};
    baseHeroitems[1] = BaseHeroItem(1, 2, 6, 1, 80, 3, 1, "Xameen");
    baseHeroitems[2] = BaseHeroItem(2, 5, 2, 1, 70, 1, 1, "Paleez");
    baseHeroitems[3] = BaseHeroItem(3, 2, 1, 6, 80, 1, 1, "RoboLeaf");
    baseHeroitems[4] = BaseHeroItem(4, 2, 3, 1, 60, 1, 2, "BloodyKnife");
    baseHeroitems[5] = BaseHeroItem(5, 1, 4, 1, 60, 20, 2, "CursedGun");
    baseHeroitems[6] = BaseHeroItem(6, 1, 3, 5, 90, 20, 1, "Thorny");
    baseHeroitems[7] = BaseHeroItem(7, 1, 1, 4, 60, 5, 2, "HairDryer");
    baseHeroitems[8] = BaseHeroItem(8, 3, 1, 1, 50, 1, 2, "RainbowGun");
    baseHeroitems[9] = BaseHeroItem(9, 5, 1, 1, 70, 50, 2, "AdmiralSword");
    map['base_heroitems'] = baseHeroitems;

    var heroes = <int, HeroCard>{};
    if (map['hero_id_set'] != null) {
      for (var v in map['hero_id_set']) {
        var items = <HeroItem>[];
        for (var item in v['items']) {
          items.add(HeroItem(
              item['id'],
              baseHeroitems[item['base_heroitem_id']]!,
              item['state'],
              item['position']));
        }
        heroes[v['id']] = HeroCard(accountCards[v['id']]!, v['potion'], items);
      }
    }
    map['heroes'] = heroes;
  }

  T get<T>(AccountField fieldName) => map[fieldName.name] as T;

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

  List<AccountCard> getReadyCards() {
    List<AccountCard> cards = map['cards'].values.toList();
    cards.removeWhere((card) {
      return (getBuilding(Buildings.defense)!
              .assignedCardsId
              .contains(card.id) ||
          getBuilding(Buildings.mine)!.assignedCardsId.contains(card.id) ||
          getBuilding(Buildings.auction)!.assignedCardsId.contains(card.id) ||
          getBuilding(Buildings.offense)!.assignedCardsId.contains(card.id));
    });
    cards.sort((AccountCard a, AccountCard b) => b.power - a.power);
    return cards;
  }

  void _addBuilding(Buildings type, [int? level, List? cards]) {
    level = level ?? 0;
    cards = cards ?? [];
    map['buildings'][type] = Building()
      ..init({
        "type": type,
        "level": level,
        "cards": List<int>.generate(cards.length, (i) => cards![i]['id'])
      });
  }

  void update(Map<String, dynamic> data) {
    for (var field in AccountField.values) {
      if (data[field.name] != null) {
        map[field.name] = data[field.name];
      }
    }
    if (data.containsKey("attack_cards")) {
      for (var attackCard in data["attack_cards"]) {
        getCards()[attackCard['id']]?.lastUsedAt = attackCard["last_used_at"];
      }
    }
  }
}

class Opponent {
  static int scoutCost = 0;
  static Map<String, dynamic> _attackLogs = {};
  int id = 0,
      rank = 0,
      index = 0,
      xp = 0,
      gold = 0,
      tribePermission = 0,
      level = 0,
      defPower = 0,
      status = 0,
      leagueId = 0,
      leagueRank = 0,
      avatarId = 0,
      powerRatio = 0;
  String name = "", tribeName = "";
  bool isRevealed = false;
  int todayAttacksCount = 0;

  Opponent(Map<String, dynamic>? map) {
    if (map == null) return;
    id = map["id"] ?? 0;
    xp = map["xp"] ?? 0;
    name = map["name"] ?? "";
    rank = map["rank"] ?? 0;
    gold = map["gold"] ?? 0;
    level = map["level"] ?? 0;
    status = map["status"] ?? 0;
    defPower = map["def_power"] ?? 0;
    leagueId = map["league_id"] ?? 0;
    avatarId = map["avatar_id"] ?? 0;
    tribeName = map["tribe_name"] ?? "";
    leagueRank = map["league_rank"] ?? 0;
    powerRatio = map["power_ratio"] ?? 0;
    tribePermission = map["tribe_permission"] ?? 0;
  }

  static List<Opponent> fromMap(Map<String, dynamic> map) {
    scoutCost = map["scout_cost"];
    _attackLogs = Opponent._getAttacksLog();
    var list = <Opponent>[];
    var index = 0;
    for (var player in map["players"]) {
      var opponent = Opponent(player);
      opponent.index = index++;
      opponent.todayAttacksCount = (_attackLogs["${opponent.id}"] ?? 0);
      list.add(opponent);
    }
    return list;
  }

  static Map<String, dynamic> _getAttacksLog() {
    var attacks = jsonDecode(Pref.attacks.getString(defaultValue: '{}'));
    var days = DateTime.now().daysSinceEpoch;
    if (attacks["days"] != days) {
      attacks = {"days": days};
    }
    return attacks;
  }

  void increaseAttacksCount() {
    todayAttacksCount++;
    _attackLogs["$id"] = todayAttacksCount;
    Pref.attacks.setString(jsonEncode(_attackLogs));
  }

  int getGoldLevel(int accountLevel) {
    var goldRate = gold / todayAttacksCount;
    if (goldRate < 100 * accountLevel) return 1;
    if (goldRate < 500 * accountLevel) return 2;
    if (goldRate < 1000 * accountLevel) return 3;
    return 4;
  }
}
