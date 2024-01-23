import 'package:flutter/material.dart';

class Messages extends ValueNotifier<List<Message>> {
  Messages(super.value);

  void add(Message message) {
    value.insert(0, message);
    notifyListeners();
  }

  void replace(ChoiceMessage message) {
    // var index = value.indexOf(message);
    // value[index] = message;
    notifyListeners();
  }
}

class Message {
  final String sender;
  final String text;
  final int creationDate;
  bool itsMe = false;
  Message(this.sender, this.text, this.creationDate);
}

class ChoiceMessage extends Message {
  final List<Map<String, dynamic>> choices;
  ChoiceMessage(super.sender, super.text, super.creationDate, this.choices)
      : super();
}
