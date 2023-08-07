import 'package:flutter/material.dart';

mixin KeyProvider {
  final Map<int, GlobalKey> _keys = {};

  GlobalKey getGlobalKey(int key) =>
      _keys.containsKey(key) ? _keys[key]! : _keys[key] = GlobalKey();
}
