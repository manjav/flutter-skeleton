import '../../data/core/tribe.dart';
import '../../services/connection/noob_socket.dart';
import '../../services/localization.dart';
import '../../utils/utils.dart';
import 'account.dart';

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
}

extension MessagesExtenstion on Messages {
  bool get inTribe => switch (this) {
        Messages.joinTribeRequest ||
        Messages.promote ||
        Messages.demote ||
        Messages.newMember ||
        Messages.donate ||
        Messages.kick =>
          true,
        _ => false,
      };
}

class Message {
  List<int> intData = [];
  Messages type = Messages.none;
  String text = "", metadata = "";
  int id = 0, createdAt = 0, senderId = 0;

  Message(Map<String, dynamic> map, Account account) {
    id = map["id"];
    senderId = map["sender_id"];
    createdAt = map["created_at"];
    type = Messages.values[map["message_type"]];
    intData.add(Utils.toInt(map["intmetadata1"]));
    intData.add(Utils.toInt(map["intmetadata2"]));
    metadata = map["strmetadata"];
    senderId = map["sender_id"];
    text = map["text"];
    if (type.inTribe) {
      var tribe = account.get<Tribe?>(AccountField.tribe);
      if (tribe != null) {
        map["messageType"] = map["message_type"];
        map["creationDate"] = map["created_at"];
        var chat = NoobChatMessage(map, account);
        tribe.chat.add(chat);
      }
    }
    text = map["text"].isNotEmpty ? map["text"] : map["text_fa"];
  }

  static List<Message> initAll(List list, Account account) {
    var result = <Message>[];
    for (var map in list) {
      result.add(Message(map, account));
    }
    return result;
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
      Messages.pin => "message_${type.index}".l([text]),
      _ => "message_${type.index}".l(),
    };
  }

}
