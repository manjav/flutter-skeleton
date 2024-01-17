import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_export.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.HOME_SCREEN, args: {});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.changeState(ServiceStatus.complete);
    getService<Sounds>().playMusic();
  }

  @override
  Widget contentFactory() {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          if (Platform.isAndroid) {
            var result = await services.get<RouteService>().to(Routes.POPUP_MESSAGE,
                args: {
                  "title": "quit_title".l(),
                  "message": "quit_message".l(),
                  "isConfirm": () {}
                });
            // var result = await Routes.popupMessage.navigate(
            //   context,
            //   args: {
            //     "title": "quit_title".l(),
            //     "message": "quit_message".l(),
            //     "isConfirm": () {}
            //   },
            // );
            if (result != null) {
              SystemNavigator.pop();
            }
          }
        }
      },
      child: const SizedBox(),
    );
  }
}
