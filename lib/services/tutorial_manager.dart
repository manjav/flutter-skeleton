import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fruitcraft/app_export.dart';
import 'package:get/get.dart';

class TutorialManager extends IService {
  dynamic _currentSequnce;

  var onStepChange = Rx<dynamic>(null);
  var onFinish = Rx<dynamic>(null);
  var onStart = Rx<dynamic>(null);
  final ValueNotifier<bool> _ignorePointer = ValueNotifier<bool>(false);
  Map<String, dynamic>? _currentItem;
  int _index = 0;

  @override
  initialize({List<Object>? args}) {
    super.initialize();
  }

  updateCheckPointAtLevelUp(int level) {
    var checkPoint = {
      3: 300,
      4: 401,
      5: 501,
      6: 601,
      7: 701,
      8: 801,
      9: 901,
      10: 1001,
      12: 1200,
      15: 1500
    };
    if (checkPoint.containsKey(level)) {
      updateTutorialIndex(
          Get.context!, checkPoint[level]!, checkPoint[level]!);
    }
  }

  void toggleIgnorePointer(bool ignore) {
    _ignorePointer.value = ignore;
  }

  bool isTutorial(String route) {
    if (!Tutorial.tutorials.containsKey(route)) return false;

    var account = serviceLocator<AccountProvider>().account;
    int currentId = account.tutorial_id;

    var data = (Tutorial.tutorials[route]! as List).lastWhereOrNull((element) =>
        element["startId"] <= currentId &&
        element["lastId"] >= currentId &&
        account.level == element["level"]);
    if (data == null) return false;
    return true;
  }

  checkToturial(String route) async {
    if (!Tutorial.tutorials.containsKey(route)) return;

    var account = serviceLocator<AccountProvider>().account;
    int currentId = account.tutorial_id;

    var data = (Tutorial.tutorials[route]! as List).firstWhereOrNull(
        (element) =>
            element["startId"] == currentId &&
            account.level == element["level"]);
    if (data == null) return;
    if (_currentSequnce != null) return;
    _currentSequnce = data["sequnces"] as List;
    await Future.delayed(Duration(milliseconds: data["delay"] as int));

    _index = 0;
    onStart(_currentSequnce[0]);
    showOverlay();
  }

  showOverlay() async {
    if (_index >= _currentSequnce.length) {
      var data = _currentSequnce[--_index];
      _currentSequnce = null;
      onFinish.value = data;
      return;
    }
    _currentItem = _currentSequnce[_index];
    await Future.delayed(Duration(milliseconds: _currentItem!["delay"] as int));
    Overlays.insert(
      Get.overlayContext!,
      TutorialOverlay(
        center: _currentItem!["center"],
        characterName: _currentItem!["characterName"],
        dialogueSide: _currentItem!["side"],
        showBackground: _currentItem!["background"],
        showCharacter: _currentItem!["character"],
        showHand: _currentItem!["hand"],
        handPosition: _currentItem!["handPosition"],
        handQuarterTurns: _currentItem!["handQuarterTurns"] ?? 0,
        showFocus: _currentItem!["showFocus"] ?? false,
        text: (_currentItem!["text"] as String).l(),
        characterSize: _currentItem!["characterSize"],
        bottom: _currentItem!["bottom"],
        ignorePointer: _ignorePointer,
        radius: _currentItem!["radius"],
        dialogueHeight: _currentItem!["dialogueHeight"],
        onTap: onTapOverlay,
      ),
    );
  }

  onTapOverlay() {
    var item = _currentItem as Map<String, dynamic>;
    Overlays.remove(OverlaysName.tutorial);
    updateTutorialIndex(
      Get.overlayContext!,
      item["index"],
      item["id"],
      updateRemote:
          item.containsKey("breakPoint") && item["breakPoint"] == true,
    );
    onStepChange.value = item;
    ++_index;
    showOverlay();
  }

  updateTutorialIndex(BuildContext context, int index, int id,
      {bool updateRemote = true}) async {
    try {
      if (context.mounted) {
        serviceLocator<AccountProvider>()
            .update(context, {"tutorial_index": index, "tutorial_id": id});
      }
      if (updateRemote) {
        await serviceLocator<HttpConnection>().tryRpc(
            context, RpcId.tutorialState,
            params: {"index": index, "id": id});
      }
    } catch (e) {
      log('$e');
    }
  }
}
