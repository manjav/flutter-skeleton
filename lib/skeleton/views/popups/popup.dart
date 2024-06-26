import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_export.dart';

class AbstractPopup extends StatefulWidget {
  final String route;

  const AbstractPopup(
    this.route, {
    super.key,
  });

  Map<String, dynamic> get args => Get.arguments;
  String get name => route.replaceAll("/", "");

  @override
  createState() => AbstractPopupState();
}

class AbstractPopupState<T extends AbstractPopup> extends State<T>
    with ILogger, ServiceFinderWidgetMixin {
  Alignment alignment = Alignment.center;
  bool barrierDismissible = true, canPop = true;

  @override
  void initState() {
    serviceLocator<Sounds>().play("popup");
    canPop = widget.args["canPop"] ?? true;
    barrierDismissible = widget.args["barrierDismissible"] ?? true;
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
            Widgets.touchable(context,
                onTap:
                    barrierDismissible ? () => Navigator.pop(context) : null),
            Align(alignment: alignment, child: outerChromeFactory()),
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
  String titleBuilder() => widget.name.toLowerCase().l();
  EdgeInsets get chromeMargin => EdgeInsets.fromLTRB(24.d, 100.d, 24.d, 0);
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(48.d, 176.d, 48.d, 92.d);

  Widget titleTextFactory() {
    return Widgets.rect(
        width: 562.d,
        height: 130.d,
        padding: EdgeInsets.only(bottom: 14.d),
        decoration: Widgets.imageDecorator(
            "popup_title", ImageCenterSliceData(562, 130)),
        child: Center(child: SkinnedText(titleBuilder(), style: TStyles.large)));
  }

  Widget closeButtonFactory() {
    return Widgets.button(context,
        alignment: Alignment.center,
        width: 160.d,
        height: 160.d,
        onPressed: () => Navigator.pop(context),
        child: Asset.load<Image>('popup_close', height: 38.d));
  }

  List<Widget> appBarElements() => [];

  Widget innerChromeFactory() => const SizedBox();

  Widget outerChromeFactory() {
    return Widgets.rect(
      margin: chromeMargin,
      padding: EdgeInsets.symmetric(horizontal: 24.d),
      decoration: chromeSkinBuilder,
      child:
          Stack(alignment: Alignment.topCenter, fit: StackFit.loose, children: [
        innerChromeFactory(),
        titleTextFactory(),
        Padding(padding: contentPadding, child: contentFactory()),
        Positioned(top: 60.d, right: -12.d, child: closeButtonFactory()),
      ]),
    );
  }

  BoxDecoration get chromeSkinBuilder =>
      Widgets.imageDecorator("popup_chrome", ImageCenterSliceData(410, 460));

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

  void toast(String message) => Overlays.insert(context, ToastOverlay(message));
}
