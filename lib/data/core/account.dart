// ignore_for_file: constant_identifier_names

import 'building.dart';
import 'card.dart';
import 'infra.dart';

enum AccountField {
  id,
  name,
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
  hero_id,
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
  heroitems,
  base_hero_id,
  hero_id_set,
  hero_max_rarity,
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
  update_message
}

class Account extends StringMap<dynamic> {
  @override
  void init(Map<String, dynamic> data, {dynamic args}) {
    var baseCards = args as Cards;
    super.init(data);
    var accountCards = <int, AccountCard>{};
    for (var card in map['cards']) {
      accountCards[card['id']] = AccountCard(card, baseCards);
    }
    map['cards'] = accountCards;

    map['buildings'] = <BuildingType, Building>{};

    if (map.containsKey('tribe')) {
      map['tribe'] = Tribe()..init(map['tribe']);
    }
  }

  T get<T>(AccountField fieldName) => map[fieldName.name] as T;
/*  Returns total power of the given cards array, taking into account any offensive tribe bonuses that the player might have 
 @param player Player whose cards you are evaluating
 @param cards An array of cards
 */
  int calculatePower(List<AccountCard?> cards) {
    var totalPower = 0;
    for (var card in cards) {
      totalPower += card != null ? card.power : 0;
    }

    var tribe = get<Tribe?>(AccountField.tribe);
    if (tribe != null) {
      // if tribe ~= nil and player.tribe.buildings.offense ~= nil then
      //     totalPower = totalPower * player.tribe.buildings.offense:benefitFromLevel();
      //     totalPower = totalPower + player.tribe.buildings.offense:benefitFromAssignedCards();
      // }
    }
    return totalPower.floor();
  }
}