import '../ads_service.dart';
import 'trackers_service.dart';

abstract class AbstractTracker {
  var sdk = TrackerSDK.none;
  initialize({List? args});
  // AppMetrica.runZoneGuarded(() {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   AppMetrica.activate(AppMetricaConfig('am_key'.l(), logs: true));
  // });
  //   AppMetrica.reportEvent("type_$type");
  //   // Smartlook initialize
  //   if (Pref.visitCount.getInt() <= 1 && Device.osVersion > 10) {
  //     // Smartlook.instance.log.enableLogging();
  //     await Smartlook.instance.preferences.setProjectKey("sl_key_$os".l());
  //     await Smartlook.instance.start();
  //     // Smartlook.instance.registerIntegrationListener(CustomIntegrationListener());
  //     // await Smartlook.instance.preferences.setWebViewEnabled(true);
  //   }
  // }

  Future<String?> getDeviceId() async => null;
  Future<int> getVariantId(String testName) async => 0;

  /*  sendDiagnosticData(String version) async {
    var url =
        "https://numbers.sarand.net/variant/?test=$_testName&variant=$variant&ads=${Ads.selectedSDK}&v=$version";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) debugPrint('Failure status code 😱');
  } */

  setProperties(Map<String, String> properties);
  // Smartlook.instance.user.setIdentifier(account.user.id);
  // Smartlook.instance.user.setName(account.user.displayName);
  // AppMetrica.setUserProfileID(account.user.id);

  purchase(
    String currency,
    double amount,
    String itemId,
    String itemType,
    String receipt,
    String signature,
  );
  // AppMetrica.reportEventWithMap("purchase", data);
  // _appsflyerSdk.validateAndLogInAppAndroidPurchase("shop_base64".l(),

  ad(MyAd ad, AdState state);
  // AppMetrica.reportEventWithMap("ads", map);
  // AppMetrica.reportEventWithMap("ad_$placementID", map);
}
