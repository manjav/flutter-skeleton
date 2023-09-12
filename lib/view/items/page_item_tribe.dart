import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../view/popups/tribe_search_popup.dart';
import '../widgets.dart';
import 'page_item.dart';

class TribePageItem extends AbstractPageItem {
  const TribePageItem({super.key}) : super("battle");
  @override
  createState() => _TribePageItemState();
}

class _TribePageItemState extends AbstractPageItemState<TribePageItem> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: TribeSearchPopup()),
      Widgets.skinnedButton(label: "tribe_new".l(), width: 380.d),
      SizedBox(height: 200.d),
    ]);
  }
}
