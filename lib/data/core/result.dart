// ignore_for_file: constant_identifier_names

enum StatusCode {
  C0_SUCCESS,
  C100_UNEXPECTED_ERROR,
  C101_PERMISSION_DENIED,
  C102_CARD_NOT_FOUND,
  C103_INCONSISTENCY_ERROR_CARD,
  C104_CARD_ALREADY_IN_AUCTION,
  C105_NOT_ENOUGH_CARDS,
  C106_INCONSISTENCY_ERROR_ACTION,
  C107_AUCTION_NOT_FOUND,
  C108_BID_MAX_PRICE,
  C109_BID_OWN_CARDS,
  C110_ALREADY_HIGHEST_BIDDER,
  C111_AUCTION_CLOSED,
  C112_AUCTION_QUERY_ONT_SELECTED,
  C113_CARD_TYPE_NOT_FOUND,
  C114_OUT_OF_RANGE,
  C115_PERMISSION_DENIED,
  C116_ACCESS_DENIED,
  C117_UNDER_MAINTENANCE,
  C118_CARD_SELECTION,
  C119_INCONSISTENT_OPPONENT,
  C120_ATTACK_NUMBER_REQUIRED,
  C121_SELF_ATTACK,
  C122_SHIELD_PROTECTED,
  C123_NEED_CAPTCHA,
  C124_MULTIPLE_DEVICE,
  C125_OPPONENT_NOT_FOUND,
  C126_OPPONENT_OUT_OF_RANGE,
  C127_OPPONENT_DEFENCE_DECK_EMPTY,
  C128_INVALID_CAPTCHA,
  C129_CARD_BUSY_IN_BUILDING,
  C130_CARD_SACRIFICE,
  C131_CARD_MAX_POWER,
  C132_EVOLVE_MAX,
  C133_EVOLVE_TYPE,
  C134_UPDATE_BUILDING,
  C135_BUILDING_MAX_CARD,
  C136_LIVE_BATTLE_UNAVAILABLE,
  C137_OPPONENT_OFFLINE,
  C138_OPPONENT_BUSY_BATTLE,
  C139_OPPONENT_BUSY,
  C140_RIBEMATE_ATTACK,
  C141_BATTLE_ID_NOT_FOUND,
  C142_UPDATE_INCONSISTANCY,
  C143_TIMED_OUT,
  C144_PLAYER_UNAVAILABLE,
  C145_BATTLE_NOT_FOUND,
  C146_ATTACKER_NOT_FOUND,
  C147_DEFENDER_NOT_FOUND,
  C148_TRIBE_NOT_FOUND,
  C149_TRIBE_JOIN_REQUIRED,
  C150_TRIBE_LIMITATION_RULE,
  C151_MESSAGE_SIZE_EXCEEDED,
  C152_MESSAGE_NOT_FOUND,
  C153_INVALID_INVITATION_TICKET,
  C154_INVALID_RESTORE_KEY,
  C155_CHANGE_ACCOUNT_ERROR,
  C156_RESTORE_DATA_REQUIRED,
  C157_PLAYER_NOT_FOUND,
  C158_REDEEMED_INVITATION_CODE,
  C159_INVALID_EMAIL,
  C160_EXISTS_EMAIL,
  C161_EMAIL_ALREADY_REGISTERED,
  C162_REWARD_ALREADY_RECEIVED,
  C163_ACCOUNT_DEACTIVATED,
  C164_ACCOUNT_RESET_FAILED,
  C165_INVALID_ACTIVATION_CODE,
  C166_CASH_REWARD_NOT_FOUND,
  C167_AVATAR_UNAVAILABLE,
  C168_LEAGUE_JOIN_NEED,
  C169_DEVICE_VRIFICATION_ERROR,
  C170_STORE_NOT_SUPPORTED,
  C171_SELECTED_PACK_INCONSISTANT,
  C172_RECEIPT_NOT_PROVIDED,
  C173_MAX_EVOLVE,
  C174_INTERNAL_ERROR_OCCURED,
  C175_INTERNAL_ERROR_OCCURED,
  C176_PLAYER_OUT_OF_BATTLE,
  C177_COOLDOWN,
  C178_COOL_ENOUGH,
  C179_DEVICE_INCONSISTANT,
  C180_NAME_TOO_LONG,
  C181_NAME_ALREADY_TAKEN,
  C182_COUNTRY_CODE_NOT_SUPPORTED,
  C183_MORE_GOLD,
  C184_MULTIPLE_ONLINE_DEVICE,
  C185_TRIBE_NAME_MAX_CHARS,
  C186_TOP_TRIBES_UNEDITABLE,
  C187_NO_SELL_CRYSTAL_CARDS,
  C188_STATUS_REQUIRED,
  C189_TRIBE_NOT_FOUND,
  C190_NAME_REQUIRED,
  C191_DESCRIPTION_REQUIRED,
  C192_DESCRIPTION_TOO_LANG,
  C193_TRIBE_NAME_ALREADY_EXISTS,
  C194_INVALID_CHIEF_COUNT,
  C195_ALREADY_JOINED_TRIBE,
  C196_TRIBE_BUILDING_REQUIRED,
  C197_MAX_TRIBE_LIMIT_CHANGE,
  C198_NO_MEMBERS_TRIBE,
  C199_UNDECIDED_REQUEST,
  C200_INVALID_DECISION_PARAMETER,
  C201_IVALID_JOIN_REQUEST,
  C202_INCONSISTENT_DATA_PROVIDED,
  C203_JOIN_REQUEST_ALREADY_PROCESSED,
  C204_TRIBE_FULL,
  C205_TRIBE_ACCESS_PERMISSION_DENIED,
  C206_ALREADY_A_MEMBER_TRIBE,
  C207_INVITATION_INVALID,
  C208_INVITATION_ALREADY_PROCESSED,
  C209_NO_TRIBES,
  C210_TRIBE_FOREIGN_PLAYER,
  C211_ABNORMAL_PERMISSION,
  C212_ELDER_NEED,
  C213_SELF_POKE,
  C214_TRIBE_ACCESS,
  C215_SELF_KICK,
  C216_PERMISSION_DENIED,
  C217_MAX_LEVEL_BUILING_COOLDOWN,
  C218_MAX_LEVEL_BUILING_MAINHALL,
  C219_MAX_LEVEL_BUILING_DEFENSE,
  C220_MAX_LEVEL_BUILING_OFFENSE,
  C221_MAX_LEVEL_BUILING_GOLD,
  C222_MAX_LEVEL_BUILING_BANK,
  C223_INVALID_BUILDING_TYPE_FO,
  C224_MINIMUM_DONATION,
  C225_TRIBE_BUILDING_NOT_FOUND,
  C226_UNDECIDED_INVITATION,
  C227_NOT_ENOUGH_TRIBE_MONEY,
  C228_FAILED_TO_UPDATE_TRIBE_SCORE,
  C229_TRIBE_HAS_NO_IDENTIFIER,
  C230_INVALID_BUILDING_TYPE_FOR_CARD_CAPACITY,
  C231_NO_QUERY_SUPPLIED,
  C232_GOOGLE_PLAY_VERIFICATION_FAILED,
  C233_PURCHASE_STATE_INVALID,
  C234_WRONG_SERVER_DATA,
  C235_SIBCHE_VERIFICATION_FAILED,
  C236_CANNOT_BUY_MORE_BOOSTS,
  C237_INVALID_COUNTRY_CODE,
  C238_USER_NOT_FOUND,
  C239_USER_POKED,
  C240_UPDATING_LEAGUE_IN_PROGRESS,
  C241_NOT_IMPLEMENTED,
  C242_INVALID_LEAGUE_ID,

