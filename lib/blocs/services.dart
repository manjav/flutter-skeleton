import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/core/rpc_data.dart';
import '../data/core/result.dart';
import '../services/ads/ads.dart';
import '../services/ads/ads_abstract.dart';
import '../services/connection/http_connection.dart';
import '../services/deviceinfo.dart';
import '../services/games.dart';
import '../services/iservices.dart';
import '../services/localization.dart';
import '../services/prefs.dart';
import '../services/sounds.dart';
import '../services/theme.dart';
import '../services/trackers/trackers.dart';
import 'account_bloc.dart';

enum ServicesInitState {
  none,
  initialize,
  complete,
  error,
}

enum ServiceType {
  none,
  ads,
  games,
  connection,
  device,
  localization,
  prefs,
  sounds,
  settings,
  themes,
  trackers,
}

class ServicesEvent {
  final ServicesInitState initState;
  final RpcException? exception;
  ServicesEvent(this.initState, this.exception);
}

//--------------------------------------------------------

abstract class ServicesState {
  final ServicesInitState initState;
  final RpcException? exception;
  ServicesState(this.initState, this.exception);
}

class ServicesInit extends ServicesState {
  ServicesInit(super.initState, super.exception);
}

class ServicesUpdate extends ServicesState {
  ServicesUpdate(super.initState, super.exception);
}

//--------------------------------------------------------

class Services extends Bloc<ServicesEvent, ServicesState> {
  FirebaseAnalytics firebaseAnalytics;
  final Map<ServiceType, IService> _map = {};

  T get<T>() => _map[_getType(T)] as T;

  ServiceType _getType(Type type) {
    return switch (type) {
      Ads => ServiceType.ads,
      Games => ServiceType.games,
      HttpConnection => ServiceType.connection,
      DeviceInfo => ServiceType.device,
      Localization => ServiceType.localization,
      Prefs => ServiceType.prefs,
      Sounds => ServiceType.sounds,
      Trackers => ServiceType.trackers,
      Theme => ServiceType.themes,
      _ => ServiceType.none
    };
  }

  updateService(ServicesEvent event, Emitter<ServicesState> emit) {
    emit(ServicesUpdate(event.initState, event.exception));
  }

  Services({required this.firebaseAnalytics})
      : super(ServicesInit(ServicesInitState.none, null)) {
    on<ServicesEvent>(updateService);

    _map[ServiceType.ads] = Ads();
    _map[ServiceType.games] = Games();
    _map[ServiceType.connection] = HttpConnection();
    _map[ServiceType.device] = DeviceInfo();
    _map[ServiceType.localization] = Localization();
    _map[ServiceType.prefs] = Prefs();
    _map[ServiceType.sounds] = Sounds();
    _map[ServiceType.themes] = Themes();
    _map[ServiceType.trackers] = Trackers(firebaseAnalytics);
  }

  initialize(BuildContext context) async {
    var q = MediaQuery.of(context);
    _map[ServiceType.device]!.initialize(args: [q.size, q.devicePixelRatio]);
    _map[ServiceType.themes]!.initialize();
    await _map[ServiceType.prefs]!.initialize();
    await _map[ServiceType.localization]!.initialize();
    await _map[ServiceType.trackers]!.initialize();

    try {
      var data =
          await _map[ServiceType.connection]!.initialize() as LoadingData;
      if (context.mounted) {
        BlocProvider.of<AccountBloc>(context)
            .add(SetAccount(account: data.account));
        BlocProvider.of<Services>(context)
            .add(ServicesEvent(ServicesInitState.initialize, null));
      }
    } on RpcException catch (e) {
      if (context.mounted) {
        BlocProvider.of<Services>(context)
            .add(ServicesEvent(ServicesInitState.error, e));
      }
    }

    _map[ServiceType.games]!.initialize();
    get<Ads>().initialize();
    (_map[ServiceType.ads]! as Ads).onUpdate = _onAdsServicesUpdate;

    _map[ServiceType.sounds]!.initialize();
  }

  _onAdsServicesUpdate(Placement? placement) {
    if (Prefs.getBool("settings_music")) {
      if (placement!.state == AdState.show) {
        get<Sounds>().stopAll();
      } else if (placement.state == AdState.closed ||
          placement.state == AdState.failedShow) {
        get<Sounds>().playMusic();
      }
    }
  }
}
