import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../app_export.dart';

class BuildingBalloon extends StatefulWidget {
  final Building building;

  const BuildingBalloon(this.building, {super.key});

  @override
  State<BuildingBalloon> createState() => _BuildingBalloonState();
}

class _BuildingBalloonState extends State<BuildingBalloon>
    with ServiceFinderWidgetMixin, ClassFinderWidgetMixin, MineMixin {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 10)),
        builder: (ctx, snapshot) {
          var account = accountProvider.account;
          if (!isCollectable(account)) {
            return const SizedBox();
          }
          return Widgets.button(context,
              radius: 40.d,
              color: TColors.primary,
              padding: EdgeInsets.all(12.d),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Asset.load<Image>("icon_gold", width: 72.d),
                Text(collectableGold(account).compact())
              ]),
              onPressed: () => _onPressed(account));
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
        accountProvider.update(context, result);
        serviceLocator<Notifications>()
            .schedule(accountProvider.account.getSchedules());
      }
    } finally {
      setState(() {
        
      });
    }
  }
}
