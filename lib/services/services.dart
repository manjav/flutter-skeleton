import '../mixins/logger.dart';
import '../mixins/service_finder_mixin.dart';

abstract class IService with ILogger, ServiceFinderMixin {
  bool isInitialized = false;
  initialize({List<Object>? args}) {
    isInitialized = true;
    log("=> Service $runtimeType initialized.");
  }
}
