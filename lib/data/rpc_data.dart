import 'export.dart';

class LoadingData {
  static String baseURL = "";
  static String chatIp = "";
  static int chatPort = 0;

  late Account account;
  late Map<int, Fruit> fruits;
  late Map<String, dynamic> rules;
  late List<ComboHint> comboHints;
  late Map<int, FruitCard> baseCards;
  late Map<int, BaseHeroItem> baseHeroItems;
  late Map<ShopSections, List<ShopItem>> shopItems;
  late Map<AchievementType, AchievementLine> achievements;
  Map<ShopSections, List<ShopItemVM>>? shopProceedItems;

  LoadingData();

  void init(data) {
    fruits = Fruit.generateMap(data['fruits']);
    baseCards = FruitCard.generateMap(data['cards'], fruits);
    baseHeroItems = BaseHeroItem.init(data['heroItems']);
    achievements = AchievementLine.init(data["achievements"]);
    comboHints = ComboHint.init(data["comboItems"]);
    shopItems = ShopData.init(data["shop"]);
    rules = data["rules"] ??
        {
          "changeNameMinLevel": 100,
          "changeNameCost": 1000,
          "maxDailyGifts": 30,
          "availabilityLevels": {
            'ads': 4,
            'name': 4,
            'park': -1,
            'tribe': 6,
            'league': 8,
            'combo': 15,
            'treasury': 5,
            'popupOpponents': 9,
            'tribeChange': 150,
            'potion': 1
          },
          'mineBallonActiveRatio': 0.1
        };
  }
}
