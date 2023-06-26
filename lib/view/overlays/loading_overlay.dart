import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/utils/assets.dart';
import 'package:rive/rive.dart';

import '../../blocs/services.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/ilogger.dart';
import '../../view/screens/iscreen.dart';
import '../widgets.dart';
import 'ioverlay.dart';

class LoadingOverlay extends AbstractOverlay {
  const LoadingOverlay({super.key}) : super(type: OverlayType.loading);

  @override
  createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends AbstractOverlayState<AbstractOverlay> {
  bool _logViewVisibility = false;
  Widget _alert = const SizedBox();
  SMIBool? _closeInput;
  int _startTime = 0;
  final _minAnimationTime = 3000;

  @override
  void initState() {
    _startTime = DateTime.now().millisecondsSinceEpoch;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Asset.load<RiveAnimation>('loading', onRiveInit: (Artboard artboard) {
        final controller = StateMachineController.fromArtboard(
          artboard,
          'Loading',
          onStateChange: (state, animation) {
            if (animation == "closed") close();
          },
        );
        _closeInput = controller!.findInput<bool>('close') as SMIBool;
        artboard.addController(controller);
      }, fit: BoxFit.fitWidth),
      BlocConsumer<Services, ServicesState>(
        builder: (context, state) => const SizedBox(),
        listener: (context, state) async {
          if (state.initState == ServicesInitState.complete) {
            _closeInput?.value = true;
          } else if (state.initState == ServicesInitState.initialize) {
            // wait for minimum animation time
            var elapsedTime =
                DateTime.now().millisecondsSinceEpoch - _startTime;
            await Future.delayed(
                Duration(milliseconds: _minAnimationTime - elapsedTime));
            if (mounted) {
              Navigator.pushNamed(context, Screens.home.routeName);
            }
          } else if (state.initState == ServicesInitState.error) {
            _alert = Positioned(
                bottom: 48.d,
                child: Column(
                  children: [
                    Text(
                      "Connection Lost!\nPlease try again.",
                      textAlign: TextAlign.center,
                      style: TStyles.medium,
                    ),
                    SizedBox(height: 16.d),
                    Widgets.button(
                        buttonId: -1,
                        child: Text('Retry', style: TStyles.large),
                        width: 180.d,
                        color: TColors.blue,
                        onPressed: () {
                          _reload();
                        })
                  ],
                ));
            setState(() {});
          }
        },
      ),
      Positioned(
          bottom: 4.d,
          right: 16.d,
          child: Text("v.${'app_version'.l()}", style: TStyles.smallInvert)),
      Positioned(
          bottom: 4.d,
          left: 16.d,
          child: Text(DeviceInfo.adId, style: TStyles.tinyInvert)),
      Positioned(
          top: 4.d,
          right: 4.d,
          bottom: 4.d,
          left: 4.d,
          child: GestureDetector(
              onDoubleTap: () {
                setState(() => _logViewVisibility = !_logViewVisibility);
              },
              child: _logViewVisibility
                  ? Text(ILogger.accumulatedLog, style: TStyles.tinyInvert)
                  : Widgets.rect(color: TColors.transparent))),
      _alert,
    ]);
  }

  void _reload() {
    close();
    // MyApp.restartApp(context);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
