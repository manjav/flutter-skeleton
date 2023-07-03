import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import '../../blocs/services.dart';
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
  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    var bloc = BlocProvider.of<Services>(context);
    bloc.add(ServicesEvent(ServicesInitState.complete, null));
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
            bottom: 300.d,
            width: 240.d,
            height: 240.d,
            child: LoaderWidget(AssetType.animation, 'coin', width: 156.d)),
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
            width: 360.d,
            color: TColors.clay,
            onPressed: () => Navigator.pushNamed(
                context, Routes.popupTabPage.routeName,
                arguments: {'tabsCount': 4}),
            child: const SkinnedText("Show Pop Up"))
      ],
    );
  }
}
