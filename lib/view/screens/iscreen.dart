import 'package:flutter/material.dart';

import '../../services/theme.dart';
import '../../view/screens/home_screen.dart';

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

class AbstractScreenState<T extends AbstractScreen> extends State<T> {
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
    var children = <Widget>[];
    children.add(Positioned(
        top: 0, right: 0, bottom: 0, left: 0, child: contentFactory()));
    children.addAll(navigationFactory());
    return Container(
        color: TColors.primary90, child: Stack(children: children));
    /*var rows = <Widget>[];
    rows.add(headerFactory(theme, width));
    rows.add(chromeFactory(theme, width));
    children.add(
        Column(mainAxisAlignment: MainAxisAlignment.center, children: rows));
    children.addAll(stepChildren);
    children.add(coinsButtonFactory(theme)); 

    return WillPopScope(
        key: Key(widget.mode.name),
        onWillPop: () async {
          onWillPop?.call();
          return /* widget.closeOnBack ??  */ true;
        },
        child: Stack(alignment: Alignment.center, children: children));
  */
  }

  List<Widget> navigationFactory() {
    return [
      /* Positioned(
          top: AbstractPage.statusPadding.height,
          left: AbstractPage.statusPadding.width,
          right: AbstractPage.statusPadding.width,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Widgets.button(widget.services,
                    child: SVG.show("back"),
                    width: 64.d,
                    height: 44.d,
                    color: TColors.primary,
                    onPressed: () => Navigator.of(context).pop()),
                title.isNotEmpty
                    ? Text(
                        title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TStyles.large,
                      )
                    : const SizedBox(),
                Indicator(widget.mode.name, "_soft", widget.services,
                    clickable: widget.mode != Screensshop)
              ])) */
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
      _ => AbstractScreen(Screens.none),
    };
  }

  String get name {
    return switch (this) {
      Screens.home => "home",
      Screens.loading => "loading",
      Screens.profile => "profile",
      Screens.shop => "shop",
      Screens.settings => "settings",
      _ => "none",
    };
  }

  String get routeName => "/$name";
}

/* class MyPageRoute<T> extends CupertinoPageRoute<T> {
  MyPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);
  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final tween = Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeOutExpo));
    return ScaleTransition(
        scale: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child));
  }
} */
