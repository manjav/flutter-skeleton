import 'package:flutter/material.dart';

import '../data/core/adam.dart';

class OpponentsProvider extends ChangeNotifier {
  List<Opponent> list = [];
  void update() => notifyListeners();
}
