import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/services_bloc.dart';
import '../../data/core/result.dart';
import '../../main.dart';
import '../../mixins/logger.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/prefs.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'overlay.dart';

class LoadingOverlay extends AbstractOverlay {
  const LoadingOverlay({super.key}) : super(type: OverlayType.loading);

  @override
  createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends AbstractOverlayState<LoadingOverlay> {
  bool _logViewVisibility = false;
  RpcException? _exception;
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
    var isUpdateError =
        _exception?.statusCode == StatusCode.C700_UPDATE_NOTICE ||
            _exception?.statusCode == StatusCode.C701_UPDATE_FORCE;
    var isForceUpdate = _exception?.statusCode == StatusCode.C701_UPDATE_FORCE;
    var logStyle = TStyles.tiny.copyWith(color: TColors.gray);
    return Scaffold(
      body: Stack(alignment: Alignment.center, children: [
        Asset.load<RiveAnimation>('loading', onRiveInit: (Artboard artboard) {
          final controller = StateMachineController.fromArtboard(
              artboard, 'Loading', onStateChange: (state, animation) {
            if (animation == "closed") {
              close();
            }
          });
          _closeInput = controller!.findInput<bool>('close') as SMIBool;
          artboard.addController(controller);
        }, fit: BoxFit.fitWidth),
        BlocConsumer<ServicesBloc, ServicesState>(
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
                Navigator.pushReplacementNamed(context, Routes.home.routeName);
              }
            } else if (state.initState == ServicesInitState.error) {
              _exception = state.data as RpcException;
              setState(() {});
            }
          },
        ),
        Positioned(
            bottom: 4.d,
            right: 16.d,
            child: Text("v.${'app_version'.l()}", style: logStyle)),
        Positioned(
            bottom: 4.d,
            left: 16.d,
            child: Text(DeviceInfo.adId, style: logStyle)),
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
                    ? Text(ILogger.accumulatedLog, style: TStyles.tiny)
                    : Widgets.rect(color: TColors.transparent))),
        _exception == null
            ? const SizedBox()
            : Positioned(
                left: 20.d,
                right: 20.d,
                bottom: 200.d,
                child: Column(
                  children: [
                    Text(
                      "${'error_${_exception!.statusCode.value}'.l([
                            _exception!.message
                          ])}\n${isUpdateError ? "" : "try_again".l()}",
                      textAlign: TextAlign.center,
                      style: TStyles.mediumInvert,
                      softWrap: true,
                    ),
                    SizedBox(height: 48.d),
                    Row(
                        textDirection: TextDirection.ltr,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isUpdateError && !isForceUpdate
                              ? Widgets.skinnedButton(
                                  height: 160.d,
                                  padding:
                                      EdgeInsets.fromLTRB(42.d, 0, 42.d, 16.d),
                                  label: "play_l".l(),
                                  buttonId: -1,
                                  onPressed: () {
                                    Pref.skipUpdate.setBool(true);
                                    _reload();
                                  })
                              : const SizedBox(),
                          SizedBox(width: 12.d),
                          Widgets.skinnedButton(
                              color: isUpdateError
                                  ? ButtonColor.green
                                  : ButtonColor.yellow,
                              height: 160.d,
                              padding: EdgeInsets.fromLTRB(42.d, 0, 42.d, 16.d),
                              label: isUpdateError
                                  ? "update_l".l()
                                  : "retry_l".l(),
                              buttonId: -1,
                              onPressed: () => _retry(
                                  _exception, isUpdateError, isForceUpdate)),
                        ])
                  ],
                )),
      ]),
    );
  }

  void _update(bool isForceUpdate) {
    launchUrl(Uri.parse("app_url".l()));
    SystemNavigator.pop();
  }

  void _reload() {
    close();
    MyApp.restartApp(context);
  }

  void _retry(RpcException? exception, bool isUpdateError, bool isForceUpdate) {
    if (_exception!.statusCode == StatusCode.C154_INVALID_RESTORE_KEY) {
      close();
      Navigator.pushNamed(context, Routes.popupRestore.routeName,
          arguments: {"onlySet": true});
    } else if (isUpdateError) {
      _update(isForceUpdate);
    } else {
      _reload();
    }
  }
}
