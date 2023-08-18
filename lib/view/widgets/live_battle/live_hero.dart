import 'package:flutter/material.dart';

import '../../../data/core/account.dart';
import '../../../data/core/card.dart';
import '../../../data/core/ranking.dart';
import '../../../services/deviceinfo.dart';
import '../../items/card_item.dart';
import '../../key_provider.dart';

class DeployHero extends StatelessWidget with KeyProvider {
  final Account account;
  final OpponentMode opponentMode;
  final ValueNotifier<List<AccountCard?>> deployedCards;
  DeployHero(this.account, this.opponentMode, this.deployedCards, {super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: deployedCards,
        builder: (context, value, child) {
          if (deployedCards.value[2] == null) {
            return const SizedBox();
          }
          return Align(
            alignment:
                Alignment(0, opponentMode == OpponentMode.allise ? 0.40 : -0.4),
            child: CardItem.getHeroAnimation(deployedCards.value[2]!, 320.d,
                key: getGlobalKey(deployedCards.value[2]!.id)),
          );
        });
  }
}
