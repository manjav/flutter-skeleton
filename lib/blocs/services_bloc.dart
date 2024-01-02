import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/core/result.dart';
import '../data/core/rpc_data.dart';
import '../services/ads/ads.dart';
import '../services/ads/ads_abstract.dart';
import '../services/connection/http_connection.dart';
import '../services/connection/noob_socket.dart';
import '../services/device_info.dart';
import '../services/games.dart';
import '../services/inbox.dart';
import '../services/localization.dart';
import '../services/notifications.dart';
import '../services/prefs.dart';
import '../services/services.dart';
import '../services/sounds.dart';
import '../services/theme.dart';
import '../services/trackers/trackers.dart';
import 'account_bloc.dart';
import 'opponents_bloc.dart';

enum ServicesInitState {
  none,
  initialize,
  complete,
  changeTab,
  punch,
  error,
}

enum ServiceType {
  none,
  ads,
  games,
  connection,
  device,
  inbox,
  localization,
  notifications,
  sounds,
  settings,
  themes,
  trackers,
  socket,
}

class ServicesEvent {
  final ServicesInitState initState;
  final dynamic data;
  ServicesEvent(this.initState, this.data);
}

//--------------------------------------------------------

abstract class ServicesState {
  final ServicesInitState initState;
  final dynamic data;
  ServicesState(this.initState, this.data);
}

class ServicesInit extends ServicesState {
  ServicesInit(super.initState, super.exception);
}

class ServicesUpdate extends ServicesState {
  ServicesUpdate(super.initState, super.exception);
}

//--------------------------------------------------------

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  FirebaseAnalytics firebaseAnalytics;
  final Map<ServiceType, IService> _map = {};

  T get<T>() => _map[_getType(T)] as T;

  ServiceType _getType(Type type) {
    return switch (type) {
      const (Ads) => ServiceType.ads,
      const (Games) => ServiceType.games,
      const (HttpConnection) => ServiceType.connection,
      const (DeviceInfo) => ServiceType.device,
      const (Inbox) => ServiceType.inbox,
      const (Localization) => ServiceType.localization,
      const (Notifications) => ServiceType.notifications,
      const (Sounds) => ServiceType.sounds,
      const (Trackers) => ServiceType.trackers,
      const (Theme) => ServiceType.themes,
      const (NoobSocket) => ServiceType.socket,
      _ => ServiceType.none
    };
  }

  updateService(ServicesEvent event, Emitter<ServicesState> emit) {
    emit(ServicesUpdate(event.initState, event.data));
  }

  ServicesBloc({required this.firebaseAnalytics})
      : super(ServicesInit(ServicesInitState.none, null)) {
    on<ServicesEvent>(updateService);

    _map[ServiceType.ads] = Ads();
    _map[ServiceType.games] = Games();
    _map[ServiceType.connection] = HttpConnection();
    _map[ServiceType.device] = DeviceInfo();
    _map[ServiceType.inbox] = Inbox();
    _map[ServiceType.localization] = Localization();
    _map[ServiceType.notifications] = Notifications();
    _map[ServiceType.socket] = NoobSocket();
    _map[ServiceType.sounds] = Sounds();
    _map[ServiceType.themes] = Themes();
    _map[ServiceType.trackers] = Trackers(firebaseAnalytics);
  }

  initialize(BuildContext context) async {
    var q = MediaQuery.of(context);
    _map[ServiceType.device]!.initialize(args: [q.size, q.devicePixelRatio]);
    _map[ServiceType.themes]!.initialize();
    await _map[ServiceType.localization]!.initialize(args: [context]);
    await _map[ServiceType.trackers]!.initialize();

    try {
      // Load server data
      var data =
          await _map[ServiceType.connection]!.initialize() as LoadingData;
      get<Trackers>().sendUserData(data.account);
      if (context.mounted) {
        BlocProvider.of<AccountBloc>(context)
            .add(SetAccount(account: data.account));
        BlocProvider.of<ServicesBloc>(context)
            .add(ServicesEvent(ServicesInitState.initialize, null));

        // Initialize notifications ...
        _map[ServiceType.notifications]!.initialize(args: [data.account]);
      }

      // Initialize socket
      if (context.mounted) {
        var opponents = BlocProvider.of<OpponentsBloc>(context);
        _map[ServiceType.socket]!.initialize(args: [data.account, opponents]);
      }
    } on RpcException catch (e) {
      if (context.mounted) {
        BlocProvider.of<ServicesBloc>(context)
            .add(ServicesEvent(ServicesInitState.error, e));
      }
    }

    _map[ServiceType.games]!.initialize();
    get<Ads>().initialize();
    (_map[ServiceType.ads]! as Ads).onUpdate = _onAdsServicesUpdate;

    _map[ServiceType.sounds]!.initialize();
  }

  _onAdsServicesUpdate(Placement? placement) {
    if (Pref.music.getBool()) {
      if (placement!.state == AdState.show) {
        get<Sounds>().stopAll();
      } else if (placement.state == AdState.closed ||
          placement.state == AdState.failedShow) {
        get<Sounds>().playMusic();
      }
    }
  }
}
