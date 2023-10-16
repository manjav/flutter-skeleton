import '../../services/service_provider.dart';
import '../../utils/ilogger.dart';

abstract class IService with ILogger, ServiceProvider {
  bool isInitialized = false;
  initialize({List<Object>? args}) {
    isInitialized = true;
    log("=> Service $runtimeType initialized.");
  }
}
