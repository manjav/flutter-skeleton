import '../../app_export.dart';

enum ShopSections { none, card, gold, boost, nectar, subscription }

extension ShopSectionsExtrension on ShopSections {
  String getCurrency() {
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
  static double getMultiplier(int level) {
    const goldMultiplier = 3;
    const veteranGoldDivider = 20;
    const veteranGoldMultiplier = 80;
    return switch (level) {
      < 10 => 1.0,
      < 20 => 2.5,
      < 30 => 4.5,
      < 40 => 7.0,
      < 50 => 10.0,
      < 60 => 12.5,
      < 70 => 16.0,
      < 80 => 20.0,
      < 90 => 25.0,
      < 100 => 30.0,
      < 300 => 30.0 + (((level - 90) / 10).floor() * goldMultiplier).floor(),
      _ => 93.0 +
          (((level - 300) / veteranGoldDivider).floor() * veteranGoldMultiplier)
              .floor(),
    };
  }

  static String calculatePrice(Account account,
      Map<String, SkuDetails> productDetails, ShopItemVM item) {
    var price = item.base.value;
    if (item.inStore) {
      return item.price.getFormattedPrice();
      // return productDetails[item.base.productID]!.mPrice!;
    }
    if (item.base.section == ShopSections.boost) {
      // Converts gold multiplier to nectar for boost packs
      var boostNectarMultiplier =
          getMultiplier(account.level) / account.nectarPrice;
      return switch (price) {
        10 => (30000 * boostNectarMultiplier).round(),
        20 => (90000 * boostNectarMultiplier).round(),
        50 => (300000 * boostNectarMultiplier).round(),
        100 => (1000000 * boostNectarMultiplier).round(),
        _ => price,
      }
          .compact();
    }
    if (item.base.id == 32) {
      return (150 + (account.heroes.length - 1) * 50).compact();
    }
    return price.compact();
  }

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
    currency = data["currency"] ?? section.getCurrency();
  }

  String get productID => "${section.name}_$id";
}

class ShopItemVM {
  final ShopItem base;
  int price, mainCells, crossCells;
  bool get inStore => base.inStore;
  ShopItemVM(this.base, this.price, this.mainCells, this.crossCells);
  String getTitle() => "shop_${base.section.name}_${base.id}";
}
