import 'account.dart';
import 'card.dart';

class LoadingData {
  static String? restoreKey;
  late Account account;
  late Cards baseCards;
  late Fruits fruits;
  late List<ComboHint> comboHints;
  late List<ShopItem> shopItems;
  late Map<int, BaseHeroItem> baseHeroItems;
  LoadingData();

  void init(data) {
    fruits = Fruits()..init(data['fruits']);
    baseCards = Cards()..init(data['cards'], args: fruits);
    baseHeroItems = BaseHeroItem.init(data['heroItems']);
    comboHints = ComboHint.init(data["comboItems"]);
    shopItems = ShopData.init(data["shop"]);
  }
}

class ShopData {
  static List<ShopItem> init(List shopItems) {
    var list = <ShopItem>[];
    for (var shopItem in shopItems) {
      list.add(ShopItem(shopItem));
    }
    return list;
  }
}

class ShopItem {
  int id = 0, type = 0, minLevel = 1, price = 0, level = 1;
  double boost = 1.0;
  String currency = "nectar";
  ShopItem(Map data) {
    id = data["id"];
    type = data["type"];
    minLevel = data["minLevel"] ?? 1;
    price = data["price"] ?? 0;
    currency = data["currency"] ?? "nectar";
    level = data["level"] ?? 1;
    boost = data["boost"] ?? 1.0;
  }
}
