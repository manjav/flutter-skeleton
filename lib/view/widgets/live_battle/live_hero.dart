import 'package:flutter/material.dart';

import '../../../data/core/fruit.dart';
import '../../../data/core/rpc.dart';
import '../../../mixins/key_provider.dart';
import '../../../mixins/service_provider.dart';
import '../../../services/device_info.dart';
import '../../../services/theme.dart';
import '../../../utils/assets.dart';
import '../../items/card_item.dart';
import '../../widgets.dart';
import '../card_holder.dart';

class LiveHero extends StatefulWidget {
  final int battleId;
  final double alignment;
  final SelectedCards deployedCards;

  const LiveHero(this.battleId, this.alignment, this.deployedCards,
      {super.key});

  @override
  State<LiveHero> createState() => _LiveHeroState();
}

class _LiveHeroState extends State<LiveHero>
    with TickerProviderStateMixin, KeyProvider, ServiceProviderMixin {
  final List<bool> _enables = [true, true, true, true];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _enables[3] = true);
      }
    });
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
                SizedBox(height: 360.d),
                CardItem.getHeroAnimation(hero, 320.d,
                    key: getGlobalKey(hero.id)),
                Positioned(
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
      ignoring: !isEnable,
      child: Widgets.button(
          padding: EdgeInsets.all(4.d),
          width: 100.d,
          height: 100.d,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: isEnable ? 1 : 0.6,
                child: Asset.load<Image>("benefit_$type",
                    width: _enables[index] ? 100.d : 80.d),
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  if (!_enables[index] || _animationController.value >= 1) {
                    return const SizedBox();
                  }
                  return CircularProgressIndicator(
                      strokeWidth: 8.d,
                      strokeAlign: -0.9,
                      color: TColors.primary10,
                      value: _animationController.value);
                },
              )
            ],
          ),
          onPressed: () => _onPressed(context, hero, index)),
    );
  }

  _onPressed(BuildContext context, AccountCard hero, int index) async {
    if (widget.battleId != 0) {
      try {
        var params = {
          RpcParams.battle_id.name: widget.battleId,
          RpcParams.hero_id.name: hero.id,
          RpcParams.ability_type.name: index + 1,
        };
        await rpc(RpcId.triggerAbility, params: params);
      } finally {}
    }
    _enables[index] = false;
    _enables[3] = false;
    setState(() {});
    _animationController.value = 0;
    _animationController.animateTo(1, curve: Curves.easeInOut);
  }
}
