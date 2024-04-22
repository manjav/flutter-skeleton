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
    with
        ILogger,
        TickerProviderStateMixin,
        ServiceFinderWidgetMixin,
        ClassFinderWidgetMixin {
  List<Widget> stepChildren = <Widget>[];
  bool get isTutorial =>
      serviceLocator.get<TutorialManager>().isTutorial(widget.route);

  @override
  void initState() {
    // var sfx = widget.sfx ?? "message";
    // if (sfx.isNotEmpty) widget.services.get<Sounds>().play(sfx);
    // Analytics.setScreen(widget.mode.name);
    WidgetsBinding.instance.addPostFrameCallback(onRender);
    super.initState();
    serviceLocator<TutorialManager>().onFinish.listen((data) {
      onTutorialFinish(data);
    });
    serviceLocator<TutorialManager>().onStepChange.listen((data) {
      onTutorialStep(data);
    });
    checkTutorial();
  }

  checkTutorial() {
    serviceLocator<TutorialManager>().checkToturial(context, widget.route);
  }

  void onTutorialFinish(dynamic data) {}
  void onTutorialStep(dynamic data) {}

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
              child: contentFactory(),
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
    return PositionedDirectional(
      top: paddingTop,
      start: 24.d,
      end: 24.d,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: appBarElements),
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

  List<Widget> appBarElementsRight() {
    return [
      Indicator(widget.route, Values.gold),
      Indicator(widget.route, Values.nectar, width: 300.d)
    ];
  }

  Widget contentFactory() => const SizedBox();

  void toast(String message) => Overlays.insert(context, ToastOverlay(message));
}
