import 'dart:async';
import 'package:flutter/widgets.dart';

import '../app_export.dart';

mixin NotifMixin<T extends AbstractScreen> on State<T> {
  onAcceptAttack(NoobRequestBattleMessage request, Account account) async {
    try {
      var result = await serviceLocator<HttpConnection>().tryRpc(
          context, RpcId.battleDefense,
          params: {"battle_id": request.id, "choice": 1});

      _joinBattle(
          request.id,
          account,
          Opponent.create(request.attackerId, request.attackerName, account.id),
          result["help_cost"],
          result["created_at"]);
    } finally {}
  }

  onAcceptHelp(NoobHelpMessage help, Account account) async {
    var attacker =
        Opponent.create(help.attackerId, help.attackerName, account.id);
    var defender =
        Opponent.create(help.defenderId, help.defenderName, account.id);
    getFriend() => help.isAttacker ? attacker : defender;
    getOpposite() => help.isAttacker ? defender : attacker;

    var result = await serviceLocator<HttpConnection>().tryRpc(
        context, RpcId.battleJoin,
        params: {"battle_id": help.id, "mainEnemy": getOpposite().id});

    if (!mounted) return;
    _joinBattle(help.id, getFriend(), getOpposite(), 0, result["created_at"]);
    _addBattleCard(account, result, help.attackerId, "attacker_cards_set");
    _addBattleCard(account, result, help.defenderId, "defender_cards_set");
  }

  _addBattleCard(Account account, result, int attackerId, String side) async {
    var noobSocket = serviceLocator<NoobSocket>();

    await Future.delayed(const Duration(milliseconds: 10));
    for (var element in result[side]) {
      element["owner_team_id"] = attackerId;
      var message = NoobCardMessage(account, element);
      noobSocket.dispatchMessage(message);
    }
  }

  void _joinBattle(int id, Opponent friendsHead, Opponent oppositesHead,
      [int helpCost = -1, int createAt = 0]) {
    var args = {
      "battle_id": id,
      "friendsHead": friendsHead,
      "oppositesHead": oppositesHead
    };
    if (helpCost > -1) {
      args["help_cost"] = helpCost;
    }
    if (createAt > 0) {
      args["created_at"] = createAt;
    }
    serviceLocator<RouteService>().to(Routes.liveBattle, args: args);
  }
}
