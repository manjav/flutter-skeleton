import 'account.dart';
import 'fruit.dart';
import 'store.dart';

class LoadingData {
  static String baseURL = '';
  static String chatIp = '';
  static int chatPort = 0;

  late Account account;
  late Map<int, Fruit> fruits;
  late List<ComboHint> comboHints;
  late Map<int, FruitCard> baseCards;
  late Map<int, BaseHeroItem> baseHeroItems;
  late Map<ShopSections, List<ShopItem>> shopItems;
  Map<ShopSections, List<ShopItemVM>>? shopProceedItems;

  LoadingData();

  void init(data) {
    fruits = Fruit.generateMap(data['fruits']);
    baseCards = FruitCard.generateMap(data['cards'], fruits);
    baseHeroItems = BaseHeroItem.init(data['heroItems']);
    comboHints = ComboHint.init(data["comboItems"]);
    shopItems = ShopData.init(data["shop"]);
  }
}
