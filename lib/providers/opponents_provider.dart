import 'package:flutter/material.dart';

import '../data/data.dart';

class OpponentsProvider extends ChangeNotifier {
  List<Opponent> list = [];
  void update() => notifyListeners();
}
