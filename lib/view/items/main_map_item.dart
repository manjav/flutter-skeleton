import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../utils/assets.dart';
import '../../view/items/page_item.dart';
import '../../view/map_elements/building.dart';
import '../../view/widgets/loaderwidget.dart';
import '../../view/widgets/skinnedtext.dart';
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
        color: const Color(0xffAA9A45),
        child:
            BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
          return Stack(children: [
          const LoaderWidget(AssetType.image, "map_main_bg",
              fit: BoxFit.fill, subFolder: "maps"),
            _building(BuildingType.cards, 167, 560),
            _building(BuildingType.tribe, 500, 500),
            _building(BuildingType.mine, 754, 699),
            _building(BuildingType.war, 45, 943),
            _building(BuildingType.battle, 400, 930),
            _building(BuildingType.shop, 773, 1040),
            _building(BuildingType.quest, 169, 1244),
            _building(BuildingType.message, 532, 1268),
        ],
      ),
    );
  }
}

Widget _building(BuildingType type, double x, double y) {
  return Positioned(left: x.d, top: y.d, child: Building(type));
}
// reward would get added soon or later
