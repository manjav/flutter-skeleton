// ignore_for_file: constant_identifier_names

enum RpcId {
  scout,
  playerLoad,
// Files
  tutorialExport,
  tutorialLangEnExport,
  tutorialLangFaExport,
  comboExport,
  comboLangEnExport,
  comboLangFaExport,
// Hero APIs
  heroItemsExport,
  heroItemsLangEnExport,
  heroItemsLangFaExport,
  buyHeroItem,
  setHeroItems,
  fruitLangFaExport,
  fruitLangEnExport,
  imageStorageAPI_ImageStorage,
  cardsExport,
  captcha,
  forgotPassword,
  getVCBalance,
}

extension RpcIdEx on RpcId {
  String get value {
    return switch (this) {
      RpcId.scout => "battle/scout",
      RpcId.playerLoad => "player/load",
      RpcId.tutorialExport => "metadata/TutorialData.json",
      RpcId.tutorialLangEnExport => "i18n/en-US/Tutorial.json",
      RpcId.tutorialLangFaExport => "i18n/fa-IR/Tutorial.json",
      RpcId.comboExport => "metadata/CardComboData.json",
      RpcId.comboLangEnExport => "i18n/en-US/CardComboLanguage.json",
      RpcId.comboLangFaExport => "i18n/fa-IR/CardComboLanguage.json",
      RpcId.heroItemsExport => "cards/heroitemsjsonexport",
      RpcId.heroItemsLangEnExport => "i18n/en-US/BaseHeroItemsLanguage.json",
      RpcId.heroItemsLangFaExport => "i18n/fa-IR/BaseHeroItemsLanguage.json",
      RpcId.buyHeroItem => "store/buyheroitem",
      RpcId.setHeroItems => "cards/equipheroitems",
      RpcId.fruitLangFaExport => "i18n/fa-IR/BaseFruitLanguage.json",
      RpcId.fruitLangEnExport => "i18n/en-US/BaseFruitLanguage.json",
      RpcId.imageStorageAPI_ImageStorage => "cardpool/",
      RpcId.cardsExport => "cards/cardsjsonexport",
      RpcId.captcha => "bot/getcaptcha",
      RpcId.forgotPassword => "user/iforgot",
      RpcId.getVCBalance => "user/getvcbalance/client/iOS/"
    };
  }

  bool get needsEncryption {
    return switch (this) {
      RpcId.cardsExport => false,
      _ => true,
    };
  }

  HttpRequestType get requestType {
    return switch (this) {
      RpcId.tutorialExport ||
      RpcId.tutorialLangEnExport ||
      RpcId.tutorialLangFaExport ||
      RpcId.comboExport ||
      RpcId.comboLangEnExport ||
      RpcId.comboLangFaExport ||
      RpcId.heroItemsExport ||
      RpcId.heroItemsLangEnExport ||
      RpcId.heroItemsLangFaExport ||
      RpcId.buyHeroItem ||
      RpcId.setHeroItems ||
      RpcId.fruitLangFaExport ||
      RpcId.fruitLangEnExport ||
      RpcId.imageStorageAPI_ImageStorage ||
      RpcId.cardsExport ||
      RpcId.captcha ||
      RpcId.forgotPassword ||
      RpcId.getVCBalance =>
        HttpRequestType.get,
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
}
