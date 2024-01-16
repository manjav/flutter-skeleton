import 'package:flutter/material.dart';
import 'package:flutter_skeleton/app_export.dart';


class Inbox extends IService with ServiceFinderMixin {
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
