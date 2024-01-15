import 'package:flutter/material.dart';

import '../services/device_info.dart';

class Scroll {
  static Future<Offset> scrollToItem(GlobalKey key, ScrollController controller,
      {double marginTop = 0,
      double marginBottom = 0,
      int time = 200,
      int direction = 1}) async {
    var box = key.currentContext?.findRenderObject() as RenderBox;
    var position = box.localToGlobal(Offset.zero); //this is global position
    var duration = Duration(milliseconds: time);
    const curve = Curves.ease;
    final top = position.dy - marginTop;
    if (top < 0) {
      position = position.translate(0, -top);
      await controller.animateTo(controller.position.pixels + top * direction,
          duration: duration, curve: curve);
    }
    final bottom = DeviceInfo.size.height - position.dy - marginBottom;
    if (bottom < 0) {
      position = position.translate(0, bottom);
      await controller.animateTo(
          controller.position.pixels - bottom * direction,
          duration: duration,
          curve: curve);
    }
    return position;
  }
}
