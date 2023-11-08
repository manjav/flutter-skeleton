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

extension AchivementTypeExtension on AchivementType {
  int get id {
    return switch (this) {
      AchivementType.t150 => 150,
      AchivementType.t151 => 151,
      AchivementType.t152 => 152,
      AchivementType.t153 => 153,
      _ => index
    };
  }
}

class AchievementLine {
  ValueNotifier<int> selectedIndex = ValueNotifier(0);
  final AchivementType type;
  List<AchievementStep> steps = [];
  late AchievementStep currentStep;

  AchievementLine(this.type);
  int getAccountValue(Account account) {
    var map = account.achivementMap;
    return switch (type) {
      AchivementType.pirtul => Utils.toInt(map["numberOfsquashedPirtul"]),
      AchivementType.battle => Utils.toInt(map["numberOfWonBattle"]),
      AchivementType.quest => Utils.toInt(map["numberOfWonQuest"]),
      AchivementType.merge => Utils.toInt(map["numberOfEvolvedCards"]),
      AchivementType.enhance => Utils.toInt(map["numberOfEnhancedCards"]),
      AchivementType.donation => Utils.toInt(map["numberOfCollectedGold"]),
      AchivementType.collection => account.collection.length,
      AchivementType.playTime => Utils.toInt(map["timeOfPlaying"]),
      AchivementType.levelup => account.level,
      // AchivementType.birds => Utils.toInt(map["numberOfEvolvedCards"]),
      // AchivementType.facebook => Utils.toInt(map["numberOfEvolvedCards"]),
      // AchivementType.invitation => Utils.toInt(map["numberOfEvolvedCards"]),
      // AchivementType.instagram => Utils.toInt(map["numberOfEvolvedCards"]),
      _ => 0,
    };
  }

  String format(int value) {
    return switch (type) {
      AchivementType.donation => value.compact(),
      AchivementType.playTime => value.round().toRemainingTime(),
      AchivementType.collection =>
        "${(value / steps[3].max * 100).floor().max(100)}%",
      _ => value.toString(),
    };
  }

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

  void updateCurrents(Account account) {
    for (var i = 0; i < steps.length; i++) {
      if (steps[i].max > getAccountValue(account)) {
        selectedIndex.value = i;
        currentStep = steps[i];
        return;
      }
      currentStep = steps.last;
    }
  }
}

class AchievementStep {
  final int id, min, max;
  AchievementStep(this.id, this.min, this.max);
}
