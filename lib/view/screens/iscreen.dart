import 'package:flutter/material.dart';

import '../../data/core/account.dart';
import '../../services/deviceinfo.dart';
import '../../utils/assets.dart';
import '../../utils/ilogger.dart';
import '../../view/widgets.dart';
import '../../view/widgets/indicator.dart';
import '../overlays/ioverlay.dart';
import '../route_provider.dart';

class AbstractScreen extends StatefulWidget {
  final Routes type;
  final Map<String, dynamic> args;
  final String? sfx;
  AbstractScreen(
    this.type, {
    required this.args,
    Key? key,
    this.sfx,
  }) : super(key: key ??= Key(type.name));
  @override
  createState() => AbstractScreenState();
}

class AbstractScreenState<T extends AbstractScreen> extends State<T>
    with ILogger, TickerProviderStateMixin {
  List<Widget> stepChildren = <Widget>[];

  @override
  void initState() {
    // var sfx = widget.sfx ?? "message";
    // if (sfx.isNotEmpty) widget.services.get<Sounds>().play(sfx);
    // Analytics.setScreen(widget.mode.name);
    WidgetsBinding.instance.addPostFrameCallback(onRender);
    super.initState();
  }

  @protected
  void onRender(Duration timeStamp) {}

  @override
  Widget build(BuildContext context) {
    var appBarElements = <Widget>[];
    appBarElements.addAll(appBarElementsLeft());
    appBarElements.add(const Expanded(child: SizedBox()));
    appBarElements.addAll(appBarElementsRight());
    return SafeArea(
        child: Scaffold(
      body: Stack(children: [
        Positioned(
            top: 0, right: 0, bottom: 0, left: 0, child: contentFactory()),
        Positioned(
            top: 32.d,
            left: 54.d,
            right: 32.d,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: appBarElements)),
      ]),
    ));
  }

  List<Widget> appBarElementsLeft() {
    return [
      Widgets.button(
          // width: 132.d,
          height: 117.d,
          padding: EdgeInsets.all(22.d),
          child: Asset.load<Image>("ui_arrow_back"),
          onPressed: () => Navigator.pop(context))
    ];
  }

  List<Widget> appBarElementsRight() {
    return [
      Indicator(widget.type.name, AccountField.gold),
      Indicator(widget.type.name, AccountField.nectar, width: 300.d)
    ];
  }

  Widget contentFactory() => const SizedBox();

  toast(String message) =>
      Overlays.insert(context, OverlayType.toast, args: message);
}
