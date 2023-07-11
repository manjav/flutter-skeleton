import 'package:flutter/material.dart';

import '../../data/core/rpc_data.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/ilogger.dart';
import '../../view/widgets/indicator.dart';
import '../../view/widgets/skinnedtext.dart';
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
    with ILogger {
  @override
  Widget build(BuildContext context) {
    var chromeCenterSlice = ImageCenterSliceDate(410, 460);
    return SafeArea(
        child: Scaffold(
      body: Stack(children: [
        Widgets.touchable(onTap: () => Navigator.pop(context)),
        Align(
            child: Widgets.rect(
          margin: EdgeInsets.symmetric(horizontal: 24.d),
          padding: EdgeInsets.symmetric(horizontal: 36.d),
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  centerSlice: chromeCenterSlice.centerSlice,
                  image: Asset.load<Image>(
                    'popup_chrome',
                    centerSlice: chromeCenterSlice,
                  ).image)),
          child: Stack(
              alignment: Alignment.topCenter,
              fit: StackFit.loose,
              children: [
                innerChromeFactory(),
                titleTextFactory(),
                Padding(
                    padding: EdgeInsets.fromLTRB(48.d, 176.d, 48.d, 64.d),
                    child: contentFactory()),
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

  titleBuilder() => 'popup_${widget.type.name.toLowerCase()}'.l();

  titleTextFactory() {
    var centerSlice = ImageCenterSliceDate(562, 130);
    return Widgets.rect(
        width: 562.d,
        height: 130.d,
        padding: EdgeInsets.only(top: 12.d),
        decoration: BoxDecoration(
            image: DecorationImage(
                centerSlice: centerSlice.centerSlice,
                image: Asset.load<Image>(
                  'popup_title',
                  centerSlice: centerSlice,
                ).image)),
        child: SkinnedText(titleBuilder(), style: TStyles.large));
  }

  closeButtonFactory() {
    return Widgets.button(
        width: 160.d,
        height: 160.d,
        onPressed: () => Navigator.pop(context),
        child: Asset.load<Image>('popup_close', height: 38.d));
  }

  List<Widget> appBarElements() {
    return [
      Indicator(widget.type.name, AccountField.gold),
      SizedBox(width: 16.d),
      Indicator(widget.type.name, AccountField.nectar, width: 260.d),
    ];
  }

  innerChromeFactory() {
    return const SizedBox();
  }

  contentFactory() => Widgets.rect(
      height: 480.d, width: 880.d, color: TColors.green.withAlpha(133));

  actionsFactory() => <Widget>[];
}
