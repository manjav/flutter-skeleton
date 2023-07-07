class Bundle {
  var outcomes = <String, int>{};
  var incomes = <String, int>{};
  Bundle([Map<String, int>? outcomes, Map<String, int>? incomes]) {
    if (outcomes != null) this.outcomes = outcomes;
    if (incomes != null) this.incomes = incomes;
  }

  static Bundle fromData(dynamic data) {
    return Bundle(
        Map.castFrom(data["outcomes"]), Map.castFrom(data['incomes']));
  }
}

enum Bundles { search, shop_0 }

class StringMap<T> {
  final map = <String, T>{};
  void init(Map<String, dynamic> data, {dynamic args}) {
    data.forEach((key, value) {
      map[key] = value;
    });
  }
}
