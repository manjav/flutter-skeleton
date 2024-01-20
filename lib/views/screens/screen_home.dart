import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app_export.dart';
import '../../main.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  var controller = Get.put(LoadingController());

  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.addListener(() {
      if (services.state.status == ServiceStatus.initialize) {
        setState(() {});
      }
    });
  }

  @override
  Widget appBarFactory(double paddingTop) {
    if (services.state.status.index < ServiceStatus.initialize.index) {
      return const SizedBox();
    }
    return super.appBarFactory(paddingTop);
  }

  @override
  Widget contentFactory() {
    if (services.state.status.index < ServiceStatus.initialize.index) {
      return const SizedBox();
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          if (Platform.isAndroid) {
            var result = await services
                .get<RouteService>()
                .to(Routes.popupMessage, args: {
              "title": "quit_title".l(),
              "message": "quit_message".l(),
              "isConfirm": () {}
            });
            if (result != null) {
              SystemNavigator.pop();
            }
          }
        }
      },
      child: Center(
          child: SkinnedButton(
        label: "Reload",
        width: 322.d,
        height: 200.d,
        onPressed: () => MyApp.restartApp(context),
      )),
    );
  }
}
