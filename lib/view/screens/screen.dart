import 'package:flutter/material.dart';

import '../../data/core/infra.dart';
import '../../mixins/logger.dart';
import '../../mixins/service_provider.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../utils/assets.dart';
import '../../view/widgets.dart';
import '../../view/widgets/indicator.dart';
import '../overlays/overlay.dart';
import '../route_provider.dart';

class AbstractScreen extends StatefulWidget {
  final Routes type;
  final Map<String, dynamic> args;
  final String? sfx;
  final bool closable;
  AbstractScreen(
    this.type, {
    required this.args,
    Key? key,
    this.sfx,
    this.closable = true,
  }) : super(key: key ??= Key(type.name));
  @override
  createState() => AbstractScreenState();
}

class AbstractScreenState<T extends AbstractScreen> extends State<T>
    with ILogger, TickerProviderStateMixin, ServiceProviderMixin {
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
    return Scaffold(
      body: PopScope(
        onPopInvoked: (i) async => widget.closable,
        child: Stack(children: [
          Positioned(
              top: 0, right: 0, bottom: 0, left: 0, child: contentFactory()),
          PositionedDirectional(
              top: 60.d,
              start: 54.d,
              end: 32.d,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: appBarElements)),
        ]),
      ),
    );
  }

  List<Widget> appBarElementsLeft() {
    return [
      Widgets.button(
          height: 117.d,
          padding: EdgeInsets.all(22.d),
          child: Asset.load<Image>(
              "ui_arrow_${Localization.isRTL ? "forward" : "back"}"),
          onPressed: () => Navigator.pop(context))
    ];
  }

  List<Widget> appBarElementsRight() {
    return [
      Indicator(widget.type.name, Values.gold),
      Indicator(widget.type.name, Values.nectar, width: 300.d)
    ];
  }

  Widget contentFactory() => const SizedBox();

  void toast(String message) =>
      Overlays.insert(context, OverlayType.toast, args: message);
}
