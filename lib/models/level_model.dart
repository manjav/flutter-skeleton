// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

abstract class Level {
  final Color color;
  final String? title;
  final String imageUrl;
  final int reward;

  Level(
      {this.title,
      this.color = Colors.white,
      this.imageUrl = "",
      this.reward = 0});
}

class PassedLevel extends Level {
  PassedLevel({super.title})
      : super(color: Colors.orange, imageUrl: "assets/images/passed1.png");
}

class RewardLevel extends Level {
  RewardLevel({super.title})
      : super(color: Colors.red, imageUrl: "assets/images/gold.png");
}

class ActiveLevel extends Level {
  ActiveLevel({super.title})
      : super(color: Colors.greenAccent, imageUrl: "assets/images/active.png");
}

class LockedLevel extends Level {
  LockedLevel({super.title})
      : super(color: Colors.grey, imageUrl: "assets/images/deactive.png");
}
