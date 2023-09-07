import 'account.dart';
import 'card.dart';

class LoadingData {
  static String? restoreKey;
  static String baseURL = '';
  static String chatIp = '';
  static int chatPort = 0;

  late Account account;
  late Cards baseCards;
  late Fruits fruits;
  late List<ComboHint> comboHints;
  late Map<int, BaseHeroItem> baseHeroItems;
  late Map<ShopSections, List<ShopItem>> shopItems;
  LoadingData();

  void init(data) {
    fruits = Fruits()..init(data['fruits']);
    baseCards = Cards()..init(data['cards'], args: fruits);
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
  int id = 0, price = 0, level = 1;
  double ratio = 1.0;
  String currency = "nectar";
  final ShopSections section;
  ShopItem(this.section, Map data) {
    id = data["id"];
    price = data["price"] ?? 0;
    level = data["level"] ?? 1;
    ratio = data["ratio"] ?? 1.0;
    currency = data["currency"] ?? section.getCurrecy();
  }
}
