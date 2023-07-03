import 'package:flutter/material.dart';

import '../../data/core/account.dart';
import '../../services/deviceinfo.dart';
import '../../utils/assets.dart';
import '../../utils/ilogger.dart';
import '../../view/screens/home_screen.dart';
import '../../view/widgets.dart';
import '../../view/widgets/indicator.dart';
import 'loading_screen.dart';

class AbstractScreen extends StatefulWidget {
  final Screens type;
  final String? sfx;
  AbstractScreen(
    this.type, {
    Key? key,
    this.sfx,
  }) : super(key: key ??= Key(type.name));
  @override
  createState() => AbstractScreenState();
}

class AbstractScreenState<T extends AbstractScreen> extends State<T>
    with ILogger {
  List<Widget> stepChildren = <Widget>[];

  @override
  void initState() {
    // var sfx = widget.sfx ?? "message";
    // if (sfx.isNotEmpty) widget.services.get<Sounds>().play(sfx);
    // Analytics.setScreen(widget.mode.name);
    WidgetsBinding.instance.addPostFrameCallback(onRender);
    super.initState();
  }

  @protected
  void onRender(Duration timeStamp) {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(children: [
        Positioned(
            top: 16.d,
            left: 12.d,
            right: 12.d,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: appBarElements())),
        Positioned(
            top: 0, right: 0, bottom: 0, left: 0, child: contentFactory()),
      ]),
    ));
  }

  List<Widget> appBarElements() {
    return [
      SizedBox(width: 234.d),
      Indicator(widget.type.name, AccountVar.gold),
      SizedBox(width: 16.d),
      Indicator(widget.type.name, AccountVar.nectar, width: 260.d),
      Widgets.button(
          padding: EdgeInsets.all(32.d),
          child: Asset.load<Image>('ui_settings'),
          onPressed: () => Navigator.of(context).pop()),
    ];
  }

  Widget contentFactory() => const SizedBox();
}

enum Screens {
  none,
  home,
  loading,
  profile,
  settings,
  shop,
}

extension ScreenTools on Screens {
  static AbstractScreen getScreen(String routeName, {List<Object>? args}) {
    return switch (routeName) {
      "/home" => HomeScreen(),
      _ => LoadingScreen(),
    };
  }

  String get routeName => "/$name";
}