import '../../export.dart';

abstract class AbstractTracker {
  TrackerSDK sdk = TrackerSDK.none;
  Function(dynamic)? logCallback;
  initialize({List? args, Function(dynamic)? logCallback}) {
    this.logCallback = logCallback;
  }

  Future<String?> getDeviceId() async => null;
  Future<int> getVariantId(String testName) async => 0;

  /*  sendDiagnosticData(String version) async {
    var url =
        "https://numbers.sarand.net/variant/?test=$_testName&variant=$variant&ads=${Ads.selectedSDK}&v=$version";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) log('Failure status code 😱');
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

  ad(Placement placement, AdState state);

  resource(ResourceFlowType type, String currency, int amount, String itemType,
      String itemId);

  design(String name, {Map<String, dynamic>? parameters});

  setScreen(String screenName);

  log(dynamic input) => logCallback?.call(input);
}
