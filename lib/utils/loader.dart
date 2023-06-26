import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/ilogger.dart';

class Loader with ILogger {
  static String? _appDir;
  HttpClient httpClient = HttpClient();
  bool debugMode = false;
  File? file;
  List<int>? bytes;
  String path = "";

  Future<Loader> load(String path, String url,
      {Function(File)? onDone,
      Function(double)? onProgress,
      Function(dynamic)? onError,
      String? hash,
      bool forceUpdate = false}) async {
    this.path = path;

    _appDir = _appDir ?? (await getApplicationSupportDirectory()).path;
    file = File('$_appDir/$path');
    var ext = url.split('.').last;
    var exists = await file!.exists();
    if (exists && !forceUpdate) {
      bytes = await file!.readAsBytes();
      if (isHashMatch(bytes!, hash, path)) {
        log("Complete loading $path");
        onDone?.call(file!);
        return this;
      }
    }

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode != 200) {
        log('Failure status code 😱');
        onError?.call(response.statusCode);
        return this;
      }
      var contentLength = response.contentLength;
      bytes = <int>[];
      response.asBroadcastStream().listen((List<int> newBytes) {
        bytes!.addAll(newBytes);
        onProgress?.call(bytes!.length / contentLength);
      }, onDone: () async {
        if (ext == 'zip') {
          Archive archive = ZipDecoder().decodeBytes(bytes!);
          bytes = archive.first.content as List<int>;
        }
        if (!isHashMatch(bytes!, hash, path)) {
          return onError?.call("$path md5 is invalid!");
        }
        await file!.writeAsBytes(bytes!);
        log("Complete loading $url");
        if (!exists || !forceUpdate) onDone?.call(file!);
      }, onError: (d) {
        log("$url loading failed.");
        return onError?.call(d);
      }, cancelOnError: true);
    } on Exception {
      log("Exception while $url loading.");
      onError?.call("exception");
    }
    return this;
  }

  void abort() => httpClient.close(force: true);

  bool isHashMatch(List<int> bytes, String? hash, String path) {
    if (hash == null) return true;
    var fileHash = md5.convert(bytes);
    if (hash == fileHash.toString()) {
      return true;
    }
    log("$path MD5 $hash != $fileHash}");
    return false;
  }
}
