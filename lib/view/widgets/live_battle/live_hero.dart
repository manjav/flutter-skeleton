import 'package:flutter/material.dart';

import '../../../data/core/account.dart';
import '../../../data/core/card.dart';
import '../../../services/deviceinfo.dart';
import '../../items/card_item.dart';
import '../../key_provider.dart';

class LiveHero extends StatelessWidget with KeyProvider {
  final Account account;
  final double alignment;
  final ValueNotifier<List<AccountCard?>> deployedCards;
  LiveHero(this.account, this.alignment, this.deployedCards, {super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: deployedCards,
        builder: (context, value, child) {
          if (deployedCards.value[2] == null) {
            return const SizedBox();
          }
          var vAlign = value[2]!.isDeployed ? alignment - 0.1 : alignment;
          return AnimatedAlign(
            alignment: Alignment(0, vAlign),
            duration: const Duration(milliseconds: 700),
            child: CardItem.getHeroAnimation(deployedCards.value[2]!, 320.d,
                key: getGlobalKey(deployedCards.value[2]!.id)),
          );
        });
  }
}
