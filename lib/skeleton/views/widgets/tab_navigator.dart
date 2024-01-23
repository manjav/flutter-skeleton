import 'package:flutter/material.dart';

import '../../export.dart';

class TabNavigator extends StatefulWidget {
  final int tabsCount;
  final Widget? Function(int, double) itemBuilder;

  const TabNavigator({
    required this.tabsCount,
    required this.itemBuilder,
    super.key,
  });

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  final double _navbarHeight = 210.d;

  @override
  Widget build(BuildContext context) {
    var tabSize = DeviceInfo.size.width / widget.tabsCount;
    return SizedBox(
      height: _navbarHeight,
      child: ListView.builder(
          itemExtent: tabSize,
          itemCount: widget.tabsCount,
          reverse: Localization.isRTL,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => widget.itemBuilder(index, tabSize)),
    );
  }
}
