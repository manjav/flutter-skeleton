
enum Screens {
  home,
  loading,
  profile,
  settings,
  shop,
}

extension ScreenTools on Screens {
  static AbstractScreen getScreen(String routeName, {List<Object>? args}) {
    return switch (routeName) {
      // case "/shop":
      //   return ShopPage(services);
      _ => LoadingScreen()
    };
  }

  String get name {
    return switch (this) {
      Screens.home => "home",
      Screens.loading => "loading",
      Screens.profile => "profile",
      Screens.shop => "shop",
      Screens.settings => "settings"
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
