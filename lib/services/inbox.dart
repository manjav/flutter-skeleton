import 'package:flutter/material.dart';

import '../../data/core/account.dart';
import '../../data/core/message.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import 'iservices.dart';

class Inbox extends IService {
  List<Message> messages = [];
  @override
  initialize({List<Object>? args}) async {
    try {
      var context = args![0] as BuildContext;
      var data = await getService<HttpConnection>(context)
          .tryRpc(context, RpcId.messages);
      messages = Message.initAll(data["messages"], args[1] as Account);
    } finally {}
    super.initialize();
  }
}
