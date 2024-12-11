import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_export.dart';

class AbstractScreen extends StatefulWidget {
  final String route;
  final String? sfx;
  final bool closable;

  AbstractScreen(
    this.route, {
    Key? key,
    this.sfx,
    this.closable = false,
  }) : super(key: key ??= Key(route));

  Map<String, dynamic> get args => Get.arguments ?? {};

  @override
  createState() => AbstractScreenState();
}

class AbstractScreenState<T extends AbstractScreen> extends State<T>
    with ILogger, TickerProviderStateMixin, ServiceFinderWidgetMixin, PopupsMixin {
  List<Widget> stepChildren = <Widget>[];
  Map<String, dynamic> trackerParams = {};
  @override
  void initState() {
    // var sfx = widget.sfx ?? "message";
    // if (sfx.isNotEmpty) widget.services.get<Sounds>().play(sfx);
    // serviceLocator<Trackers>()
    //     .setScreen(widget.route, parameters: trackerParams);
    WidgetsBinding.instance.addPostFrameCallback(onRender);
    super.initState();
  }

  @protected
  void onRender(Duration timeStamp) {}

  @override
  Widget build(BuildContext context) {
    var paddingTop = MediaQuery.of(context).viewPadding.top;
    if (paddingTop <= 0) {
      paddingTop = 24.d;
    }
    return Scaffold(
      body: PopScope(
        canPop: widget.closable,
        onPopInvokedWithResult: onPopInvoked,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              left: 0,
              child: contentFactory(paddingTop),
            ),
            appBarFactory(paddingTop),
          ],
        ),
      ),
    );
  }

  Widget appBarFactory(double paddingTop) {
    var appBarElements = <Widget>[];
    appBarElements.addAll(appBarElementsLeft());
    appBarElements.add(const Expanded(child: SizedBox()));
    appBarElements.addAll(appBarElementsRight());
    return Positioned(
      top: paddingTop,
      left: 8.d,
      right: 8.d,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: appBarElements),
    );
  }

  List<Widget> appBarElementsLeft() {
    return [
      Widgets.button(context,
          height: 56.d,
          padding: EdgeInsets.all(16.d),
          child: Asset.load<Image>("footer_prev"),
          onPressed: () => Navigator.pop(context)),
    ];
  }

  List<Widget> appBarElementsRight() => [];

  Widget contentFactory(double paddingTop) => const SizedBox();


  void onPopInvoked(bool didPop, dynamic result) {
    if (!didPop) Navigator.pop(context);
  }
}
