import 'package:flutter/material.dart';
import 'package:fruitcraft/app_export.dart';

class TutorialManager {
  dynamic currentSequnce;

  bool inTutorial(String route) {
    return true;
  }

  checkToturial(BuildContext context, String route,
      {VoidCallback? onFinish, Function(dynamic)? onTap}) async {
    if (!Tutorial.tutorials.containsKey(route)) return;

    //todo: check tutorial by index and level
    //for now we just get the sequnces and show them

    var data = Tutorial.tutorials[route]![0];
    currentSequnce = data["sequnces"] as List;
    await Future.delayed(Duration(milliseconds: data["delay"] as int));
    if (context.mounted) {
      showOverlay(context, 0, onFinish: onFinish, onTap: onTap);
    }
  }

  showOverlay(BuildContext context, int index,
      {VoidCallback? onFinish, Function(dynamic)? onTap}) async {
    if (index + 1 == currentSequnce.length) {
      if (onFinish != null) onFinish();
      return;
    }
    var item = currentSequnce[index];
    await Future.delayed(Duration(milliseconds: item["delay"] as int));
    if (context.mounted) {
      Overlays.insert(
        context,
        TutorialOverlay(
          center: item["center"],
          characterName: item["characterName"],
          dialogueSide: item["side"],
          showBackground: item["background"],
          showCharacter: item["character"],
          showHand: item["hand"],
          handPosition: item["handPosition"],
          text: (item["text"] as String).l(),
          onTap: () {
            Overlays.remove(OverlaysName.tutorial);
            if (onTap != null) onTap(item);
            showOverlay(context, ++index, onFinish: onFinish, onTap: onTap);
          },
        ),
      );
    }
  }
}
