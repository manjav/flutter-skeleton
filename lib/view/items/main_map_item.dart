import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/items/page_item.dart';
import '../../view/widgets/loaderwidget.dart';
import '../widgets.dart';

class MainMapItem extends AbstractPageItem {
  const MainMapItem({
    super.key,
  }) : super("battle");
  @override
  createState() => _MainMapItemState();
}

class _MainMapItemState extends AbstractPageItemState<AbstractPageItem> {
  @override
  Widget build(BuildContext context) {
    return Widgets.rect(
      color: TColors.green,
      child: Stack(
        children: [
          const LoaderWidget(AssetType.image, "map_main_bg",
              fit: BoxFit.fill, subFolder: "maps"),
          Container(
              padding: EdgeInsets.only(top: 60.d, left: 25.d, right: 25.d),
              child: Column(children: [
                SizedBox(height: 50.d),
            ]),
          ),
        ],
      ),
    );
  }
}
