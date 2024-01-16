import 'package:flutter/material.dart';

import 'views.dart';

enum Routes {
  none,
  home,
  loading,

  popupNone,
  popupMessage,
}

extension RoutesExtension on Routes {
  static Widget getWidget(String routeName, {Map<String, dynamic>? args}) {
    return switch (routeName) {
      "/home" => HomeScreen(),
      "/popupMessage" => MessagePopup(args: args ?? {}),
      _ => LoadingScreen(),
    };
  }

  String get routeName => "/$name";

  static bool getOpaque(String routeName) {
    return switch (routeName) {
      "/popupMessage" => false,
      _ => true,
    };
  }

  dynamic navigate(BuildContext context, {Map<String, dynamic>? args}) async {
    return await Navigator.pushNamed(context, routeName, arguments: args);
  }

  dynamic replace(BuildContext context, {Map<String, dynamic>? args}) async {
    return await Navigator.pushReplacementNamed(context, routeName,
        arguments: args);
  }
}

class MaterialTransparentRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  final bool isOpaque;
  MaterialTransparentRoute({
    required this.builder,
    required RouteSettings super.settings,
    this.isOpaque = true,
    this.maintainState = true,
    super.fullscreenDialog = true,
  });

  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  bool get opaque => isOpaque;

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}
