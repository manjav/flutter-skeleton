import 'package:flutter_animate/flutter_animate.dart';
import 'package:fruitcraft/app_export.dart';
import 'package:fruitcraft/views/overlays/mission_overlay.dart';
import 'package:get/get.dart';

class MissionManager extends IService {
  @override
  initialize({List<Object>? args}) {
    serviceLocator<AccountProvider>().addListener(() {
      checkMission();
    });
    checkMission();
  }

  checkMission() async {
    var account = serviceLocator<AccountProvider>().account;
    int tutorialIndex = account.tutorial_index;

    var mission = MissionData.missions
        .firstWhereOrNull((element) => element.startIndex == tutorialIndex);

    if (mission == null) return;
    await Future.delayed(1300.ms);
    Overlays.insert(
        Get.overlayContext!, MissionOverlay(missions: mission.missions));
  }
}
