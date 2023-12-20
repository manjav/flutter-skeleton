import 'account.dart';
import 'achievement.dart';
import 'fruit.dart';
import 'store.dart';

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
  late Map<AchivementType, AchievementLine> achievements;
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
          "maxDailyGifts": 30
        };
  }
}
