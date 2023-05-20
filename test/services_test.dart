import 'package:flutter/material.dart';
import 'package:flutter_skeleton/services/localization_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // group('MainAnalytics', () {
  //   late AnalyticsService analyticsService;

  //   setUp(() {
  //     analyticsService = Analytics();
  //   });

  //   test('initialize() should initialize the service', () async {
  //     final result = await analyticsService.initialize();
  //     expect(true, true);
  //   });

  //   test('funnle should return an Analytics funnle', () async {
  //     final result = await analyticsService.funnle("testType", "name");
  //     expect(true, true);
  //   });
  // });

  // group('soundService', () {
  //   late SoundService soundService;

  //   setUp(() {
  //     soundService = Sounds();
  //   });

  //   test('initialize() should initialize the service', () async {
  //     final result = await soundService.initialize();
  //     expect(true, true);
  //   });

  //   test('log should log the service', () async {
  //     final result = await soundService.log("log");
  //     expect(true, true);
  //   });

  //   test('play should play the add', () async {
  //     final result = await soundService.play("testName");
  //     expect(true, true);
  //   });
  //   test('stop should stop the add', () async {
  //     final result = await soundService.stop("channel");
  //     expect(true, true);
  //     // expect(result.data, 'analytics sendEvent');
  //   });
  //   test('stopAll should stop all ads', () async {
  //     final result = await soundService.stopAll();
  //     expect(true, true);
  //   });
  // });

  // group('soundService', () {
  //   late AnalyticsService analytics;
  //   late IAdsService adsService;
  //   late SoundService soundService;

  //   setUp(() {
  //     analytics = Analytics();
  //     soundService = Sounds();
  //     adsService = AdsService(analytics: analytics, sound: soundService);
  //   });

  //   test('initialize() should initialize the service', () async {
  //     final result = await adsService.initialize();
  //     expect(true, true);
  //   });

  //   test('log should log the service', () async {
  //     final result = await adsService.log("log");
  //     expect(true, true);
  //   });

  //   test('showInterstitial is for ?', () async {
  //     final result =
  //         await adsService.showInterstitial(AdId.bannerGoogle, "island");

  //     expect(true, true);
  //   });
  //   test('isReady is for the time when ad is ready', () async {
  //     final result = await adsService.isReady();

  //     expect(true, true);
  //   });
  //   test('stopAll should stop all ads', () async {
  //     final result = await adsService.showRewarded("source");

  //     expect(true, true);
  //   });
  // });
  group('localization', () {
    late LocalizationService localizationService;

    setUp(() {
      localizationService = LocalizationService();
      // networkService = Network();
      // gameApisService = MainGameApi();
    });
    TestWidgetsFlutterBinding.ensureInitialized();

    // expect(localizationService.isLoaded, false);
    test('Defult load values before localization init', () async {
      expect(localizationService.dir, TextDirection.ltr);
      expect(localizationService.languageCode, "en");
      expect(localizationService.isLoaded, false);
      expect(localizationService.isRTL, false);
    });
    test('initialize() should initialize the service', () async {
      await localizationService.initialize();
      expect(localizationService.isLoaded, true);
    });

    test('log() should print the provided log message', () {
      const logMessage = 'This is a log message';
      final printedLogs = <String>[];

      // Mock debugPrint method to capture printed logs
      debugPrint = (message, {wrapWidth}) {
        printedLogs.add(message!);
      };
      localizationService.log(logMessage);

      expect(printedLogs.length, 1);
      expect(printedLogs[0], logMessage);
    });
  });

  // group('network', () {
  //   late NetworkService networkService;

  //   setUp(() {
  //     networkService = Network();
  //   });

  //   test('initialize() should initialize the service', () async {
  //     final result = await networkService.initialize();
  //     expect(true, true);
  //   });

  //   test('log should log the service', () async {
  //     final result = await networkService.log("log");
  //     expect(true, true);
  //   });
  //   test('rpc for the protocol', () async {
  //     final result = await networkService.rpc(RpcId.battle, payload: "payload");
  //     expect(true, true);
  //   });
  //   test('updateResponse is to update the response', () async {
  //     final result =
  //         await networkService.updateResponse(LoadingState.complete, "Message");
  //     expect(true, true);
  //   });
  // });
  // group('network', () {
  //   late GameApisService gameApisService;

  //   setUp(() {
  //     gameApisService = MainGameApi();
  //   });

  //   test('initialize() should initialize the service', () async {
  //     final result = await gameApisService.initialize();
  //     expect(true, true);
  //   });

  //   test('log should log the service', () async {
  //     final result = await gameApisService.log("log");
  //     expect(true, true);
  //   });
  //   test('connect check if the api is connected', () async {
  //     final result = await gameApisService.connect();
  //     expect(true, true);
  //   });
  //   test('disconnect check if the api is not connected', () async {
  //     final result = await gameApisService.disconnect();
  //     expect(true, true);
  //   });
  // });
}
