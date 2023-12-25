import '../mixins/ilogger.dart';
import '../mixins/service_provider.dart';

abstract class IService with ILogger, ServiceProvider {
  bool isInitialized = false;
  initialize({List<Object>? args}) {
    isInitialized = true;
    log("=> Service $runtimeType initialized.");
  }
}
