abstract class IService {
  bool isInitialized = false;
  initialize({List<Object>? args}) => isInitialized = true;
}
