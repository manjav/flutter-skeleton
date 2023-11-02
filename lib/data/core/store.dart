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

  bool get inStore => this == ShopSections.gold || this == ShopSections.nectar;
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
  bool get inStore => section.inStore;
  ShopItem(this.section, Map data) {
    id = data["id"] ?? 0;
    value = data["value"] ?? 0;
    level = data["level"] ?? 1;
    ratio = data["ratio"] ?? 1.0;
    reward = data["reward"] ?? "";
    isPopular = data.containsKey("pop");
    currency = data["currency"] ?? section.getCurrecy();
  }

  Object? get productID => "${section.name}_$id";
}

class ShopItemVM {
  final ShopItem base;
  int price, mainCells, crossCells;
  bool get inStore => base.inStore;
  ShopItemVM(this.base, this.price, this.mainCells, this.crossCells);
}
