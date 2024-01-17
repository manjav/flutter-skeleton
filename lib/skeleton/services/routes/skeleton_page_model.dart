import 'package:flutter/material.dart';

enum RouteType{
  page,
  popup,
}

class SkeletonPageModel {
  final String route;
  final Widget page;
  final bool isOpaque;
  final RouteType type;

  SkeletonPageModel({
    required this.route,
    required this.page,
    this.type = RouteType.page,
    this.isOpaque = false,
  });
}