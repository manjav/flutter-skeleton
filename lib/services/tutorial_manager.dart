import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fruitcraft/app_export.dart';
import 'package:get/get.dart';

class TutorialManager {
  dynamic _currentSequnce;

  var onStepChange = Rx<dynamic>(null);
  var onFinish = Rx<dynamic>(null);

  bool isTutorial(String route) {
    if (!Tutorial.tutorials.containsKey(route)) return false;

    var account = serviceLocator<AccountProvider>().account;
    int currentIndex = account.tutorial_index;

    var data = (Tutorial.tutorials[route]! as List)
        .lastWhereOrNull((element) => element["lastIndex"] >= currentIndex
            //&& account.level == element["level"]
            );
    if (data == null) return false;
    return true;
  }

  checkToturial(BuildContext context, String route) async {
    if (!Tutorial.tutorials.containsKey(route)) return;

    var account = serviceLocator<AccountProvider>().account;
    int currentIndex = account.tutorial_index;

    var data = (Tutorial.tutorials[route]! as List)
        .firstWhereOrNull((element) => element["startIndex"] == currentIndex
            //&& account.level == element["level"]
            );
    if (data == null) return;
    // if (_currentSequnce != null) return;
    _currentSequnce = data["sequnces"] as List;
    await Future.delayed(Duration(milliseconds: data["delay"] as int));

    if (context.mounted) {
      showOverlay(context, 0);
    }
  }

  showOverlay(BuildContext context, int index) async {
    if (index == _currentSequnce.length) {
      onFinish.value = _currentSequnce[--index];
      // if (onFinish != null) onFinish(_currentSequnce[--index]);
      // _currentSequnce = null;
      return;
    }
    var item = _currentSequnce[index];
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
          handQuarterTurns: item["handQuarterTurns"] ?? 0,
          showFocus: item["showFocus"] ?? false,
          text: (item["text"] as String).l(),
          onTap: () {
            Overlays.remove(OverlaysName.tutorial);
            updateTutorialIndex(context, item["index"], item["id"]);
            onStepChange.value = item;
            showOverlay(context, ++index);
          },
        ),
      );
    }
  }

  updateTutorialIndex(BuildContext context, int index, int id) async {
    try {
      // await serviceLocator<HttpConnection>().tryRpc(
      //     context, RpcId.tutorialState,
      //     params: {"index": 11, "id": id});
      if (context.mounted) {
        serviceLocator<AccountProvider>()
            .update(context, {"tutorial_index": index, "tutorial_id": id});
      }
    } catch (e) {
      log('$e');
    }
  }
}
