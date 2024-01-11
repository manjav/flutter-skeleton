import 'dart:io';
import 'dart:math' as math;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'services.dart';

class DeviceInfo extends IService {
  static double ratio = 1;
  static Size size = Size.zero;
  static double aspectRatio = 1;
  static double devicePixelRatio = 1;
  static String id = "";
  static String adId = "";
  static String model = "";
  static double osVersion = 0;
  static String baseVersion = "";
  static Map<String, dynamic> _deviceData = {};
  static String packageName = "";
  static String buildNumber = "";
  static String version = "";
  static String appName = "";
  static bool isPreInitialized = false;

  static Future<bool> preInitialize(BuildContext context,
      [bool forced = false]) async {
    if (!forced && isPreInitialized) return false;
    var q = MediaQuery.of(context);
    DeviceInfo.size = q.size;
    DeviceInfo.devicePixelRatio = q.devicePixelRatio;
    var width = math.min(size.width, size.height);
    var height = math.max(size.width, size.height);
    ratio = width / 1080;
    aspectRatio = width / height;
    var packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo.packageName;
    buildNumber = packageInfo.buildNumber;
    version = packageInfo.version;
    appName = packageInfo.appName;
    isPreInitialized = true;
    return true;
  }

  @override
  initialize({List<Object>? args}) async {
    log("◢◤◢◤◢◤◢◤◢◤◢ ${DeviceInfo.size} ${DeviceInfo.devicePixelRatio} $ratio ◢◤◢◤◢◤◢◤◢◤◢");
    var deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (kIsWeb) {
        _deviceData =
            _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        if (Platform.isAndroid) {
          _deviceData =
              _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
          id = _deviceData['fingerprint'];
          model = _deviceData['model'];
          var releaseVersion = _deviceData['version.release'].toString();
          var parts = releaseVersion.split('.');
          osVersion =
              double.parse(parts[0] + (parts.length > 1 ? ".${parts[0]}" : ""));
          baseVersion = _deviceData['version.sdkInt'].toString();
        } else if (Platform.isIOS) {
          _deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
          id = _deviceData['identifierForVendor'];
          model = _deviceData['name'];
          osVersion = double.parse(_deviceData['systemVersion']);
          baseVersion = _deviceData['utsname.version:'];
        } else if (Platform.isLinux) {
          _deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
        } else if (Platform.isMacOS) {
          _deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
        } else if (Platform.isWindows) {
          _deviceData =
              _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
        }
      }
    } on PlatformException {
      _deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }

  static _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
    };
  }

  static _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  static _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  static _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  static _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  static _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    };
  }
}

extension DeviceI on int {
  double get d => this * DeviceInfo.ratio;
  int get i => d.round();
}

extension DeviceD on double {
  double get d => this * DeviceInfo.ratio;
  int get i => d.round();
}
