import 'package:flutter/material.dart';

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

class IntVec2 {
  final int i, j;
  IntVec2(this.i, this.j);
  @override
  String toString() => "$i, $j";
}

class IntVec3 extends IntVec2 {
  final int k;
  IntVec3(super.i, super.j, this.k);
  @override
  String toString() => "$i, $j, $k";
}

class ListValueNotifier<T> extends ValueNotifier<List<T>> {
  ListValueNotifier(super.value);

  void add(T item) {
    value.add(item);
    notifyListeners();
  }

  void remove(T item) {
    value.remove(item);
    notifyListeners();
  }

  void removeLast() {
    value.removeLast();
    notifyListeners();
  }

  void update(int index, T item) {
    value[index] = item;
    notifyListeners();
  }
}
