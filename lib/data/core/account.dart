// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:math' as math;

import '../../data/core/rpc_data.dart';
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
  late LoadingData loadingData;
  static int getXpRequiered(int level) =>
      (math.pow(level, levelExpo) * levelMultiplier).ceil();

  Building? getBuilding(Buildings type) => map['buildings'][type] as Building;
  Map<int, AccountCard> getCards() => map['cards'];

  @override
  void init(Map<String, dynamic> data, {dynamic args}) {
    loadingData = args as LoadingData;
    super.init(data);
    map['delta_time'] = map['now'] - DateTime.now().secondsSinceEpoch;

    var accountCards = <int, AccountCard>{};
    for (var card in map['cards']) {
      accountCards[card['id']] = AccountCard(this, card, loadingData.baseCards);
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
      map['buildings'][Buildings.tribe]
          .init(map['tribe'], args: {'account': this, 'cards': []});
    }

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

  List<AccountCard> getReadyCards(
      {List<Buildings>? exceptions, bool removeCooldowns = false}) {
    exceptions = exceptions ??
        [
          Buildings.defense,
          Buildings.mine,
          Buildings.auction,
          Buildings.offense,
          Buildings.cards,
          Buildings.base
        ];
    var cards = getCards().values.toList();
    cards.removeWhere((card) {
      for (var exception in exceptions!) {
        if (getBuilding(exception)!.cards.contains(card)) return true;
      }
      return (removeCooldowns && card.getRemainingCooldown() > 0);
    });
    cards.sort((AccountCard a, AccountCard b) =>
        a.power * (b.base.isHero ? 1 : -1) - b.power * (a.base.isHero ? 1 : -1));
    return cards;
  }

  void _addBuilding(Buildings type, [int? level, List? cards]) {
    level = level ?? 0;
    cards = cards ?? [];
    map['buildings'][type] = Building()
      ..init({"type": type, "level": level},
          args: {"account": this, "cards": cards});
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
    if (data.containsKey("player_gold")) map["gold"] = data["player_gold"];
    var tribe = getBuilding(Buildings.tribe);
    if (tribe != null) tribe.map["gold"] = data["tribe_gold"];

    map["gold"] = map["gold"] + (data["added_gold"] ?? 0);
    map["nectar"] = map["nectar"] + (data["added_nectar"] ?? 0);
    map["potion_number"] = map["potion_number"] + (data["added_potion"] ?? 0);
    map["potion_number"] = data["potion"] ?? 0;
  }
}
