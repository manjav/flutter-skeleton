import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_export.dart';
import '../../main.dart';

class LoadingOverlay extends AbstractOverlay {
  const LoadingOverlay({super.key}) : super(route: OverlaysName.loading);

  @override
  createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends AbstractOverlayState<LoadingOverlay> {
  bool _logViewVisibility = false;
  SMIBool? _closeInput;
  final _minAnimationTime = 1500;
  ServiceState _serviceState = ServiceState(ServiceStatus.none);

  @override
  void initState() {
    services.addListener(_serviceListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //todo: check status code is moved to project it's better check this in project or refactor
    var isForceUpdate = _serviceState.exception != null &&
        _serviceState.exception!.statusCode ==
            StatusCode.C701_UPDATE_FORCE.value;
    var isUpdateError = _serviceState.exception != null &&
            _serviceState.exception!.statusCode ==
                StatusCode.C700_UPDATE_NOTICE.value ||
        isForceUpdate;
    var logStyle = TStyles.tiny.copyWith(color: TColors.gray);
    return Scaffold(
      backgroundColor: TColors.transparent,
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
        Positioned(
            bottom: 4.d,
            right: 16.d,
            child: Text("v.${DeviceInfo.buildNumber}", style: logStyle)),
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
        _serviceState.exception == null
            ? const SizedBox()
            : Positioned(
                left: 20.d,
                right: 20.d,
                bottom: 200.d,
                child: Column(
                  children: [
                    Text(
                      "${'error_${_serviceState.exception!.statusCode}'.l([
                            _serviceState.exception!.message
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
                              ? SkinnedButton(
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
                          SkinnedButton(
                              color: isUpdateError
                                  ? ButtonColor.green
                                  : ButtonColor.yellow,
                              height: 160.d,
                              padding: EdgeInsets.fromLTRB(42.d, 0, 42.d, 16.d),
                              label: isUpdateError
                                  ? "update_l".l()
                                  : "retry_l".l(),
                              buttonId: -1,
                              onPressed: () => _retry(_serviceState.exception,
                                  isUpdateError, isForceUpdate)),
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

  void _retry(
      SkeletonException? exception, bool isUpdateError, bool isForceUpdate) {
    if (exception!.statusCode == StatusCode.C154_INVALID_RESTORE_KEY.value ||
        exception.statusCode == StatusCode.C702_UPDATE_TEST.value) {
      close();
      // Routes.popupRestore.navigate(context, args: {"onlySet": true});
    } else if (isUpdateError) {
      _update(isForceUpdate);
    } else {
      _reload();
    }
  }

  Future<void> _serviceListener() async {
    if (services.state.status == ServiceStatus.complete) {
      services.removeListener(_serviceListener);
    } else if (services.state.status == ServiceStatus.initialize) {
      // Wait for minimum animation time
      var elapsedTime =
          DateTime.now().difference(MyApp.startTime).inMilliseconds;
      await Future.delayed(
          Duration(milliseconds: _minAnimationTime - elapsedTime));
      _closeInput?.value = true;
    } else if (services.state.status == ServiceStatus.error) {
      _serviceState = services.state;
      setState(() {});
    }
  }
}