  C250_UNKNOWN_ERROR,
  C301_MOVED_PERMANENTLY,

  C403_SERVICE_UNAVAILABLE,
  C503_SERVICE_UNAVAILABLE,
}

extension StatusCodeintEx on int {
  StatusCode toStatus() {
    for (var r in StatusCode.values) {
      if (this == r.value) return r;
    }
    return StatusCode.C250_UNKNOWN_ERROR;
  }
}

extension StatusCodeEx on StatusCode {
  int get value {
    return switch (this) {
      StatusCode.C0_SUCCESS => 0,
      StatusCode.C100_UNEXPECTED_ERROR => 100,
      StatusCode.C101_PERMISSION_DENIED => 101,
      StatusCode.C102_CARD_NOT_FOUND => 102,
      StatusCode.C103_INCONSISTENCY_ERROR_CARD => 103,
      StatusCode.C104_CARD_ALREADY_IN_AUCTION => 104,
      StatusCode.C105_NOT_ENOUGH_CARDS => 105,
      StatusCode.C106_INCONSISTENCY_ERROR_ACTION => 106,
      StatusCode.C107_AUCTION_NOT_FOUND => 107,
      StatusCode.C108_BID_MAX_PRICE => 108,
      StatusCode.C109_BID_OWN_CARDS => 109,
      StatusCode.C110_ALREADY_HIGHEST_BIDDER => 110,
      StatusCode.C111_AUCTION_CLOSED => 111,
      StatusCode.C112_AUCTION_QUERY_ONT_SELECTED => 112,
      StatusCode.C113_CARD_TYPE_NOT_FOUND => 113,
      StatusCode.C114_OUT_OF_RANGE => 114,
      StatusCode.C115_PERMISSION_DENIED => 115,
      StatusCode.C116_ACCESS_DENIED => 116,
      StatusCode.C117_UNDER_MAINTENANCE => 117,
      StatusCode.C118_CARD_SELECTION => 118,
      StatusCode.C119_INCONSISTENT_OPPONENT => 119,
      StatusCode.C120_ATTACK_NUMBER_REQUIRED => 120,
      StatusCode.C121_SELF_ATTACK => 121,
      StatusCode.C122_SHIELD_PROTECTED => 122,
      StatusCode.C123_NEED_CAPTCHA => 123,
      StatusCode.C124_MULTIPLE_DEVICE => 124,
      StatusCode.C125_OPPONENT_NOT_FOUND => 125,
      StatusCode.C126_OPPONENT_OUT_OF_RANGE => 126,
      StatusCode.C127_OPPONENT_DEFENCE_DECK_EMPTY => 127,
      StatusCode.C128_INVALID_CAPTCHA => 128,
      StatusCode.C129_CARD_BUSY_IN_BUILDING => 129,
      StatusCode.C130_CARD_SACRIFICE => 130,
      StatusCode.C131_CARD_MAX_POWER => 131,
      StatusCode.C132_EVOLVE_MAX => 132,
      StatusCode.C133_EVOLVE_TYPE => 133,
      StatusCode.C134_UPDATE_BUILDING => 134,
      StatusCode.C135_BUILDING_MAX_CARD => 135,
      StatusCode.C136_LIVE_BATTLE_UNAVAILABLE => 136,
      StatusCode.C137_OPPONENT_OFFLINE => 137,
      StatusCode.C138_OPPONENT_BUSY_BATTLE => 138,
      StatusCode.C139_OPPONENT_BUSY => 139,
      StatusCode.C140_RIBEMATE_ATTACK => 140,
      StatusCode.C141_BATTLE_ID_NOT_FOUND => 141,
      StatusCode.C142_UPDATE_INCONSISTANCY => 142,
      StatusCode.C143_TIMED_OUT => 143,
      StatusCode.C144_PLAYER_UNAVAILABLE => 144,
      StatusCode.C145_BATTLE_NOT_FOUND => 145,
      StatusCode.C146_ATTACKER_NOT_FOUND => 146,
      StatusCode.C147_DEFENDER_NOT_FOUND => 147,
      StatusCode.C148_TRIBE_NOT_FOUND => 148,
      StatusCode.C149_TRIBE_JOIN_REQUIRED => 149,
      StatusCode.C150_TRIBE_LIMITATION_RULE => 150,
      StatusCode.C151_MESSAGE_SIZE_EXCEEDED => 151,
      StatusCode.C152_MESSAGE_NOT_FOUND => 152,
      StatusCode.C153_INVALID_INVITATION_TICKET => 153,
      StatusCode.C154_INVALID_RESTORE_KEY => 154,
      StatusCode.C155_CHANGE_ACCOUNT_ERROR => 155,
      StatusCode.C156_RESTORE_DATA_REQUIRED => 156,
      StatusCode.C157_PLAYER_NOT_FOUND => 157,
      StatusCode.C158_REDEEMED_INVITATION_CODE => 158,
      StatusCode.C159_INVALID_EMAIL => 159,
      StatusCode.C160_EXISTS_EMAIL => 160,
      StatusCode.C161_EMAIL_ALREADY_REGISTERED => 161,
      StatusCode.C162_REWARD_ALREADY_RECEIVED => 162,
      StatusCode.C163_ACCOUNT_DEACTIVATED => 163,
      StatusCode.C164_ACCOUNT_RESET_FAILED => 164,
      StatusCode.C165_INVALID_ACTIVATION_CODE => 165,
      StatusCode.C166_CASH_REWARD_NOT_FOUND => 166,
      StatusCode.C167_AVATAR_UNAVAILABLE => 167,
      StatusCode.C168_LEAGUE_JOIN_NEED => 168,
      StatusCode.C169_DEVICE_VRIFICATION_ERROR => 169,
      StatusCode.C170_STORE_NOT_SUPPORTED => 170,
      StatusCode.C171_SELECTED_PACK_INCONSISTANT => 171,
      StatusCode.C172_RECEIPT_NOT_PROVIDED => 172,
      StatusCode.C173_MAX_EVOLVE => 173,
      StatusCode.C174_INTERNAL_ERROR_OCCURED => 174,
      StatusCode.C175_INTERNAL_ERROR_OCCURED => 175,
      StatusCode.C176_PLAYER_OUT_OF_BATTLE => 176,
      StatusCode.C177_COOLDOWN => 177,
      StatusCode.C178_COOL_ENOUGH => 178,
      StatusCode.C179_DEVICE_INCONSISTANT => 179,
      StatusCode.C180_NAME_TOO_LONG => 180,
      StatusCode.C181_NAME_ALREADY_TAKEN => 181,
      StatusCode.C182_COUNTRY_CODE_NOT_SUPPORTED => 182,
      StatusCode.C183_MORE_GOLD => 183,
      StatusCode.C184_MULTIPLE_ONLINE_DEVICE => 184,
      StatusCode.C185_TRIBE_NAME_MAX_CHARS => 185,
      StatusCode.C186_TOP_TRIBES_UNEDITABLE => 186,
      StatusCode.C187_NO_SELL_CRYSTAL_CARDS => 187,
      StatusCode.C188_STATUS_REQUIRED => 188,
      StatusCode.C189_TRIBE_NOT_FOUND => 189,
      StatusCode.C190_NAME_REQUIRED => 190,
      StatusCode.C191_DESCRIPTION_REQUIRED => 191,
      StatusCode.C192_DESCRIPTION_TOO_LANG => 192,
      StatusCode.C193_TRIBE_NAME_ALREADY_EXISTS => 193,
      StatusCode.C194_INVALID_CHIEF_COUNT => 194,
      StatusCode.C195_ALREADY_JOINED_TRIBE => 195,
      StatusCode.C196_TRIBE_BUILDING_REQUIRED => 196,
      StatusCode.C197_MAX_TRIBE_LIMIT_CHANGE => 197,
      StatusCode.C198_NO_MEMBERS_TRIBE => 198,
      StatusCode.C199_UNDECIDED_REQUEST => 199,
      StatusCode.C200_INVALID_DECISION_PARAMETER => 200,
      StatusCode.C201_IVALID_JOIN_REQUEST => 201,
      StatusCode.C202_INCONSISTENT_DATA_PROVIDED => 202,
      StatusCode.C203_JOIN_REQUEST_ALREADY_PROCESSED => 203,
      StatusCode.C204_TRIBE_FULL => 204,
      StatusCode.C205_TRIBE_ACCESS_PERMISSION_DENIED => 205,
      StatusCode.C206_ALREADY_A_MEMBER_TRIBE => 206,
      StatusCode.C207_INVITATION_INVALID => 207,
      StatusCode.C208_INVITATION_ALREADY_PROCESSED => 208,
      StatusCode.C209_NO_TRIBES => 209,
      StatusCode.C210_TRIBE_FOREIGN_PLAYER => 210,
      StatusCode.C211_ABNORMAL_PERMISSION => 211,
      StatusCode.C212_ELDER_NEED => 212,
      StatusCode.C213_SELF_POKE => 213,
      StatusCode.C214_TRIBE_ACCESS => 214,
      StatusCode.C215_SELF_KICK => 215,
      StatusCode.C216_PERMISSION_DENIED => 216,
      StatusCode.C217_MAX_LEVEL_BUILING_COOLDOWN => 217,
      StatusCode.C218_MAX_LEVEL_BUILING_MAINHALL => 218,
      StatusCode.C219_MAX_LEVEL_BUILING_DEFENSE => 219,
      StatusCode.C220_MAX_LEVEL_BUILING_OFFENSE => 220,
      StatusCode.C221_MAX_LEVEL_BUILING_GOLD => 221,
      StatusCode.C222_MAX_LEVEL_BUILING_BANK => 222,
      StatusCode.C223_INVALID_BUILDING_TYPE_FO => 223,
      StatusCode.C224_MINIMUM_DONATION => 224,
      StatusCode.C225_TRIBE_BUILDING_NOT_FOUND => 225,
      StatusCode.C226_UNDECIDED_INVITATION => 226,
      StatusCode.C227_NOT_ENOUGH_TRIBE_MONEY => 227,
      StatusCode.C228_FAILED_TO_UPDATE_TRIBE_SCORE => 228,
      StatusCode.C229_TRIBE_HAS_NO_IDENTIFIER => 229,
      StatusCode.C230_INVALID_BUILDING_TYPE_FOR_CARD_CAPACITY => 230,
      StatusCode.C231_NO_QUERY_SUPPLIED => 231,
      StatusCode.C232_GOOGLE_PLAY_VERIFICATION_FAILED => 232,
      StatusCode.C233_PURCHASE_STATE_INVALID => 233,
      StatusCode.C234_WRONG_SERVER_DATA => 234,
      StatusCode.C235_SIBCHE_VERIFICATION_FAILED => 235,
      StatusCode.C236_CANNOT_BUY_MORE_BOOSTS => 236,
      StatusCode.C237_INVALID_COUNTRY_CODE => 237,
      StatusCode.C238_USER_NOT_FOUND => 238,
      StatusCode.C239_USER_POKED => 239,
      StatusCode.C240_UPDATING_LEAGUE_IN_PROGRESS => 240,
      StatusCode.C241_NOT_IMPLEMENTED => 241,
      StatusCode.C242_INVALID_LEAGUE_ID => 242,
      StatusCode.C301_MOVED_PERMANENTLY => 301,
      StatusCode.C403_SERVICE_UNAVAILABLE => 403,
      StatusCode.C503_SERVICE_UNAVAILABLE => 503,
      StatusCode.C700_UPDATE_NOTICE => 700,
      StatusCode.C701_UPDATE_FORCE => 701,
      _ => 250
    };
  }
}

class RpcException implements Exception {
  final StatusCode statusCode;
  final String message;

  RpcException(this.statusCode, this.message);
}
