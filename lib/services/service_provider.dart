import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/account_bloc.dart';
import '../blocs/services_bloc.dart';
import '../data/core/rpc.dart';
import '../services/connection/http_connection.dart';

mixin ServiceProvider {
  ServicesBloc getServices(BuildContext context) =>
      BlocProvider.of<ServicesBloc>(context);
  T getService<T>(BuildContext context) => getServices(context).get<T>();

  AccountBloc getAccountBloc(BuildContext context) =>
      BlocProvider.of<AccountBloc>(context);
}

mixin ServiceProviderMixin<S extends StatefulWidget> on State<S> {
  ServicesBloc get services => BlocProvider.of<ServicesBloc>(context);
  T getService<T>() => services.get<T>();

  AccountBloc get accountBloc => BlocProvider.of<AccountBloc>(context);

  Future<dynamic> rpc(RpcId id, {Map? params}) async {
    return await getService<HttpConnection>()
        .tryRpc(context, id, params: params);
  }
}
