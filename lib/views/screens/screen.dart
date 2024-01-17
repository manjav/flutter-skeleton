import 'package:flutter/material.dart';

import '../../app_export.dart';

class AbstractScreen extends StatefulWidget {
  //todo: check routes here
  final String route;
  final Map<String, dynamic> args;
  final String? sfx;
  final bool closable;

  AbstractScreen(
    this.route, {
    required this.args,
    Key? key,
    this.sfx,
    this.closable = true,
  }) : super(key: key ??= Key(route));

  @override
  createState() => AbstractScreenState();
}

class AbstractScreenState<T extends AbstractScreen> extends State<T>
    with ILogger, TickerProviderStateMixin, ServiceFinderWidgetMixin {
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
    var paddingTop = MediaQuery.of(context).viewPadding.top;
    if (paddingTop <= 0) {
      paddingTop = 24.d;
    }
    return Scaffold(
      body: PopScope(
        canPop: widget.closable,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              left: 0,
              child: contentFactory(),
            ),
            PositionedDirectional(
              top: paddingTop,
              start: 24.d,
              end: 24.d,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: appBarElements),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> appBarElementsLeft() {
    return [
      Widgets.button(context,
          height: 117.d,
          padding: EdgeInsets.all(22.d),
          child: Asset.load<Image>(
              "ui_arrow_${Localization.isRTL ? "forward" : "back"}"),
          onPressed: () => Navigator.pop(context))
    ];
  }

  List<Widget> appBarElementsRight() => [];

  Widget contentFactory() => const SizedBox();

  // void toast(String message) =>
  //     Overlays.insert(context, OverlayType.toast, args: message);
}
