import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service.dart';
import 'skeleton_page_model.dart';

class RouteService extends IService {
  @override
  initialize({List<Object>? args}) {}

  List<SkeletonPageModel> pages = [];

  void setPages(List<SkeletonPageModel> pages) {
    pages.clear();
    pages.addAll(pages);
  }

  String get currentRoute => Get.currentRoute;

  Future<dynamic> to(String route, {dynamic args}) async {
    var page = pages.firstWhereOrNull((item) => item.route == route);
    if (page == null) throw Exception("route not found");
    if (page.type == RouteType.page || page.type == RouteType.popup) {
      return Get.to(
        () => page.page,
        arguments: args,
        opaque: page.isOpaque,
        routeName: page.route,
        transition: Transition.fadeIn,
      );
    }
  }

  Future<dynamic> replace(String route, {dynamic args}) async {
    var page = pages.firstWhereOrNull((item) => item.route == route);
    if (page == null) throw Exception("route not found");

    if (page.type == RouteType.page || page.type == RouteType.popup) {
      return Get.off(
        () => page.page,
        arguments: args,
        routeName: page.route,
        opaque: page.isOpaque,
      );
    }
  }

  void popUntil(RoutePredicate predicate) async {
    Get.until(predicate);
  }
}
