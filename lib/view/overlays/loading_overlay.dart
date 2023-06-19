import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import '../../blocs/player_bloc.dart';
import '../../utils/utils.dart';
import '../../view/screens/iscreen.dart';
import 'ioverlay.dart';

class LoadingOverlay extends AbstractOverlay {
  const LoadingOverlay({super.key}) : super(type: OverlayType.loading);

  @override
  createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends AbstractOverlayState<AbstractOverlay> {
  Widget _alert = const SizedBox();
  SMIBool? _closeInput;
  var logViewVisibility = false;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      RiveAnimation.asset('anims/${Asset.prefix}loading.riv',
          onInit: (Artboard artboard) {
        final controller = StateMachineController.fromArtboard(
          artboard,
          'Loading',
          onStateChange: (state, animation) {
            if (animation == "closed") {
              close();
            }
          },
        );
        _closeInput = controller!.findInput<bool>('close') as SMIBool;
        artboard.addController(controller);
      }, fit: BoxFit.fitWidth),
      BlocConsumer<PlayerBloc, PlayerState>(
        builder: (context, state) {
          return Text(state.player.name);
        },
        listener: (context, state) {
          if (state.player.loadinfState == PlayerLoadingState.complete) {
            _closeInput?.value = true;
          } else if (state.player.loadinfState == PlayerLoadingState.load) {
            Navigator.pushNamed(context, Screens.home.routeName);
          }
        },
      ),
      // Positioned(
      //     bottom: 4.d,
      //     right: 16.d,
      //     child: _services.localization.isInitialized
      //         ? Text("v.${'app_version'.l()}", style: TStyles.smallInvert)
      //         : const SizedBox()),
      // Positioned(
      //     bottom: 4.d,
      //     left: 16.d,
      //     child: Text(Device.adId, style: TStyles.tinyInvert)),
      // Positioned(
      //     top: 4.d,
      //     right: 4.d,
      //     bottom: 4.d,
      //     left: 4.d,
      //     child: GestureDetector(
      //         onDoubleTap: () {
      //           setState(() => logViewVisibility = !logViewVisibility);
      //         },
      //         child: logViewVisibility
      //             ? Text(_services.connection.accumulatedLog,
      //                 style: TStyles.tinyInvert)
      //             : Widgets.rect(color: TColors.transparent))),
      _alert,
    ]);
  }

  /* _onNetworkEventChange() {
    setState(() {});
    if (_services.connection.response.state == LoadingState.disconnect) {
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
      } else if (_services.connection.response.state == LoadingState.complete) {
        _closeInput?.value = true;
    }
  } */

  void _reload() {
    close();
    // MyApp.restartApp(context);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
