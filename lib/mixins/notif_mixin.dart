import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../app_export.dart';

mixin NotifMixin<T extends AbstractScreen> on State<T> {
  static Map<GlobalKey<NotifState>, OverlayEntry> notifications = {};

  void showNotif(
    NoobMessage message, {
    required String title,
    required String caption,
    int mode = 0,
  }) {
    var key = GlobalKey<NotifState>();
    var notif = Notif(
      key: key,
      message: NotifData(
        message: message,
        title: title,
        caption: caption,
        mode: mode,
      ),
      bottom: 400.d,
      onClose: () {
        key.currentState?.remove();
        notifications.remove(key);
        _animateNotifications();
      },
      //todo: comment for now we need to fix it
      // onTap: () => onNotifTap(message),
    );
    var entry = OverlayEntry(
      builder: (ctx) => notif,
    );

    notifications[key] = entry;

    Overlay.of(context).insert(entry);
    _animateNotifications();
  }

  void _animateNotifications() {
    int index = 0;
    for (var entry in notifications.keys) {
      var add = ((notifications.length - 1 - index) * 150.d);
      var bottom = 400.d + add;
      entry.currentState?.changePosition(bottom);
      index++;
    }
  }

  void onNotifTap(NoobMessage message) {
    var account = context.read<AccountProvider>().account;
    if (message is NoobHelpMessage) {
      showConfirmOverlay(
          "tribe_help".l([message.attackerName, message.defenderName]),
          () => _onAcceptHelp(message, account));
      return;
    }
    if (message is NoobRequestBattleMessage) {
      showConfirmOverlay("battle_request".l([message.attackerName]),
          () => _onAcceptAttack(message, account));
      return;
    }
  }

  void showConfirmOverlay(String message, Function() onAccept) {
    Overlays.insert(
        context,
        ConfirmOverlay(
          message,
          "accept_l".l(),
          "decline_l".l(),
          onAccept,
          barrierDismissible: false,
        ));
    Timer(const Duration(seconds: 10),
        () => Overlays.remove(OverlaysName.confirm));
  }

  _onAcceptAttack(NoobRequestBattleMessage request, Account account) async {
    try {
      var result = await context
          .read<ServicesProvider>()
          .get<HttpConnection>()
          .tryRpc(context, RpcId.battleDefense,
              params: {"battle_id": request.id, "choice": 1});

      _joinBattle(
          request.id,
          account,
          Opponent.create(request.attackerId, request.attackerName, account.id),
          result["help_cost"],
          result["created_at"]);
    } finally {}
  }

  _onAcceptHelp(NoobHelpMessage help, Account account) async {
    var attacker =
        Opponent.create(help.attackerId, help.attackerName, account.id);
    var defender =
        Opponent.create(help.defenderId, help.defenderName, account.id);
    getFriend() => help.isAttacker ? attacker : defender;
    getOpposite() => help.isAttacker ? defender : attacker;

    var result = await context
        .read<ServicesProvider>()
        .get<HttpConnection>()
        .tryRpc(context, RpcId.battleJoin,
            params: {"battle_id": help.id, "mainEnemy": getOpposite().id});

    if (!mounted) return;
    _joinBattle(help.id, getFriend(), getOpposite(), 0, result["created_at"]);
    _addBattleCard(account, result, help.attackerId, "attacker_cards_set");
    _addBattleCard(account, result, help.defenderId, "defender_cards_set");
  }

  _addBattleCard(Account account, result, int attackerId, String side) async {
    var noobSocket = context.read<ServicesProvider>().get<NoobSocket>();

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
    context
        .read<ServicesProvider>()
        .get<RouteService>()
        .to(Routes.liveBattle, args: args);
  }
}
