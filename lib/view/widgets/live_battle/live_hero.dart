import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/services_bloc.dart';
import '../../../data/core/card.dart';
import '../../../data/core/rpc.dart';
import '../../../services/connection/http_connection.dart';
import '../../../services/deviceinfo.dart';
import '../../../services/theme.dart';
import '../../../utils/assets.dart';
import '../../items/card_item.dart';
import '../../key_provider.dart';
import '../../screens/screen_livebattle.dart';
import '../../widgets.dart';

class LiveHero extends StatefulWidget {
  final int battleId;
  final double alignment;
  final LiveCardsData deployedCards;

  const LiveHero(this.battleId, this.alignment, this.deployedCards, {super.key});

  @override
  State<LiveHero> createState() => _LiveHeroState();
}

class _LiveHeroState extends State<LiveHero>
    with TickerProviderStateMixin, KeyProvider {
  final List<bool> _enables = [true, true, true, true];
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: widget.deployedCards,
        builder: (context, value, child) {
          if (value[4] == null) {
            return const SizedBox();
          }
          var hero = value[4]!;
          var vAlign =
              hero.isDeployed ? widget.alignment - 0.1 : widget.alignment;
          return AnimatedContainer(
            alignment: Alignment(0, vAlign),
            duration: const Duration(milliseconds: 700),
            child: Stack(
              children: [
                CardItem.getHeroAnimation(hero, 320.d,
                    key: getGlobalKey(hero.id)),
                Positioned(
                  bottom: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: hero.isDeployed
                        ? [
                            _benefit(context, hero, 0, "power"),
                            _benefit(context, hero, 1, "cooldown"),
                            _benefit(context, hero, 2, "gold"),
                          ]
                        : [],
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _benefit(
      BuildContext context, AccountCard hero, int index, String type) {
    var isEnable = _enables[index] && _enables[3];
    return IgnorePointer(
      ignoring: isEnable,
      child: Widgets.button(
          padding: EdgeInsets.all(12.d),
          height: 120.d,
          child: Opacity(
              opacity: isEnable ? 1 : 0.5,
              child: Stack(
                children: [
                  Asset.load<Image>("benefit_$type"),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      if (_animationController.value >= 1) {
                        setState(() => _enables[3] = true);
                      }
                      return CircularProgressIndicator(
                          strokeWidth: 8.d,
                          strokeAlign: 0.9,
                          color: TColors.green,
                          value: _animationController.value);
                    },
                  )
                ],
              )),
          onPressed: () => _onPressed(context, hero, index)),
    );
  }

  _onPressed(BuildContext context, AccountCard hero, int index) async {
    try {
      var params = {
        RpcParams.battle_id.name: widget.battleId,
        RpcParams.hero_id.name: hero.id,
        RpcParams.ability_type.name: index + 1,
      };
       await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.battleSetCard, params: params);
      _enables[index] = false;
      _enables[3] = false;
      _animationController.value = 0;
      _animationController.animateTo(1, curve: Curves.easeInOut);
    } finally {}
  }
}
