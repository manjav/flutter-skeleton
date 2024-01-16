import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/data.dart';
import '../providers/providers.dart';
import '../skeleton/providers/services_provider.dart';
import '../services/services.dart';

mixin ServiceFinderMixin {
  ServicesProvider getServices(BuildContext context) =>
      context.read<ServicesProvider>();
  T getService<T>(BuildContext context) => getServices(context).get<T>();

  AccountProvider getAccountProvider(BuildContext context) =>
      context.read<AccountProvider>();
}

mixin ServiceFinderWidgetMixin<S extends StatefulWidget> on State<S> {
  ServicesProvider get services => context.read<ServicesProvider>();
  T getService<T>() => services.get<T>();

  AccountProvider get accountProvider => context.read<AccountProvider>();

  Future<dynamic> rpc(RpcId id, {Map? params}) async {
    return await getService<HttpConnection>()
        .tryRpc(context, id, params: params);
  }
}
