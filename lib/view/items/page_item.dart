import 'package:flutter/material.dart';

import '../../services/localization.dart';
import '../../services/service_provider.dart';
import '../../services/theme.dart';
import '../../utils/ilogger.dart';
import '../../view/widgets/skinnedtext.dart';
import '../overlays/ioverlay.dart';

class AbstractPageItem extends StatefulWidget {
  final String name;
  const AbstractPageItem(this.name, {super.key});

  @override
  State<AbstractPageItem> createState() => AbstractPageItemState();
}

class AbstractPageItemState<T extends AbstractPageItem> extends State<T>
    with ILogger, ServiceProviderMixin {
  @override
  Widget build(BuildContext context) {
    return Center(child: SkinnedText("coming_soon".l(), style: TStyles.large));
  }

  void toast(String message) =>
      Overlays.insert(context, OverlayType.toast, args: message);
}
