import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../view/popups/ipopup.dart';
import '../../view/tab_provider.dart';
import '../route_provider.dart';

class LeaguePopup extends AbstractPopup {
  const LeaguePopup({super.key, required super.args})
      : super(Routes.popupLeague);

  @override
  createState() => _LeaguePopupState();
}

class _LeaguePopupState extends AbstractPopupState<LeaguePopup>
    with TabProviderMixin {
  @override
  void initState() {
    selectedTabIndex = widget.args['selectedTabIndex'] ?? 0;
    contentPadding = EdgeInsets.fromLTRB(12.d, 176.d, 12.d, 64.d);
    super.initState();
  }

  @override
  contentFactory() {
    return SizedBox(
        width: 850.d,
        height: 850.d,
        child: tabsBuilder(data: [
          TabData("Gold", "icon_gold"),
          TabData("Nectar", "icon_nectar"),
          TabData("Pluus", "ui_plus"),
        ]));
  }

  @override
  void onTapChange() {
    log('$selectedTabIndex');
  }
}
