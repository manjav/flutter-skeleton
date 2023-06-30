import 'package:flutter/material.dart';

import '../../data/core/account.dart';
import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/ilogger.dart';
import '../../view/widgets/indicator.dart';
import '../../view/widgets/skinnedtext.dart';
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
    return SafeArea(
        child: Scaffold(
      body: Stack(children: [
        Widgets.touchable(onTap: () => Navigator.pop(context)),
        Align(
            child: Widgets.rect(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  centerSlice: const Rect.fromLTWH(80, 80, 4, 4),
                  image: Asset.load<Image>('popup_chrome',
                          imageCacheWidth: (410 * DeviceInfo.ratio).round(),
                          imageCacheHeight: (460 * DeviceInfo.ratio).round())
                      .image)),
          child: Stack(
              alignment: Alignment.center,
              fit: StackFit.loose,
              children: [
                Positioned(
                    top: 0, child: headerFactory('popup_${widget.type.name}')),
                Padding(
                    padding: EdgeInsets.fromLTRB(48.d, 176.d, 48.d, 64.d),
                    child: contentFactory()),
                // Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     children: actionsFactory()),
                // ]),
                Positioned(
                    top: 90.d, right: 56.d, child: closeButtonFactory('')),

                // Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ]),
        )),
        Positioned(
            top: 16.d,
            left: 32.d,
            right: 32.d,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: appBarFactory())),
      ]),
    ));
  }

  headerFactory(String title) {
    return Widgets.rect(
        width: 562.d,
        height: 130.d,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            image: DecorationImage(
                centerSlice: const Rect.fromLTWH(12, 120, 4, 4),
                image: Asset.load<Image>(
                  'popup_header',
                  imageCacheWidth: (562 * DeviceInfo.ratio).round(),
                  imageCacheHeight: (130 * DeviceInfo.ratio).round(),
                ).image)),
        child: SkinnedText(title));
  }

  closeButtonFactory(String title) {
    return Widgets.button(
        width: 100.d,
        height: 100.d,
        onPressed: () => Navigator.pop(context),
        child: Asset.load<Image>('popup_close', height: 38.d));
  }

  List<Widget> appBarFactory() {
    return [
      Indicator(widget.type.name, AccountVar.gold),
      SizedBox(width: 16.d),
      Indicator(widget.type.name, AccountVar.nectar, width: 260.d),
    ];
  }

  contentFactory() => Widgets.rect(
      height: 480.d, width: 880.d, color: TColors.green.withAlpha(133));

  actionsFactory() => <Widget>[];
}
