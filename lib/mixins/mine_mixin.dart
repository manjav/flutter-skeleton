import '../app_export.dart';

mixin MineMixin {
  int collectableGold(Account account) {
    var building = account.buildings[Buildings.mine]!;
    var goldPerSec = building.getCardsBenefit(account) / 3600;
    return ((account.getTime() - account.last_gold_collect_at) * goldPerSec)
        .clamp(0, building.benefit)
        .floor();
  }

  bool isCollectable(Account account) =>
      collectableGold(account) >
      (account.loadingData.rules["mineBallonActiveRatio"]! *
              account.buildings[Buildings.mine]!.benefit)
          .floor();

  int nextFullTime(Account account) {
    var building = account.buildings[Buildings.mine]!;
    if (building.level == 0) return -1;

    var capacity = account.buildings[Buildings.mine]!.benefit;
    var goldPerSec = building.getCardsBenefit(account) / 3600;
    var collected = collectableGold(account);

    return (capacity - collected) ~/ goldPerSec;
  }

  int nextCollectableTime(Account account) {
    var building = account.buildings[Buildings.mine]!;
    if (building.level == 0) return -1;

    var collected = collectableGold(account);
    var capacity = account.buildings[Buildings.mine]!.benefit *
        account.loadingData.rules["mineBallonActiveRatio"]!;
    var goldPerSec = building.getCardsBenefit(account) / 3600;

    return (capacity - collected) ~/ goldPerSec;
  }

  int goldLevel(Account account) {
    var building = account.buildings[Buildings.mine]!;
    if (building.level == 0) return 0;
    return ((5 * collectableGold(account)) / building.benefit).round();
  }
}
