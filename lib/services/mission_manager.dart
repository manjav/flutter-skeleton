import 'package:flutter_animate/flutter_animate.dart';
import 'package:fruitcraft/app_export.dart';
import 'package:get/get.dart';

class MissionManager extends IService {
  Missions? currentMissions;

  @override
  initialize({List<Object>? args}) {
    serviceLocator<AccountProvider>().addListener(() {
      checkMission();
    });
    checkMission();
  }

  checkMission() async {
    var account = serviceLocator<AccountProvider>().account;
    int tutorialId = account.tutorial_id;

    // var isFinishMission = MissionData.missions.firstWhereOrNull(
    //         (element) => element.finishId == account.tutorial_id) !=
    //     null;
    // if (isFinishMission) await Future.delayed(300.ms);

    var mission = MissionData.missions.firstWhereOrNull((element) =>
        tutorialId >= element.startId &&
        tutorialId < element.finishId &&
        account.level == element.level);

    if (mission == null) return;
    // if (currentMissions != mission) {
    //   Overlays.remove(OverlaysName.mission);
    // }
    await Future.delayed(1300.ms);
    currentMissions = mission;
    Overlays.insert(
        Get.overlayContext!, MissionOverlay(missions: mission.missions));
  }
}
