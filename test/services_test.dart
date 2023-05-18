// import 'package:flutter_skeleton/services/ads_service.dart';
// import 'package:flutter_skeleton/services/analytics_service.dart';
// import 'package:flutter_skeleton/services/sounds_service.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';

// class MockAnalyticsService extends Mock implements AnalyticsService {}

// class MockSoundService extends Mock implements SoundService {}

// void main() {
//   late AdsService adsService;
//   late MockAnalyticsService mockAnalyticsService;
//   late MockSoundService mockSoundService;

//   setUp(() {
//     mockAnalyticsService = MockAnalyticsService();
//     mockSoundService = MockSoundService();
//     adsService = AdsService(analytics: mockAnalyticsService, sound: mockSoundService);
//   });

//   group('AdsService', () {
//     test('initialize method initializes Google Mobile Ads when selected SDK is Google', () {
//       // Arrange
//       adsService.selectedSDK = AdSDK.google;
//       MobileAds.instance.initialize();

//       // Act
//       adsService.initialize();

//       // Assert
//       verify(MobileAds.instance.initialize()).called(1);
//     });

//     test('initialize method initializes Unity Ads when selected SDK is Unity', () {
//       // Arrange
//       adsService.selectedSDK = AdSDK.unity;

//       // Act
//       adsService.initialize();

//       // Assert
//       // Verify that UnityAds.init() is called with the correct arguments
//       // You may need to use Mockito's `captureAnyNamed` matcher to capture the onComplete callback
//       verify(UnityAds.init(
//         testMode: false,
//         gameId: anyNamed('gameId'),
//         onComplete: captureAnyNamed('onComplete'),
//         onFailed: anyNamed('onFailed'),
//       )).called(1);
//     });

//     test('getBannerWidget returns a SizedBox with the correct width and height', () {
//       // Arrange
//       final type = 'type';
//       final island = 'island';

//       // Act
//       final widget = adsService.getBannerWidget(type, island);

//       // Assert
//       expect(widget, isA<SizedBox>());
//       expect(widget.width, 320.0);
//       expect(widget.height, 50.0);
//     });

//     // Add more tests as needed for other methods and behaviors of AdsService
//   });
// }
