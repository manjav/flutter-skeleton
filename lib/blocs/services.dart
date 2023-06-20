import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/ads/ads.dart';
import '../services/ads/ads_abstract.dart';
import '../services/connection/http_connection.dart';
import '../services/iservices.dart';
import '../services/games.dart';
import '../services/localization.dart';
import '../services/prefs.dart';
import '../services/sounds.dart';
import '../services/theme.dart';
import '../services/trackers/trackers.dart';
import '../services/deviceinfo.dart';
import 'account_bloc.dart';

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
  theme,
  trackers,
}

class ServicesEvent {}

//--------------------------------------------------------

abstract class ServicesState {
  ServicesState();
}

class ServicesInit extends ServicesState {
  ServicesInit();
}

class ServicesUpdate extends ServicesState {
  ServicesUpdate();
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
      IConnection => ServiceType.connection,
      DeviceInfo => ServiceType.device,
      Localization => ServiceType.localization,
      Prefs => ServiceType.prefs,
      Sounds => ServiceType.sounds,
      Trackers => ServiceType.trackers,
      Theme => ServiceType.theme,
      _ => ServiceType.none
    };
  }

  Services({required this.firebaseAnalytics}) : super(ServicesInit()) {
    _map[ServiceType.ads] = Ads();
    _map[ServiceType.games] = Games();
    _map[ServiceType.connection] = HttpConnection();
    _map[ServiceType.device] = DeviceInfo();
    _map[ServiceType.localization] = Localization();
    _map[ServiceType.prefs] = Prefs();
    _map[ServiceType.sounds] = Sounds();
    _map[ServiceType.theme] = MyTheme();
    _map[ServiceType.trackers] = Trackers(firebaseAnalytics);
  }

  initialize(BuildContext context) async {
    var q = MediaQuery.of(context);
    _map[ServiceType.device]!.initialize(args: [q.size, q.devicePixelRatio]);
    _map[ServiceType.theme]!.initialize();
    await _map[ServiceType.prefs]!.initialize();
    await _map[ServiceType.sounds]!.initialize();
    await _map[ServiceType.localization]!.initialize();
    await _map[ServiceType.trackers]!.initialize();

    var result = await get<IConnection>().initialize();
    if (context.mounted) {
      BlocProvider.of<AccountBloc>(context)
          .add(SetAccount(account: result.data));
    }

    _map[ServiceType.games]!.initialize();
    get<Ads>().initialize();
    (_map[ServiceType.ads]! as Ads).onUpdate = _onAdsServicesUpdate;
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
