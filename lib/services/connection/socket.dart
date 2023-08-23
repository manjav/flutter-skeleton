import 'dart:convert';

import 'package:flutter_skeleton/data/core/account.dart';
import 'package:flutter_skeleton/data/core/rpc_data.dart';
import 'package:flutter_skeleton/services/iservices.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';

import '../../utils/utils.dart';
class NoobSocket extends IService {
  @override
  initialize({List<Object>? args}) async {
    super.initialize(args: args);
    var account = args![0] as Account;
  }
