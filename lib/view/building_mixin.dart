import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/deviceinfo.dart';
import '../../utils/utils.dart';
import '../../view/widgets.dart';
import '../blocs/account_bloc.dart';
import '../blocs/services_bloc.dart';
import '../data/core/account.dart';
import '../data/core/building.dart';
import '../data/core/rpc.dart';
import '../services/connection/http_connection.dart';
import '../services/localization.dart';
import '../services/theme.dart';
import '../utils/assets.dart';
import 'map_elements/building_widget.dart';
import 'overlays/ioverlay.dart';
import 'popups/ipopup.dart';
import 'widgets/skinnedtext.dart';

@optionalTypeArgs
mixin BuildingPopupMixin<T extends AbstractPopup> on State<T> {
  late Building building;

  @override
  void initState() {
    building = widget.args['building'];
    super.initState();
  }

  String titleBuilder() => "building_${building.type.name}_t".l();
  String descriptionBuilder() => "building_${building.type.name}_d".l();
  getBuildingIcon() {
    return SizedBox(width: 360.d, child: BuildingWidget(building));
  }

  upgtadeButton(Account account, Building building) {
    var bgCenterSlice = ImageCenterSliceData(42, 42);
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Widgets.skinnedButton(
            height: 160.d,
            isEnable: building.level < building.maxLevel,
            color: ButtonColor.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 8.d),
                SkinnedText("upgrade_l".l(),
                    style: TStyles.large.copyWith(height: 3.d)),
                SizedBox(width: 24.d),
                Widgets.rect(
                  padding:
                      EdgeInsets.symmetric(vertical: 6.d, horizontal: 12.d),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          centerSlice: bgCenterSlice.centerSlice,
                          image: Asset.load<Image>('ui_frame_inside',
                                  centerSlice: bgCenterSlice)
                              .image)),
                  child: Row(children: [
                    Asset.load<Image>("icon_gold", height: 76.d),
                    SkinnedText(building.upgradeCost.compact(),
                        style: TStyles.large),
                  ]),
                )
              ],
            ),
            onPressed: () => _upgrade(account, building),
            onDisablePressed: () => Overlays.insert(context, OverlayType.toast,
                args: "max_level".l(["building_${building.type.name}_t".l()])),
          )
        ]);
  }

  _upgrade(Account account, Building building) async {
    var params = {RpcParams.type.name: building.type.id};
    var tribe = account.getBuilding(Buildings.tribe);
    if (tribe != null) {
      params[RpcParams.tribe_id.name] = tribe.get<int>(BuildingField.id);
    }
    try {
      var data = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.upgrade, params: params);
      if (!mounted) return;
      var accountBloc = BlocProvider.of<AccountBloc>(context);
      accountBloc.account!.update(data);
      building.map["level"] = data["level"];
      accountBloc.add(SetAccount(account: accountBloc.account!));
    } finally {}
  }
}
