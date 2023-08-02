import 'account.dart';
import 'card.dart';

class LoadingData {
  late Account account;
  late Cards baseCards;
  late Fruits fruits;
  late List<ComboHint> comboHints;
  late Map<int, BaseHeroItem> baseHeroItems;
  LoadingData();

  void init(data) {
    fruits = Fruits()..init(data['fruits']);
    baseCards = Cards()..init(data['cards'], args: fruits);
    baseHeroItems = BaseHeroItem.init(data['heroItems']);
    comboHints = ComboHint.init(data["comboItems"]);
  }
}
