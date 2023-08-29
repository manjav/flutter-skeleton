import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/services_bloc.dart';
import '../../../data/core/card.dart';
import '../../../data/core/rpc.dart';
import '../../../services/connection/http_connection.dart';
import '../../../services/deviceinfo.dart';
import '../../../services/theme.dart';
import '../../items/card_item.dart';
import '../../key_provider.dart';
import '../../screens/screen_livebattle.dart';

class LiveHero extends StatefulWidget {
  final int battleId;
  final double alignment;
  final LiveCardsData deployedCards;

  const LiveHero(this.battleId, this.alignment, this.deployedCards, {super.key});

  @override
  State<LiveHero> createState() => _LiveHeroState();
}

class _LiveHeroState extends State<LiveHero>
    with  KeyProvider {

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: widget.deployedCards,
        builder: (context, value, child) {
          if (value[4] == null) {
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
