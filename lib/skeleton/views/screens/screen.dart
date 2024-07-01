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
    this.closable = true,
  }) : super(key: key ??= Key(route));

  Map<String, dynamic> get args => Get.arguments ?? {};

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
    var speaker = serviceLocator<Speaker>();
    return [
      Widgets.button(context,
          height: 56.d,
          padding: EdgeInsets.all(16.d),
          child: Asset.load<Image>(
              "ui_arrow_${Localization.isRTL ? "back" : "forward"}"),
          onPressed: () => Navigator.pop(context)),
      Widgets.button(
        context,
        height: 56.d,
        padding: EdgeInsets.all(16.d),
        child: Text(speaker.defaultNarrator.name),
        onPressed: () {
          speaker.defaultNarrator = Narrator.values[
              (speaker.defaultNarrator.index + 1) % Narrator.values.length];
          setState(() {});
        },
      ),
    ];
  }

  List<Widget> appBarElementsRight() => [];

  Widget contentFactory(double paddingTop) => const SizedBox();

  void toast(String message) => Overlays.insert(context, ToastOverlay(message));
}
