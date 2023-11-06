import 'package:flutter/foundation.dart';

import 'account.dart';
import '../../utils/utils.dart';

enum AchivementType {
  none,
  pirtul,
  battle,
  quest,
  merge,
  enhance,
  donation,
  collection,
  playTime,
  levelup,
  birds,
  facebook,
  invitation,
  instagram,
  t150,
  t151,
  t152,
  t153,
}

class AchievementLine {
  ValueNotifier<int> selectedIndex = ValueNotifier(0);
  final AchivementType type;
  List<AchievementStep> steps = [];
  AchievementLine(this.type);

  static AchivementType getType(int id) {
    return switch (id) {
      150 => AchivementType.t150,
      151 => AchivementType.t151,
      152 => AchivementType.t152,
      153 => AchivementType.t153,
      _ => AchivementType.values[id],
    };
  }

  static Map<AchivementType, AchievementLine> init(Map map) {
    var result = <AchivementType, AchievementLine>{};
    for (var e in map.entries) {
      var type = getType(int.parse(e.key));
      result[type] = AchievementLine(type);
      if (e.value.isEmpty) {
        result[type]!.steps.add(AchievementStep(type.index, 0, 1));
      } else {
        var entries = e.value.entries.toList();
        for (var i = 0; i < entries.length; i++) {
          var id = int.parse(entries[i].key);
          result[type]!.steps.add(AchievementStep(
              id,
              i > 0 ? entries[i - 1].value as int : 0,
              entries[i].value as int));
        }
      }
      // Default step selection
      result[type]!.selectedIndex.value = result[type]!.steps.length - 1;
    }
    return result;
  }
  }

class AchievementStep {
  final int id, min, max;
  AchievementStep(this.id, this.min, this.max);
}
