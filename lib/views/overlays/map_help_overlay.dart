import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class MapHelpOverlay extends AbstractOverlay {
  const MapHelpOverlay({
    super.key,
  }) : super(route: OverlaysName.helpMap);

  @override
  createState() => _MapHelpOverlayState();
}

class _MapHelpOverlayState extends AbstractOverlayState<MapHelpOverlay> {
  final data = [
    {"text": "weak", "image": "opponent_gold_weak"},
    {"text": "strong", "image": "opponent_gold_strong"},
    {"text": "weak", "image": "opponent_power_weak"},
    {"text": "strong", "image": "opponent_power_strong"},
  ];

  @override
  initState() {
    super.initState();
    checkTutorial();
    Future.delayed(100.ms,
        () => serviceLocator<TutorialManager>().toggleIgnorePointer(true));
  }

  @override
  Widget build(BuildContext context) {
    return Widgets.rect(
      height: Get.height,
      width: Get.width,
      color: TColors.black80,
      child: Center(
        child: Widgets.rect(
          height: 1026.d,
          width: Get.width * 0.95,
          decoration: Widgets.imageDecorator("opponent_frame"),
          margin: EdgeInsets.only(bottom: 200.d),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Widgets.button(
                context,
                alignment: Alignment.center,
                width: 160.d,
                height: 160.d,
                onPressed: () {
                  serviceLocator<TutorialManager>().toggleIgnorePointer(false);
                  serviceLocator<TutorialManager>().onTapOverlay();
                  Overlays.remove(widget.route);
                },
                child: Asset.load<Image>('popup_close', height: 38.d),
              ),
              Expanded(
                child: Material(
                  color: TColors.transparent,
                  child: ListView.separated(
                    itemCount: data.length,
                    scrollDirection: Axis.horizontal,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.d, vertical: 0.d),
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          LoaderWidget(
                            key: GlobalKey(),
                            AssetType.image,
                            data[index]["image"]!,
                            subFolder: "tutorial",
                            height: 694.d,
                            width: 500.d,
                          ),
                          SizedBox(
                            height: 22.d,
                          ),
                          Widgets.rect(
                            width: 334.d,
                            height: 81.d,
                            decoration: Widgets.imageDecorator(
                                "opponent_frame_caption"),
                            child: Center(
                              child: Text(
                                data[index]["text"]!.l(),
                                style: TStyles.large.copyWith(
                                  color: TColors.primary90,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(width: 41.d),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
