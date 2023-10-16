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
class Message {
  List<int> intData = [];
  Messages type = Messages.none;
  String text = "", metadata = "";
  int id = 0, createdAt = 0, senderId = 0;

  Message(Map<String, dynamic> map, Account account) {
    id = map["id"];
    createdAt = map["created_at"];
    type = Messages.values[map["message_type"]];
    intData.add(Utils.toInt(map["intmetadata1"]));
    intData.add(Utils.toInt(map["intmetadata2"]));
    metadata = map["strmetadata"];
    senderId = map["sender_id"];
    text = map["text"];
  }

  static List<Message> initAll(List list, Account account) {
    var result = <Message>[];
    for (var map in list) {
      result.add(Message(map, account));
    }
    return result;
  }
}
