import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/data/core/rpc.dart';
import 'package:flutter_skeleton/services/connection/http_connection.dart';
import 'package:flutter_skeleton/utils/utils.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services.dart';
import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/items/card_item_minimal.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/card_holder.dart';
import 'ipopup.dart';

class CardEnhancePopup extends AbstractPopup {
  const CardEnhancePopup({super.key, required super.args})
      : super(Routes.popupCardEnhance);

  @override
  createState() => _CardEnhancePopupState();
}

class _CardEnhancePopupState extends AbstractPopupState<CardEnhancePopup> {
  final _selectedCards = SelectedCards([]);
  late AccountCard _card;

  bool _isSacrificeAvailable = false;

  @override
  void initState() {
    _card = widget.args['card'];
    contentPadding = EdgeInsets.fromLTRB(24.d, 142.d, 24.d, 32.d);
    super.initState();
  }

  @override
  titleBuilder() => "card_enhance".l();

  @override
  Widget contentFactory() {
    var gap = 10.d;
    var crossAxisCount = 5;
    var itemSize =
        (DeviceInfo.size.width - gap * (crossAxisCount + 1)) / crossAxisCount;
    var cards = BlocProvider.of<AccountBloc>(context).account!.getReadyCards()
      ..remove(_card);
    cards.reverseRange(0, cards.length);
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: _selectedCards,
        builder: (context, value, child) {
          return SizedBox(
              width: 980.d,
              height: 1280.d,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                      bottom: 0,
                      right: -contentPadding.right,
                      left: -contentPadding.left,
                      height: 846.d,
                      child: Asset.load<Image>("ui_popup_bottom",
                          centerSlice: ImageCenterSliceDate(
                              200, 114, const Rect.fromLTWH(99, 4, 3, 3)))),
                  Positioned(
                      height: 838.d,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(64.d),
                              bottomRight: Radius.circular(64.d)),
                          child: GridView.builder(
                              itemCount: cards.length,
                              padding: EdgeInsets.fromLTRB(0, 32.d, 0, 220.d),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 0.74,
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: gap,
                                      mainAxisSpacing: gap),
                              itemBuilder: (c, i) =>
                                  _cardItemBuilder(c, i, cards[i], itemSize)))),
                  SizedBox(
                      width: 300.d,
                      child: MinimalCardItem(_card,
                          size: 300.d, extraPower: _getSacrificesPower())),
                  Positioned(
                      bottom: 0,
                      right: -contentPadding.right,
                      left: -contentPadding.left,
                      height: 200.d,
                      child: IgnorePointer(
                          ignoring: true,
                          child: Asset.load<Image>("ui_shade_bottom",
                              centerSlice: ImageCenterSliceDate(200, 165,
                                  const Rect.fromLTWH(98, 1, 3, 160))))),
                ],
              ));
        });
  }

  Widget? _cardItemBuilder(
      BuildContext context, int index, AccountCard card, double itemSize) {
    return Widgets.button(
        padding: EdgeInsets.zero,
        onPressed: () => _selectedCards.addCard(card),
        child: Stack(
          children: [
            MinimalCardItem(card, size: itemSize),
          ],
        ));
  }
