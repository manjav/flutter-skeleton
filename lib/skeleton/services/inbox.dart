import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../../services/services.dart';
import '../skeleton.dart';

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
