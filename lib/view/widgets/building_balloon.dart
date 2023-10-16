import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../data/core/rpc.dart';
import '../../services/deviceinfo.dart';
import '../../services/service_provider.dart';
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
      var mine = widget.building as Mine;
      if (!mine.isCollectable(state.account)) {
        return const SizedBox();
      }
      return Widgets.button(
          radius: 40.d,
          color: TColors.primary,
          padding: EdgeInsets.all(12.d),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Asset.load<Image>("icon_gold", width: 72.d),
            Text(mine.collectableGold(state.account).compact())
          ]),
          onPressed: () => _onPressed(state.account, mine));
    });
  }

  Future<void> _onPressed(Account account, Mine mine) async {
    if (!mine.isCollectable(account)) {
      return;
    }
    var params = {RpcParams.client.name: Platform.operatingSystem};
    try {
      var result = await rpc(RpcId.collectGold, params: params);
      if (result is List) return;
      account.update(result);
      if (mounted) {
        BlocProvider.of<AccountBloc>(context).add(SetAccount(account: account));
      }
    } finally {}
  }
}
