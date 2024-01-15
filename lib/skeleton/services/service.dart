import '../skeleton.dart';

abstract class IService with ILogger, ServiceFinderMixin {
  bool isInitialized = false;
  initialize({List<Object>? args}) {
    isInitialized = true;
    log("=> Service $runtimeType initialized.");
  }
}
