import 'package:flutter/material.dart';

import '../data/responses.dart';

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

  void changeState(ServiceStatus state,
      {SkeletonException? exception, dynamic data}) {
    this.state = ServiceState(state, data: data, exception: exception);
    notifyListeners();
  }
}
