import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../app_export.dart';

class MissionOverlay extends AbstractOverlay {
  final List<Mission> missions;

  const MissionOverlay({
    required this.missions,
    super.key,
  }) : super(route: OverlaysName.mission);

  @override
  createState() => _MissionOverlayState();
}

class _MissionOverlayState extends AbstractOverlayState<MissionOverlay> {
  ValueNotifier<bool> show = ValueNotifier(true);

  @override
  void initState() {
    accountProvider.addListener(() async {
      var isFinishMission = MissionData.missions.firstWhereOrNull(
          (element) => element.finishId == accountProvider.account.tutorial_id);

      if (isFinishMission != null) {
        await Future.delayed(800.ms);
        show.value = false;
        await Future.delayed(300.ms);
        Overlays.remove(OverlaysName.mission);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: show,
          builder: (context, value, child) {
            return AnimatedPositioned(
              duration: 300.ms,
              top: show.value ? 0 : -300,
              width: Get.width,
              height: widget.missions.length * 110.d,
              child: Container(
                height: widget.missions.length * 110.d,
                width: Get.width,
                color: TColors.black80,
                child: Material(
                  child: ListView.builder(
                    itemCount: widget.missions.length,
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.d, vertical: 10.d),
                    itemBuilder: (ctx, index) {
                      var mission = widget.missions[index];
                      return Row(
                        children: [
                          LoaderWidget(
                            key: GlobalKey(),
                            AssetType.image,
                            accountProvider.account.tutorial_id >=
                                    mission.doneId
                                ? "icon_checked"
                                : "icon_check",
                            subFolder: "tutorial",
                            height: 70.d,
                            width: 70.d,
                          ),
                          SizedBox(
                            width: 10.d,
                          ),
                          Text(
                            widget.missions[index].mission.l(),
                            style: TStyles.medium.copyWith(
                              color: TColors.primary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
