import 'package:flutter/material.dart';

import '../../data/core/infra.dart';
import '../../mixins/logger.dart';
import '../../mixins/service_provider.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/widgets/indicator.dart';
import '../widgets/skinned_text.dart';
import '../overlays/overlay.dart';
import '../route_provider.dart';
import '../widgets.dart';

class AbstractPopup extends StatefulWidget {
  final Routes type;
  final Map<String, dynamic> args;

  const AbstractPopup(
    this.type, {
    required this.args,
    super.key,
  });
  @override
  createState() => AbstractPopupState();
}

class AbstractPopupState<T extends AbstractPopup> extends State<T>
    with ILogger, ServiceProviderMixin {
  Alignment alignment = Alignment.center;
  bool barrierDismissible = true, canPop = true;

  BoxDecoration get chromeSkinBuilder =>
      Widgets.imageDecorator("popup_chrome", ImageCenterSliceData(410, 460));

  @override
  void initState() {
    getService<Sounds>().play("popup");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var paddingTop = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
        backgroundColor: backgroundColor,
        body: PopScope(
          canPop: canPop,
          child: Stack(children: [
            Widgets.touchable(
                onTap:
                    barrierDismissible ? () => Navigator.pop(context) : null),
            Align(
                alignment: alignment,
                child: Widgets.rect(
                  margin: chromeMargin,
                  padding: EdgeInsets.symmetric(horizontal: 24.d),
                  decoration: chromeSkinBuilder,
                  child: Stack(
                      alignment: Alignment.topCenter,
                      fit: StackFit.loose,
                      children: [
                        innerChromeFactory(),
                        titleTextFactory(),
                        Padding(
                            padding: contentPadding, child: contentFactory()),
                        Positioned(
                            top: 60.d,
                            right: -12.d,
                            child: closeButtonFactory()),
                      ]),
                )),
            Positioned(
                top: paddingTop > 0 ? paddingTop : 24.d,
                left: 32.d,
                right: 32.d,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: appBarElements())),
          ]),
        ));
  }

  Color get backgroundColor => TColors.black80;
  String titleBuilder() => widget.type.name.toLowerCase().l();
  EdgeInsets get chromeMargin => EdgeInsets.fromLTRB(24.d, 100.d, 24.d, 0);
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(48.d, 176.d, 48.d, 92.d);

  Widget titleTextFactory() {
    return Widgets.rect(
        width: 562.d,
        height: 130.d,
        padding: EdgeInsets.only(bottom: 14.d),
        decoration: Widgets.imageDecorator(
            "popup_title", ImageCenterSliceData(562, 130)),
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
      Indicator(widget.type.name, Values.gold),
      Indicator(widget.type.name, Values.nectar, width: 310.d)
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
