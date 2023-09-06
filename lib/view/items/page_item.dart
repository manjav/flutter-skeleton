import 'package:flutter/material.dart';

import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/ilogger.dart';
import '../../view/widgets/skinnedtext.dart';

class AbstractPageItem extends StatefulWidget {
  final String name;
  const AbstractPageItem(this.name, {super.key});

  @override
  State<AbstractPageItem> createState() => AbstractPageItemState();
}

class AbstractPageItemState<T extends AbstractPageItem> extends State<T>
    with ILogger {
  @override
  Widget build(BuildContext context) {
    return Center(child: SkinnedText("coming_soon".l(), style: TStyles.large));
  }
}
