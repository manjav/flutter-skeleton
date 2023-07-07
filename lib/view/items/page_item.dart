import 'package:flutter/material.dart';

import '../../utils/ilogger.dart';

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
    return Center(child: Text(widget.name));
  }
}
