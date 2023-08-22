import 'package:flutter/material.dart';
import 'package:flutter_skeleton/services/theme.dart';

import '../../widgets.dart';

class LiveFriend extends StatefulWidget {
  const LiveFriend({super.key});

  @override
  State<LiveFriend> createState() => _LiveFriendState();
}

class _LiveFriendState extends State<LiveFriend> {
  @override
  Widget build(BuildContext context) {
    return Widgets.rect(color: TColors.accent);
  }
}
