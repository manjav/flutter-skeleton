import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_export.dart';

mixin ClassFinderMixin {
  AccountProvider getAccountProvider(BuildContext context) =>
      context.read<AccountProvider>();
}

mixin ClassFinderWidgetMixin<S extends StatefulWidget> on State<S> {
  AccountProvider get accountProvider => context.read<AccountProvider>();

  Future<dynamic> rpc(RpcId id, {Map? params}) async {
    return await context
        .read<ServicesProvider>()
        .get<HttpConnection>()
        .tryRpc(context, id, params: params);
  }
}
