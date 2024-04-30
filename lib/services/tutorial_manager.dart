import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fruitcraft/app_export.dart';
import 'package:get/get.dart';

class TutorialManager {
  dynamic _currentSequnce;

  var onStepChange = Rx<dynamic>(null);
  var onFinish = Rx<dynamic>(null);
  var onStart = Rx<dynamic>(null);
  final ValueNotifier<bool> _ignorePointer = ValueNotifier<bool>(false);
  dynamic _currentItem;
  int _index = 0;
  late BuildContext _context;

  void toggleIgnorePointer(bool ignore) {
    _ignorePointer.value = ignore;
  }

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
    _context = context;

    var data = (Tutorial.tutorials[route]! as List)
        .firstWhereOrNull((element) => element["startIndex"] == currentIndex
            //&& account.level == element["level"]
            );
    if (data == null) return;
    // if (_currentSequnce != null) return;
    _currentSequnce = data["sequnces"] as List;
    await Future.delayed(Duration(milliseconds: data["delay"] as int));

    if (context.mounted) {
      _index = 0;
      onStart(_currentSequnce[0]);
      showOverlay();
    }
  }

  showOverlay() async {
    if (_index == _currentSequnce.length) {
      onFinish.value = _currentSequnce[--_index];
      return;
    }
    _currentItem = _currentSequnce[_index];
    await Future.delayed(Duration(milliseconds: _currentItem["delay"] as int));
    if (_context.mounted) {
      Overlays.insert(
        _context,
        TutorialOverlay(
          center: _currentItem["center"],
          characterName: _currentItem["characterName"],
          dialogueSide: _currentItem["side"],
          showBackground: _currentItem["background"],
          showCharacter: _currentItem["character"],
          showHand: _currentItem["hand"],
          handPosition: _currentItem["handPosition"],
          handQuarterTurns: _currentItem["handQuarterTurns"] ?? 0,
          showFocus: _currentItem["showFocus"] ?? false,
          text: (_currentItem["text"] as String).l(),
          characterSize: _currentItem["characterSize"],
          bottom: _currentItem["bottom"],
          ignorePointer: _ignorePointer,
          radius: _currentItem["radius"],
          onTap: onTapOverlay,
        ),
      );
    }
  }

  onTapOverlay() {
    Overlays.remove(OverlaysName.tutorial);
    updateTutorialIndex(_context, _currentItem["index"], _currentItem["id"]);
    onStepChange.value = _currentItem;
    ++_index;
    showOverlay();
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
