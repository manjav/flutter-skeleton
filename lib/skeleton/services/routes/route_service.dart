import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service.dart';

class RouteService extends IService {
  @override
  initialize({List<Object>? args}) {}

  String get currentRoute => Get.currentRoute;

  Future<dynamic> to(String route, {dynamic args}) async {
    return Get.toNamed(
      route,
      arguments: args,
    );
  }

  void popUntil(RoutePredicate predicate) async {
    Get.until(predicate);
  }

  void back({dynamic result}) {
    Get.back(result: result);
  }
}
