import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:games_services/games_services.dart';

import 'core/iservices.dart';

abstract class IGameService extends IService {}

class GamesService extends IGameService {
  static const duration = Duration(seconds: 5);
  Timer? _timer;
  String? playerId;
  // String? playerToken;
  String? playerName;

  GamesService();
  // signIn({int timeoutSeconds = 10}) async {
  //   var checks = 0;
  //   getPlayerData();
  //   while (playerToken == null && checks < timeoutSeconds * 2) {
  //     await Future.delayed(const Duration(milliseconds: 500));
  //     ++checks;
  //   }
  //   return playerToken;
  // }

  signIn() async {
    try {
      if (Platform.isAndroid) {
        await GamesServices.signIn();
        playerId = await GamesServices.getPlayerID();
        playerName = await GamesServices.getPlayerName();
        // playerToken = await GamesServices.getPlayerToken();
      } else {
        playerId = '';
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return playerId;
  }

  submitScore(int score) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      _timer?.cancel();
      // GamesServices.submitScore(
      //     score: Score(
      //         androidLeaderboardID: 'leaderboard_android'.l(),
      //         iOSLeaderboardID: 'leaderboard_ios'.l(),
      //         value: score));
    });
  }

  bool showLeaderboards(String source) {
    // var analytics = analytics;
    // GamesServices.showLeaderboards();
    return true;
  }
}
