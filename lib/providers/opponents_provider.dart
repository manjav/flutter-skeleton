import 'package:flutter/material.dart';

import '../data/export.dart';

class OpponentsProvider extends ChangeNotifier {
  List<Opponent> list = [];
  void update() => notifyListeners();
}
