import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../view/popups/ipopup.dart';
import '../../view/tab_provider.dart';

class TabPagePopup extends AbstractPopup {
  const TabPagePopup(super.type, {super.key, required super.args});

  @override
  createState() => _TabPagePopupState();
}

class _TabPagePopupState extends AbstractPopupState<AbstractPopup>
    with TabProviderMixin {
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
          TabData("Nectar", "ui_nectar"),
          TabData("Pluus", "ui_plus"),
        ]));
  }

  @override
  void onTapChange() {
    log('$selectedTabIndex');
  }
}
