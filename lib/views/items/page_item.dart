import 'package:flutter/material.dart';

import '../../app_export.dart';

class AbstractPageItem extends StatefulWidget {
  final String name;
  const AbstractPageItem(this.name, {super.key});

  @override
  State<AbstractPageItem> createState() => AbstractPageItemState();
}

class AbstractPageItemState<T extends AbstractPageItem> extends State<T>
    with
        ILogger,
        ServiceFinderWidgetMixin,
        ClassFinderWidgetMixin,
        AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    serviceLocator<TutorialManager>().onFinish.listen((data) {
      onTutorialFinish(data);
    });
    serviceLocator<TutorialManager>().onStepChange.listen((data) {
      onTutorialStep(data);
    });
    checkTutorial();
    super.initState();
  }

  checkTutorial() {
    serviceLocator<TutorialManager>().checkToturial(context, widget.name);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(child: SkinnedText("coming_soon".l(), style: TStyles.large));
  }

  bool get isTutorial =>
      serviceLocator.get<TutorialManager>().isTutorial(widget.name);

  void onTutorialFinish(dynamic data) {}
  void onTutorialStep(dynamic data) {}

  void toast(String message) => Overlays.insert(context, ToastOverlay(message));

  @override
  bool get wantKeepAlive => true;
}
