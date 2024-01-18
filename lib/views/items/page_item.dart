import 'package:flutter/material.dart';

import '../../app_export.dart';

class AbstractPageItem extends StatefulWidget {
  final String name;
  const AbstractPageItem(this.name, {super.key});

  @override
  State<AbstractPageItem> createState() => AbstractPageItemState();
}

class AbstractPageItemState<T extends AbstractPageItem> extends State<T>
    with ILogger, ServiceFinderWidgetMixin, ClassFinderWidgetMixin {
  @override
  Widget build(BuildContext context) {
    return Center(child: SkinnedText("coming_soon".l(), style: TStyles.large));
  }

  void toast(String message) =>
      Overlays.insert(context, ToastOverlay(message));
}
