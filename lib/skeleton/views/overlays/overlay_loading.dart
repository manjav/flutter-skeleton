import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_export.dart';

class LoadingOverlay extends AbstractOverlay {
  const LoadingOverlay({super.key}) : super(route: OverlaysName.loading);

  @override
  createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends AbstractOverlayState<LoadingOverlay> {
  SMIBool? _closeInput;
  bool _logViewVisibility = false;
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
        _serviceState.exception!.statusCode == StatusCode.UPDATE_FORCE;
    var isUpdateError = _serviceState.exception != null &&
            _serviceState.exception!.statusCode == StatusCode.UPDATE_NOTICE ||
        isForceUpdate;
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
            child: Text("v.${DeviceInfo.buildNumber}",
                style: TStyles.tinyDetails)),
        Positioned(
            bottom: 4.d,
            left: 16.d,
            child: Text(DeviceInfo.adId, style: TStyles.tinyDetails)),
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
                bottom: 80.d,
                child: Column(
                  children: [
                    Text(
                      "${_serviceState.exception!.message}\n${isUpdateError ? "" : "Try Again".l()}",
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
                                  label: "Go !",
                                  buttonId: -1,
                                  onPressed: () {
                                    _reload();
                                  })
                              : const SizedBox(),
                          SizedBox(
                              width:
                                  isUpdateError && !isForceUpdate ? 12.d : 0),
                          SkinnedButton(
                              color: isUpdateError
                                  ? TColors.green
                                  : TColors.orange,
                              label: isUpdateError ? "Update" : "Retry",
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
    launchUrl(Uri.parse("app_url_${Platform.operatingSystem}".l()));
    SystemNavigator.pop();
  }

  void _reload() {
    close();
    MyApp.restartApp(context);
  }

  void _retry(
      SkeletonException? exception, bool isUpdateError, bool isForceUpdate) {
    if (exception!.statusCode == StatusCode.INVALID_RESTORE_KEY ||
        exception.statusCode == StatusCode.UPDATE_TEST) {
      close();
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
