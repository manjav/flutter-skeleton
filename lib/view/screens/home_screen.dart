import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import '../../blocs/services.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/screens/iscreen.dart';
import '../../view/widgets/loaderwidget.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  late SMINumber _level;
  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    var bloc = BlocProvider.of<Services>(context);
    bloc.add(ServicesEvent(ServicesInitState.complete, null));
  }


  @override
  List<Widget> appBarElements() {
    return <Widget>[
      SizedBox(
          width: 194.d,
          height: 202.d,
          child: const LevelIndicator(level: "2", xp: 12)),
      ...super.appBarElements(),
    ];
  }

  @override
  Widget contentFactory() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
            top: 310.d,
            child: LoaderWidget(AssetType.image, 'weather_4', width: 128.d)),
        Positioned(
            bottom: 500.d,
            width: 500.d,
            height: 500.d,
            child: LoaderWidget(AssetType.animation, 'building_greenhouse',
                onRiveInit: (Artboard artboard) {
              final controller = StateMachineController.fromArtboard(
                artboard,
                'Building',
                onStateChange: (state, animation) {
                  print('$state ====== $animation');
                },
              )!;
              _level = controller.findInput<double>('greenhouse') as SMINumber;
              artboard.addController(controller);
            }, fit: BoxFit.fitWidth)),
        Positioned(
            bottom: 0,
            width: 240.d,
            height: 240.d,
            child: Asset.load<RiveAnimation>('loading',
                fit: BoxFit.fitWidth,
                onRiveInit: (artboard) => artboard.addController(
                    StateMachineController.fromArtboard(artboard, 'Loading')
                        as RiveAnimationController))),
        Widgets.button(
            color: TColors.clay,
            onPressed: () {
              Navigator.pushNamed(context, Routes.popupTabPage.routeName,
                  arguments: {'selectedTabIndex': 2});
            },
            child: const SkinnedText("Show Pop Up")),
        Positioned(
            bottom: 400.d,
            width: 450.d,
            child: Widgets.button(
                color: TColors.clay,
                onPressed: () => _level.value = (_level.value + 1) % 12,
                child: const SkinnedText("Upgrade Building"))),
      ],
    );
  }
}
