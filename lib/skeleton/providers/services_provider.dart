import 'package:flutter/material.dart';

import '../data/data.dart';
import '../services/services.dart';

enum ServiceStatus {
  none,
  initialize,
  complete,
  changeTab,
  punch,
  error,
}

class ServiceState {
  final dynamic data;
  final ServiceStatus status;
  final SkeletonException? exception;

  ServiceState(this.status, {this.data, this.exception});
}

class ServicesProvider extends ChangeNotifier {

  ServiceState state = ServiceState(ServiceStatus.none);

  final Set<IService> _services = {};

  T get<T>() => _services.firstWhere((service) => service is T) as T;

  void addService(IService service) {
    try {
      _services.add(service);
    } catch (x) {
      throw SkeletonException(400, "cannot add service");
    }
  }

  void changeState(ServiceStatus state,
      {SkeletonException? exception, dynamic data}) {
    this.state = ServiceState(state, data: data, exception: exception);
    notifyListeners();
  }
}
