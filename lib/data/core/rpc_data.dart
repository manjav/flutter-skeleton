import 'account.dart';
import 'fruit.dart';

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
    baseCards = Cards()..initialize(data['cards'], args: fruits);
    baseHeroItems = BaseHeroItem.init(data['heroItems']);
    comboHints = ComboHint.init(data["comboItems"]);
    shopItems = ShopData.init(data["shop"]);
  }
}

enum ShopSections { none, card, gold, boost, nectar, subscription }

extension ShopSectionsExtrension on ShopSections {
  String getCurrecy() {
    return switch (this) {
      ShopSections.gold ||
      ShopSections.nectar ||
      ShopSections.subscription =>
        "real",
      _ => "nectar"
    };
  }
}

class ShopData {
  static const boostDeadline = 18000;
  static Map<ShopSections, List<ShopItem>> init(Map shopItems) {
    var map = <ShopSections, List<ShopItem>>{};
    for (var entry in shopItems.entries) {
      var section = ShopSections.values[int.parse(entry.key)];
      map[section] = [];
      for (var shopItem in entry.value) {
        map[section]!.add(ShopItem(section, shopItem));
      }
    }
    return map;
  }
}

class ShopItem {
  double ratio = 1.0;
  bool isPopular = false;
  String currency = "", reward = "";
  int id = 0, value = 0, level = 1;
  late ShopSections section;
  ShopItem(this.section, Map data) {
    id = data["id"] ?? 0;
    value = data["value"] ?? 0;
    level = data["level"] ?? 1;
    ratio = data["ratio"] ?? 1.0;
    reward = data["reward"] ?? "";
    isPopular = data.containsKey("pop");
    currency = data["currency"] ?? section.getCurrecy();
  }
}

class ShopItemVM {
  final int price, mainCells, crossCells;
  final ShopItem base;
  ShopItemVM(this.base, this.price, this.mainCells, this.crossCells);
}
