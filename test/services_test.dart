// import 'package:fc_project/services/analytics.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:fc_project/models/analytics_model.dart';

// import 'package:fc_project/models/ads_model.dart';

// import 'package:fc_project/models/connection_mode.dart';
// import 'package:fc_project/models/game_api_model.dart';
// import 'package:fc_project/services/ads_service.dart';
// import 'package:fc_project/services/connection.dart';
// import 'package:fc_project/services/game_apis.dart';

// void main() {
//   group('MainAnalytics', () {
//     late AnalyticsService analyticsService;

//     setUp(() {
//       analyticsService = MainAnalytics();
//     });

//     test('initialize() should return an Analytics instance', () async {
//       final result = await analyticsService.initialize();
//       expect(result, isA<Analytics>());
//       expect(result.data, 'analytics initialize');
//     });

//     test('sendEvent() should return an Analytics instance', () async {
//       final result = await analyticsService.sendEvent();
//       expect(result, isA<Analytics>());
//       expect(result.data, 'analytics sendEvent');
//     });
//   });

//   group('GoogleAds', () {
//     late AdsService adsService;

//     setUp(() {
//       adsService = GoogleAds();
//     });

//     test('initialize() should return an Ads instance', () async {
//       final result = await adsService.initialize();
//       expect(result, isA<Ads>());
//       expect(result.data, 'ads Initialized');
//     });

//     test('isReady() should return an Ads instance', () async {
//       final result = await adsService.isReady();
//       expect(result, isA<Ads>());
//       expect(result.data, 'ads IsReady');
//     });

//     test('show() should return an Ads instance', () async {
//       final result = await adsService.show();
//       expect(result, isA<Ads>());
//       expect(result.data, 'ads Show');
//     });
//   });

//   group('MainConnection', () {
//     late ConnectionService connectionService;

//     setUp(() {
//       connectionService = MainConnection();
//     });

//     test('initialize() should return a NetConnection instance', () async {
//       final result = await connectionService.initialize();
//       expect(result, isA<NetConnection>());
//       expect(result.message, 'ConnectionService initialize');
//       expect(result.response, ConnectionType.wifi);
//     });

//     test('connect() should return a NetConnection instance', () async {
//       final result = await connectionService.connect();
//       expect(result, isA<NetConnection>());
//       expect(result.message, 'ConnectionService connect');
//       expect(result.response, ConnectionType.wifi);
//     });

//     test('disconnect() should return a NetConnection instance', () async {
//       final result = await connectionService.disconnect();
//       expect(result, isA<NetConnection>());
//       expect(result.message, 'disconnect');
//       expect(result.response, ConnectionType.wifi);
//     });
//   });

//   group('MainAPI', () {
//     late GameApis gameApis;

//     setUp(() {
//       gameApis = MainAPI();
//     });

//     test('initialize() should return a GameApi instance with the provided data',
//         () async {
//       final result = await gameApis.initialize();
//       expect(result, isA<GameApi>());
//       expect(result.data, {"gold": 1});
//     });

//     test('connect() should return a GameApi instance with the server data',
//         () async {
//       final result = await gameApis.connect();
//       expect(result, isA<GameApi>());
//       expect(result.data, {"gold": 1, "nektar": 1});
//     });

//     test('disconnect() should return a GameApi instance with the server data',
//         () async {
//       final result = await gameApis.disconnect();
//       expect(result, isA<GameApi>());
//       expect(result.data, {"gold": 2, "nektar": 2});
//     });
//   });
// }
