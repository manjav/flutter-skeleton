import 'dart:convert';

import 'package:flutter_skeleton/data/core/account.dart';
import 'package:flutter_skeleton/data/core/rpc_data.dart';
import 'package:flutter_skeleton/services/iservices.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';

import '../../utils/utils.dart';

class NoobSocket extends IService {
  late TcpSocketConnection _socketConnection;
  String get _secret => "floatint201412bool23string";

  @override
  initialize({List<Object>? args}) async {
    super.initialize(args: args);
    var account = args![0] as Account;

    _socketConnection =
        TcpSocketConnection(LoadingData.chatIp, LoadingData.chatPort);
    // _socketConnection.enableConsolePrint(true);
    await _socketConnection.connect(500, _messageReceived, attempts: 3);
  }

  void _messageReceived(String message) {
    var startIndex = message.indexOf("__JSON__START__");
    var endIndex = message.indexOf("__JSON__END__");
    if (startIndex < 0 || endIndex < 0) {
      return;
    }
    var b64 = utf8.fuse(base64);
    message = message.substring(startIndex + 15, endIndex);
    message = b64.decode(message.xorDecrypt(secret: _secret));
  }
  }
