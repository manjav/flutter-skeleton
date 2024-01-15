import 'package:flutter/material.dart';

import '../app_export.dart';

class OpponentsProvider extends ChangeNotifier {
  List<Opponent> list = [];
  void update() => notifyListeners();
}
