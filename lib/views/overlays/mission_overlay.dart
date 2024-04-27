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
  bool show = true;

  @override
  void initState() {
    accountProvider.addListener(() async {
      var isFinishMission = MissionData.missions.firstWhereOrNull((element) =>
          element.finishIndex == accountProvider.account.tutorial_index);

      if (isFinishMission != null) {
        await Future.delayed(800.ms);
        setState(() {
          show = false;
        });
        await Future.delayed(300.ms);
        Overlays.remove(OverlaysName.mission);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, value, child) {
        return Positioned(
          top: 0,
          width: Get.width,
          child: AnimatedContainer(
            duration: 300.ms,
            height: show ? 250.d : 0.d,
            width: Get.width,
            color: TColors.black80,
            child: Expanded(
              child: Material(
                child: ListView.builder(
                  itemCount: widget.missions.length,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.d, vertical: 10.d),
                  itemBuilder: (ctx, index) {
                    var mission = widget.missions[index];
                    return Row(
                      children: [
                        LoaderWidget(
                          key: GlobalKey(),
                          AssetType.image,
                          value.account.tutorial_id > mission.doneId
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
                          style: TStyles.large.copyWith(
                            color: TColors.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
