class StringMap<T> {
  final map = <String, T>{};
  void initialize(Map<String, dynamic> data, {dynamic args}) {
    data.forEach((key, value) {
      map[key] = value;
    });
  }

  void setDefault(
      String name, Map<String, dynamic> data, dynamic defaultValue) {
    map[name] = data[name] ?? defaultValue;
  }
}

enum Values {
  none,
  gold,
  leagueRank,
  nectar,
  potion,
  rank,
}

class IntVec2d {
  final int i, j;
  IntVec2d(this.i, this.j);
  @override
  String toString() => "$i, $j";
}
