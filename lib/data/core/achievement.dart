import 'package:flutter/foundation.dart';

import '../data.dart';
import '../../skeleton/utils/utils.dart';

enum AchievementType {
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

extension AchivementTypeExtension on AchievementType {
  int get id {
    return switch (this) {
      AchievementType.t150 => 150,
      AchievementType.t151 => 151,
      AchievementType.t152 => 152,
      AchievementType.t153 => 153,
      _ => index
    };
  }
}

class AchievementLine {
  ValueNotifier<int> selectedIndex = ValueNotifier(0);
  final AchievementType type;
  List<AchievementStep> steps = [];
  late AchievementStep currentStep;

  AchievementLine(this.type);
  int getAccountValue(Account account) {
    var map = account.achievementMap;
    return switch (type) {
      AchievementType.pirtul => Convert.toInt(map["numberOfsquashedPirtul"]),
      AchievementType.battle => Convert.toInt(map["numberOfWonBattle"]),
      AchievementType.quest => Convert.toInt(map["numberOfWonQuest"]),
      AchievementType.merge => Convert.toInt(map["numberOfEvolvedCards"]),
      AchievementType.enhance => Convert.toInt(map["numberOfEnhancedCards"]),
      AchievementType.donation => Convert.toInt(map["numberOfCollectedGold"]),
      AchievementType.collection => account.collection.length,
      AchievementType.playTime => Convert.toInt(map["timeOfPlaying"]),
      AchievementType.levelup => account.level,
      // AchievementType.birds => Convert.toInt(map["numberOfEvolvedCards"]),
      // AchievementType.facebook => Convert.toInt(map["numberOfEvolvedCards"]),
      // AchievementType.invitation => Convert.toInt(map["numberOfEvolvedCards"]),
      // AchievementType.instagram => Convert.toInt(map["numberOfEvolvedCards"]),
      _ => 0,
    };
  }

  String format(int value) {
    return switch (type) {
      AchievementType.donation => value.compact(),
      AchievementType.playTime => value.round().toRemainingTime(),
      AchievementType.collection =>
        "${(value / steps[3].max * 100).floor().max(100)}%",
      _ => value.toString(),
    };
  }

  String countFormat(int value) {
    return switch (type) {
      AchievementType.donation => value.compact(),
      AchievementType.playTime => value.round().toRemainingTime(),
      _ => value.toString(),
    };
  }

  static AchievementType getType(int id) {
    return switch (id) {
      150 => AchievementType.t150,
      151 => AchievementType.t151,
      152 => AchievementType.t152,
      153 => AchievementType.t153,
      _ => AchievementType.values[id],
    };
  }

  static Map<AchievementType, AchievementLine> init(Map map) {
    var result = <AchievementType, AchievementLine>{};
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
