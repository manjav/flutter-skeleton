import 'package:flutter/material.dart';

import '../../mixins/logger.dart';
import '../../mixins/service_finder_mixin.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../widgets/skinned_text.dart';
import '../overlays/overlay.dart';

class AbstractPageItem extends StatefulWidget {
  final String name;
  const AbstractPageItem(this.name, {super.key});

  @override
  State<AbstractPageItem> createState() => AbstractPageItemState();
}

class AbstractPageItemState<T extends AbstractPageItem> extends State<T>
    with ILogger, ServiceFinderWidgetMixin {
  @override
  Widget build(BuildContext context) {
    return Center(child: SkinnedText("coming_soon".l(), style: TStyles.large));
  }

  void toast(String message) =>
      Overlays.insert(context, OverlayType.toast, args: message);
}
