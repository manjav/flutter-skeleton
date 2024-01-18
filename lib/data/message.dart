import 'package:flutter/material.dart';

class Message {
  String sender = "Ali";
  final String text;
  final int creationDate;
  get itsMe => false;
  Message({required this.text, this.creationDate = 0});
}

class Messages extends ValueNotifier<List<Message>> {
  Messages(super.value);

  void add(Message message) {
    value.insert(0, message);
    notifyListeners();
  }
}
