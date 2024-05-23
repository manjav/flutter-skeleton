import 'package:flutter/material.dart';

import '../app_export.dart';

mixin ClassFinderMixin {
  AccountProvider getAccountProvider(BuildContext context) =>
      serviceLocator<AccountProvider>();
}

mixin ClassFinderWidgetMixin<S extends StatefulWidget> on State<S> {
  AccountProvider get accountProvider => serviceLocator<AccountProvider>();

  Future<dynamic> rpc(RpcId id, {Map? params, bool showError = true}) async {
    return await serviceLocator<HttpConnection>()
        .tryRpc(context, id, params: params, showError: showError);
  }
}
