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
  void init(Map<String, dynamic> data) {
    data.forEach((key, value) {
      map[key] = value;
    });
  }

  // T? operator [](String key) => map[key];
  // void operator []=(String key, T value) {
  //   map[key] = value;
  // }

  // T? remove(Object? key) => map.remove(key);
  // bool containsKey(Object? key) => map.containsKey(key);
  // bool get isEmpty => throw map.isEmpty;
  // Iterable<MapEntry<String, T>> get entries => map.entries;
  // Iterable<String> get keys => map.keys;
  // Iterable<T> get values => map.values;
  // int get length => map.length;
}

