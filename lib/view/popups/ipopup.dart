import 'package:flutter/material.dart';
import 'package:flutter_skeleton/services/deviceinfo.dart';

import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/ilogger.dart';
import '../widgets.dart';

enum PopupType {
  none,
  scout,
}

extension Popups on PopupType {
  String get routeName => "/$name";

  AbstractPopup getWidget({
    EdgeInsets? insetPadding,
    List<Object>? args,
  }) {
    return switch (this) {
      _ => AbstractPopup(insetPadding: insetPadding!, args: args),
    };
  }

  static show(
    BuildContext context,
    PopupType type, {
    EdgeInsets? insetPadding,
    List<Object>? args,
    Color? barrierColor,
    bool? barrierDismissible,
    // String sfx = '',
  }) async {
    var result = await showGeneralDialog(
        barrierDismissible: barrierDismissible ?? true,
        barrierColor: barrierColor ?? TColors.black80,
        context: context,
        barrierLabel: "",
        pageBuilder: (c, _, __) {
          return type.getWidget(
              insetPadding:
                  insetPadding ?? EdgeInsets.fromLTRB(92.d, 128.d, 92.d, 92.d),
              args: args);
        });
    return result;
  }
}

class AbstractPopup extends StatefulWidget {
  // final bool showConfetti;
  final PopupType type;
  final String sfx;
  final EdgeInsets insetPadding;
  final List<Object>? args;

  const AbstractPopup({
    this.type = PopupType.none,
    this.sfx = '',
    this.insetPadding = EdgeInsets.zero,
    this.args,
    super.key,
  });
  @override
  createState() => AbstractPopupState();
}

class AbstractPopupState<T extends AbstractPopup> extends State<T>
    with ILogger {
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topCenter, children: [
      Positioned(
          top: widget.insetPadding.top,
          right: widget.insetPadding.right,
          bottom: widget.insetPadding.bottom,
          left: widget.insetPadding.left,
          child: Asset.load<Image>(
            'popup_chrome',
            imageCacheWidth: (128 * DeviceInfo.ratio).round(),
            imageCacheHeight: (128 * DeviceInfo.ratio).round(),
            imageCenterSlice: const Rect.fromLTWH(20, 20, 4, 4),
          )),
      Positioned(top: 80.d, child: headerFactory('')),
      Positioned(top: 180.d, right: 140.d, child: closeButtonFactory('')),
      Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        contentFactory(),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actionsFactory()),
      ]),
    ]);
  }

  headerFactory(String title) {
    return Widgets.rect(
        width: 562.d,
        height: 130.d,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            image: DecorationImage(
                centerSlice: const Rect.fromLTWH(20, 20, 4, 4),
                image: Asset.load<Image>(
                  'popup_header',
                  imageCacheWidth: (128 * DeviceInfo.ratio).round(),
                  imageCacheHeight: (128 * DeviceInfo.ratio).round(),
                ).image)),
        child: Text(title));
  }

  closeButtonFactory(String title) {
    return Widgets.button(
        color: TColors.transparent,
        width: 100.d,
        height: 100.d,
        onPressed: () => Navigator.pop(context),
        child: Asset.load<Image>('popup_close', height: 38.d));
    // return Text(title);
  }

  contentFactory() => const SizedBox();

  actionsFactory() => <Widget>[];
}
