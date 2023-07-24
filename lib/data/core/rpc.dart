// ignore_for_file: constant_identifier_names

enum RpcId {
  playerLoad,
//Card
  assignCard,
  enhanceCard,
  enhanceMax,
// Battle
  getOpponents,
  scout,
  quest,
  battle,

  // Building
  upgrade,
}

extension RpcIdEx on RpcId {
  String get value {
    return switch (this) {
      RpcId.assignCard => "cards/assign",
      RpcId.enhanceCard => "cards/enhance",
      RpcId.enhanceMax => "cards/nectarify",
      RpcId.scout => "battle/scout",
      RpcId.quest => "battle/quest",
      RpcId.battle => "battle/battle",
      RpcId.getOpponents => "battle/getopponents",
      RpcId.playerLoad => "player/load",
      RpcId.upgrade => "tribe/upgrade"
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
  // Quest - Battle
  cards,
  hero_id,
  check,
  opponent_id,
  attacks_in_today,
  // Cards
  card_id,
  sacrifices,
  // Buildings
  type,
  tribe_id
}
