import '../../export.dart';

abstract class AbstractTracker {
  TrackerSDK sdk = TrackerSDK.none;
  Function(dynamic)? logCallback;
  Future<void> initialize({List? args, Function(dynamic)? logCallback}) async {
    this.logCallback = logCallback;
    design("start_session",
        parameters: {"session_count": Pref.session.getInt()});
  }

  Future<Map<String, dynamic>> getRemoteConfigs({String? name}) async => {};

  /*  sendDiagnosticData(String version) async {
    var url =
        "https://numbers.sarand.net/variant/?test=$_testName&variant=$variant&ads=${Ads.selectedSDK}&v=$version";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) log('Failure status code 😱');
  } */

  void setProperties(Map<String, String> properties);

  void purchase(
    String currency,
    double amount,
    String itemId,
    String itemType,
    String receipt,
    String signature,
  );

  void ad(Placement placement, AdState state);

  void design(String name, {Map<String, dynamic>? parameters});

  void resource(
    ResourceFlowType type,
    String currency,
    int amount,
    String itemType,
    String itemId,
  );

  void setScreen(String screenName, {Map<String, dynamic>? parameters});

  void startProgress(String name, {Map<String, dynamic>? parameters}) {}

  void endProgress(
    String name,
    int score, {
    Map<String, dynamic>? parameters,
  }) {}

  Map<String, Object>? convertMap([Map<String, dynamic>? map]) =>
      map != null ? Map.castFrom<String, dynamic, String, Object>(map) : null;

  void log(dynamic input) => logCallback?.call(input);
}
