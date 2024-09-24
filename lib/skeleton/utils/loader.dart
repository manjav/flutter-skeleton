import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:lifetalk/skeleton/data/responses.dart';
import 'package:path_provider/path_provider.dart';

import '../mixins/logger.dart';

class Loader with ILogger {
  static String? _appDir;
  HttpClient httpClient = HttpClient();
  bool debugMode = false;
  File? file;
  List<int>? bytes;
  String path = "";
  dynamic metadata;

  Future<File?> load(
    String path,
    String url, {
    String? hash,
    bool forceUpdate = false,
    Function(double)? onProgress,
  }) async {
    this.path = path;

    _appDir = _appDir ?? (await getApplicationSupportDirectory()).path;
    file = File('$_appDir/$path');
    var ext = url.split('.').last;
    var exists = await file!.exists();
    if (exists && !forceUpdate) {
      bytes = await file!.readAsBytes();
      if (isHashMatch(bytes!, hash)) {
        // log("Complete loading $path");
        return file!;
      } else {
        log("$path MD5 is defferent. start loading ...");
      }
    }

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode != 200) {
        // log('Failure😱 => code $path ${response.statusCode} ');
        throw SkeletonException(response.statusCode.toStatus(),
            'Failure😱 => code $path ${response.statusCode} ');
      }
      bytes = <int>[];
      await _readResponse(response, onProgress);

      if (ext == 'zip') {
        Archive archive = ZipDecoder().decodeBytes(bytes!);
        bytes = archive.first.content as List<int>;
      }
      if (!isHashMatch(bytes!, hash)) {
        log("$path MD5 check failure!");
        return null;
      }
      await file!.writeAsBytes(bytes!);
      log("Complete downloading $url");
      if (!exists || !forceUpdate) {
        return file!;
      }
    } on Exception {
      log("Exception while $url loading.");
    }
    return null;
  }

  Future<List<int>?> _readResponse(HttpClientResponse response,
      [Function(double)? onProgress]) {
    final completer = Completer<List<int>?>();
    final contentLength = response.contentLength;
    response.asBroadcastStream().listen((List<int> newBytes) {
      bytes!.addAll(newBytes);
      onProgress?.call(bytes!.length / contentLength);
    },
        onDone: () => completer.complete(bytes),
        onError: (d) => log("loading failed. $d"),
        cancelOnError: true);
    return completer.future;
  }

  void abort() => httpClient.close(force: true);

  static bool isHashMatch(List<int> bytes, String? hash) {
    if (hash == null) return true;
    var fileHash = md5.convert(bytes);
    if (hash != fileHash.toString()) {
      ILogger.slog("Loader", "$fileHash is'nt equal $hash");
      return false;
    }
    return true;
  }
}
