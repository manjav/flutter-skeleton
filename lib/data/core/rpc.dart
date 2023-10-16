// ignore_for_file: constant_identifier_names

enum RpcId {
  none,

  playerLoad,
  deposit,
  witdraw,
  fillPotion,
  redeemGift,
  messages,

  // Card
  coolOff,
  assignCard,
  enhanceCard,
  enhanceMax,
  evolveCard,
  equipHeroitems,
  collectGold,
  potionize,

  // Battle
  getOpponents,
  scout,
  quest,
  battle,
  battleLive,
  battleHelp,
  battleSetCard,
  triggerAbility,
  joinBattle,

  // Ranking
  rankingGlobal,
  rankingExpertTribes,
  rankingTopTribes,
  league,
  leagueHistory,

  // Shop
  getShopitems,
  buyHeroItem,
  buyCardPack,

  //Tribe
  upgrade,
  tribeSearch,
  tribeCreate,
  tribeEdit,
  tribeMembers,
  tribeInvite,
  tribeVisibility,
  tribeDonate,
  tribeUpgrade,
  tribePoke,
  tribeJoin,
  tribeLeave,
  tribeKick,
  tribePromote,
  tribeDemote,
  tribePinMessage,
  tribeGetPinnedMessages,

  // Auction
  auctionSell,
  auctionSearch,
  auctionBid,
  auctionDeals,
  auctionSells,
}

extension RpcIdEx on RpcId {
  String get value {
    return switch (this) {
      RpcId.none => "",
      RpcId.coolOff => "cards/cooloff",
      RpcId.assignCard => "cards/assign",
      RpcId.enhanceCard => "cards/enhance",
      RpcId.enhanceMax => "cards/nectarify",
      RpcId.evolveCard => "cards/evolve",
      RpcId.equipHeroitems => "cards/equipheroitems",
      RpcId.collectGold => "cards/collectgold",
      RpcId.potionize => "cards/potionize",
      RpcId.scout => "battle/scout",
      RpcId.quest => "battle/quest",
      RpcId.battle => "battle/battle",
      RpcId.getOpponents => "battle/getopponents",
      RpcId.battleLive => "live-battle/livebattle",
      RpcId.battleHelp => "live-battle/help",
      RpcId.battleSetCard => "live-battle/setcardforlivebattle",
      RpcId.triggerAbility => "live-battle/triggerability",
      RpcId.joinBattle => "live-battle/livebattlejoin",
      RpcId.playerLoad => "player/load",
      RpcId.deposit => "player/deposittobank",
      RpcId.witdraw => "player/withdrawfrombank",
      RpcId.fillPotion => "player/fillpotion",
      RpcId.redeemGift => "player/redeemgift",
      RpcId.messages => "message/systemmessages",
      RpcId.rankingGlobal => "ranking/global",
      RpcId.rankingExpertTribes => "ranking/tribe",
      RpcId.rankingTopTribes => "ranking/tribebasedonseed",
      RpcId.league => "ranking/league",
      RpcId.leagueHistory => "ranking/leaguehistory",
      RpcId.getShopitems => "store/getshopitems",
      RpcId.buyHeroItem => "store/buyheroitem",
      RpcId.buyCardPack => "store/buycardpack",
      RpcId.tribeSearch => "tribe/find",
      RpcId.tribeCreate => "tribe/create",
      RpcId.upgrade => "tribe/upgrade",
      RpcId.tribeEdit => "tribe/edit",
      RpcId.tribeMembers => "tribe/members",
      RpcId.tribeInvite => "tribe/invite",
      RpcId.tribeVisibility => "tribe/invisible",
      RpcId.tribePinMessage => "tribe/broadcast",
      RpcId.tribeGetPinnedMessages => "message/tribebroadcast",
      RpcId.tribeDonate => "tribe/donate",
      RpcId.tribeUpgrade => "tribe/upgrade",
      RpcId.tribeJoin => "tribe/joinrequest",
      RpcId.tribeLeave => "tribe/leave",
      RpcId.tribeKick => "tribe/kick",
      RpcId.tribePromote => "tribe/promote",
      RpcId.tribeDemote => "tribe/demote",
      RpcId.tribePoke => "tribe/poke",
      RpcId.auctionSell => "auction/setcardforauction",
      RpcId.auctionSearch => "auction/search",
      RpcId.auctionBid => "auction/bid",
      RpcId.auctionDeals => "auction/loadmyparticipatedauctions",
      RpcId.auctionSells => "auction/loadmyauctions",
    };
  }

  bool get needsEncryption {
    return switch (this) {
      _ => true,
    };
  }

  HttpRequestType get requestType {
    return switch (this) {
      _ => HttpRequestType.post,
    };
  }
}

enum HttpRequestType { get, post }

enum RpcParams {
  // Player laod
  device_name,
  game_version,
  model,
  name,
  os_type,
  os_version,
  restore_key,
  store_type,
  udid,
  code,
  // Quest - Battle
  cards,
  hero_id,
  check,
  opponent_id,
  attacks_in_today,
  // Cards
  card_id,
  sacrifices,
  client,
  // Buildings
  type,
  tribe_id,
  amount,
  // League
  rounds,
  // Shop
  id,
  // Battle
  battle_id,
  card,
  round,
  ability_type,
  potion,
  query,
  status,
  description,
  gold,
  invitee_name,
  member_id,
}
