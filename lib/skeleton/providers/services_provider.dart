import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/data.dart';
import '../../services/services.dart';
import '../data/data.dart';
import '../services/services.dart';
import '../../providers/providers.dart';

enum ServiceStatus {
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

class ServiceState {
  final dynamic data;
  final ServiceStatus status;
  final SkeletonException? exception;
  ServiceState(this.status, {this.data, this.exception});
}

class ServicesProvider extends ChangeNotifier {
  FirebaseAnalytics firebaseAnalytics;
  final Map<ServiceType, IService> _map = {};
  ServiceState state = ServiceState(ServiceStatus.none);

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

  ServicesProvider(this.firebaseAnalytics) : super() {
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
    _map[ServiceType.device]!.initialize();
    _map[ServiceType.themes]!.initialize();
    await _map[ServiceType.localization]!.initialize(args: [context]);
    await _map[ServiceType.trackers]!.initialize();

    try {
      // Load server data
      var data =
          await _map[ServiceType.connection]!.initialize() as LoadingData;
      get<Trackers>().sendUserData(data.account);
      if (context.mounted) {
        context.read<AccountProvider>().initialize(data.account);
        context.read<ServicesProvider>().changeState(ServiceStatus.initialize);

        // Initialize notifications ...
        _map[ServiceType.notifications]!.initialize(args: [data.account]);
      }

      // Initialize socket
      if (context.mounted) {
        _map[ServiceType.socket]!.initialize(
            args: [data.account, context.read<OpponentsProvider>()]);
      }
    } on SkeletonException catch (e) {
      if (context.mounted) {
        changeState(ServiceStatus.error, exception: e);
      }
    }

    _map[ServiceType.games]!.initialize();

    var ads = get<Ads>();
    ads.initialize();
    ads.onUpdate = _onAdsServicesUpdate;

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

  void changeState(ServiceStatus state,
      {SkeletonException? exception, dynamic data}) {
    this.state = ServiceState(state, data: data, exception: exception);
    notifyListeners();
  }
}
