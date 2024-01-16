import 'package:flutter/material.dart';

import '../../app_export.dart';

enum Messages {
  none,
  text, //1
  joinTribeRequest, //2
  joinSucceed, //3
  inviteTribeRequest, //4
  attackLose, //5
  poke, //6
  info, //7
  taunt, //8
  kickMessage, //9
  promote, //10
  demote, //11
  inviteAcceptMessage, //12
  newMember, //13
  donate, //14
  kick, //15,
  leagueWinMessage, //16
  attackLose2, //17
  pin, //18
  unknown2, //19
  unknown3, //20
}

enum MessageSubject { attack, info, social }

extension MessagesExtenstion on Messages {
  bool get inTribe => switch (this) {
        Messages.joinTribeRequest ||
        Messages.poke ||
        Messages.promote ||
        Messages.demote ||
        Messages.newMember ||
        Messages.donate ||
        Messages.kick ||
        Messages.pin =>
          true,
        _ => false,
      };
  bool get isConfirm {
    return switch (this) {
      Messages.joinTribeRequest || Messages.inviteTribeRequest => true,
      _ => false,
    };
  }

  MessageSubject get subject {
    if (this == Messages.attackLose || this == Messages.attackLose2) {
      return MessageSubject.attack;
    }
    if (inTribe ||
        this == Messages.joinSucceed ||
        this == Messages.inviteTribeRequest) {
      return MessageSubject.social;
    }
    return MessageSubject.info;
  }
}

class Message with ServiceFinderMixin {
  List<int> intData = [];
  Messages type = Messages.none;
  String text = "", metadata = "";
  int id = 0, createdAt = 0, senderId = 0;

  Message(Map<String, dynamic> map, Account account) {
    id = map["id"];
    senderId = map["sender_id"];
    createdAt = map["created_at"];
    type = Messages.values[map["message_type"]];
    intData.add(Convert.toInt(map["intmetadata1"]));
    intData.add(Convert.toInt(map["intmetadata2"]));
    metadata = map["strmetadata"];
    senderId = map["sender_id"];
    text = map["text"].isNotEmpty ? map["text"] : map["text_fa"];
  }

  static List<Message> initAll(List list, Account account) {
    var result = <Message>[];
    var now = DateTime.now().secondsSinceEpoch;
    for (var map in list) {
      if (now - map["created_at"] > 3600 * 24 * 365) continue;
      var message = Message(map, account);
      if (message.type.inTribe) {
        _addtoTribe(account, message, map);
      } else {
        result.add(message);
      }
    }
    return result;
  }

  static void _addtoTribe(
      Account account, Message message, Map<String, dynamic> map) {
    if (account.tribe == null) return;
    var index =
        account.tribe!.chat.value.indexWhere((chat) => chat.id == map["id"]);
    if (index >= 0) return;
    map["messageType"] = map["message_type"];
    map["creationDate"] = map["created_at"];
    var chat = NoobChatMessage(map, account);
    chat.text = message.getText();
    chat.base = message;
    account.tribe!.chat.add(chat);
  }

  String getText() {
    return switch (type) {
      Messages.text => text,
      Messages.joinTribeRequest => "message_${type.index}".l([metadata]),
      Messages.joinSucceed => "message_${type.index}".l([metadata]),
      Messages.inviteTribeRequest => "message_${type.index}".l([metadata]),
      Messages.attackLose ||
      Messages.attackLose2 =>
        "message_5_${id % 3}".l([metadata]),
      Messages.poke => "message_${type.index}".l([metadata]),
      Messages.promote => "message_${type.index}".l([text, metadata]),
      Messages.demote => "message_${type.index}".l([text, metadata]),
      Messages.inviteAcceptMessage => "message_${type.index}".l([metadata]),
      Messages.newMember => "message_${type.index}".l([metadata]),
      Messages.donate =>
        "message_${type.index}".l([metadata, intData[1].compact()]),
      Messages.kick => "message_${type.index}".l([text, metadata]),
      Messages.pin => "message_${type.index}".l(["'${text.truncate(32)}'"]),
      _ => "message_${type.index}".l(),
    };
  }

  dynamic decideTribeRequest(BuildContext context, int tribeId, bool isAccept,
      [int? requesterId]) async {
    try {
      var params = {
        "req_id": id,
        "tribe_id": tribeId,
        "decision": isAccept ? "approve" : "reject"
      };
      if (requesterId != null) params["new_member_id"] = requesterId;
      var data = await getService<HttpConnection>(context).tryRpc(context,
          requesterId != null ? RpcId.tribeDecideJoin : RpcId.tribeDecideInvite,
          params: params);
      return data;
    } catch (e) {
      return null;
    }
  }
}
