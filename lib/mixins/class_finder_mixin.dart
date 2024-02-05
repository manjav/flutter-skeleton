import 'package:flutter/material.dart';

import '../app_export.dart';

mixin ClassFinderMixin {
  AccountProvider getAccountProvider(BuildContext context) =>
      serviceLocator<AccountProvider>();
}

mixin ClassFinderWidgetMixin<S extends StatefulWidget> on State<S> {
  AccountProvider get accountProvider => serviceLocator<AccountProvider>();

  Future<dynamic> rpc(RpcId id, {Map? params}) async {
    return await serviceLocator<HttpConnection>()
        .tryRpc(context, id, params: params);
  }
}
