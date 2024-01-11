import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../data/core/rpc.dart';
import '../../mixins/service_provider.dart';
import '../../services/device_info.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class BuildingBalloon extends StatefulWidget {
  final Building building;

  const BuildingBalloon(this.building, {super.key});

  @override
  State<BuildingBalloon> createState() => _BuildingBalloonState();
}

class _BuildingBalloonState extends State<BuildingBalloon>
    with ServiceProviderMixin {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      if (!isCollectable(state.account)) {
        return const SizedBox();
      }
      return Widgets.button(context,
          radius: 40.d,
          color: TColors.primary,
          padding: EdgeInsets.all(12.d),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Asset.load<Image>("icon_gold", width: 72.d),
            Text(collectableGold(state.account).compact())
          ]),
          onPressed: () => _onPressed(state.account));
    });
  }

  Future<void> _onPressed(Account account) async {
    if (!isCollectable(account)) {
      return;
    }
    var params = {RpcParams.client.name: Platform.operatingSystem};
    try {
      var result = await rpc(RpcId.collectGold, params: params);
      if (result is List) return;
      if (mounted) {
        account.update(context, result);
        accountBloc.add(SetAccount(account: account));
      }
    } finally {}
  }

  int collectableGold(Account account) {
    var goldPerSec = widget.building.getCardsBenefit(account) / 3600;
    return ((account.getTime() - account.last_gold_collect_at) * goldPerSec)
        .clamp(0, widget.building.benefit)
        .floor();
  }

  bool isCollectable(Account account) =>
      account.getTime() >= account.gold_collection_allowed_at;
}
