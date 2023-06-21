import '../../utils/ilogger.dart';

abstract class IService with ILogger {
  bool isInitialized = false;
  initialize({List<Object>? args}) {
    isInitialized = true;
    log("initialized.");
  }
}
