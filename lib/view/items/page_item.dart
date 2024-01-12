import 'package:flutter/material.dart';

import '../../skeleton/mixins/logger.dart';
import '../../skeleton/mixins/service_finder_mixin.dart';
import '../../skeleton/services/localization.dart';
import '../../skeleton/services/theme.dart';
import '../../skeleton/views/overlays/overlay.dart';
import '../../skeleton/views/widgets/skinned_text.dart';

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
