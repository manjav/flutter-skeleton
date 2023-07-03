import 'package:flutter/material.dart';
import '../../view/tab_provider.dart';

import '../../services/deviceinfo.dart';
import '../../view/popups/ipopup.dart';

class TabPagePopup extends AbstractPopup {
  const TabPagePopup(super.type, {super.key, required super.args});

  @override
  createState() => _TabPagePopupState();
}

class _TabPagePopupState extends AbstractPopupState<AbstractPopup>
    with TabProviderStateMixin {
  @override
  void initState() {
    selectedTabIndex = widget.args['selectedTabIndex'] ?? 0;
    super.initState();
  }

  @override
  contentFactory() {
    return SizedBox(
        width: 880.d,
        height: 880.d,
        child: tabsBuilder(data: [
          TabData("Gold", "ui_gold"),
          TabData("Nectar"),
        ]));
  }

  @override
  void onTapChange() {
    print(selectedTabIndex);
  }
}
