import 'package:flutter/material.dart';

import '../../data/core/account.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/ilogger.dart';
import '../../view/widgets/indicator.dart';
import '../../view/widgets/skinnedtext.dart';
import '../overlays/ioverlay.dart';
import '../route_provider.dart';
import '../widgets.dart';

class AbstractPopup extends StatefulWidget {
  final Routes type;
  final Map<String, dynamic> args;
  final bool barrierDismissible;

  const AbstractPopup(
    this.type, {
    required this.args,
    this.barrierDismissible = true,
    super.key,
  });
  @override
  createState() => AbstractPopupState();
}

class AbstractPopupState<T extends AbstractPopup> extends State<T>
    with ILogger {
  Alignment alignment = Alignment.center;
  EdgeInsets contentPadding = EdgeInsets.fromLTRB(48.d, 176.d, 48.d, 92.d);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: TColors.black80,
      body: Stack(children: [
        Widgets.touchable(
            onTap: widget.barrierDismissible
                ? () => Navigator.pop(context)
                : null),
        Align(
            alignment: alignment,
            child: Widgets.rect(
              margin: EdgeInsets.fromLTRB(24.d, 100.d, 24.d, 0),
              padding: EdgeInsets.symmetric(horizontal: 24.d),
              decoration: Widgets.imageDecore(
                  "popup_chrome", ImageCenterSliceData(410, 460)),
              child: Stack(
                  alignment: Alignment.topCenter,
                  fit: StackFit.loose,
                  children: [
                    innerChromeFactory(),
                    titleTextFactory(),
                    Padding(padding: contentPadding, child: contentFactory()),
                    Positioned(
                        top: 60.d, right: -12.d, child: closeButtonFactory()),
                  ]),
            )),
        Positioned(
            top: 16.d,
            left: 32.d,
            right: 32.d,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: appBarElements())),
      ]),
    ));
  }

  String titleBuilder() => widget.type.name.toLowerCase().l();

  Widget titleTextFactory() {
    return Widgets.rect(
        width: 562.d,
        height: 130.d,
        padding: EdgeInsets.only(bottom: 14.d),
        decoration:
            Widgets.imageDecore("popup_title", ImageCenterSliceData(562, 130)),
        child: SkinnedText(titleBuilder(), style: TStyles.large));
  }

  Widget closeButtonFactory() {
    return Widgets.button(
        alignment: Alignment.center,
        width: 160.d,
        height: 160.d,
        onPressed: () => Navigator.pop(context),
        child: Asset.load<Image>('popup_close', height: 38.d));
  }

  List<Widget> appBarElements() {
    return [
      Indicator(widget.type.name, AccountField.gold),
      Indicator(widget.type.name, AccountField.nectar, width: 310.d)
    ];
  }

  Widget innerChromeFactory() => const SizedBox();

  Widget contentFactory() => Widgets.rect(
      height: 480.d, width: 880.d, color: TColors.green.withAlpha(133));

  Widget dualColorText(String whiteText, String coloredText,
      {TextStyle? style}) {
    style = style ?? TStyles.large;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SkinnedText(whiteText, style: style),
      SizedBox(width: 18.d),
      SkinnedText(coloredText, style: style.copyWith(color: TColors.orange))
    ]);
  }

  void toast(String message) =>
      Overlays.insert(context, OverlayType.toast, args: message);
}
