import 'package:flutter/material.dart';

import '../../data/core/fruit.dart';
import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../key_provider.dart';
import '../widgets.dart';
import 'loaderwidget.dart';

class CardHolder extends StatefulWidget {
  final AccountCard? card;
  final bool heroMode;
  final bool showPower;
  final bool isLocked;
  final Function()? onTap;

  const CardHolder({
    this.card,
    this.heroMode = false,
    this.showPower = true,
    this.isLocked = false,
    this.onTap,
    super.key,
  });

  @override
  State<CardHolder> createState() => _CardHolderState();
}

class _CardHolderState extends State<CardHolder> with KeyProvider {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      widget.card == null || !widget.showPower
          ? const SizedBox()
          : Widgets.rect(
              padding: EdgeInsets.all(12.d),
              decoration: Widgets.imageDecore(
                  "deck_balloon",
                  ImageCenterSliceData(
                      50, 57, const Rect.fromLTWH(11, 11, 2, 2))),
              child: Text(widget.card!.power.compact(),
                  style: TStyles.mediumInvert)),
      Widgets.button(
          onPressed: () => widget.onTap?.call(),
          width: widget.heroMode ? 202.d : 184.d,
          height: widget.heroMode ? 202.d : 184.d,
          padding: EdgeInsets.all(12.d),
          decoration: Widgets.imageDecore(
              "deck_placeholder", ImageCenterSliceData(117, 117)),
          child: widget.card == null ? _emptyCard() : _filledCard())
    ]);
  }

  Widget _emptyCard() {
    var inside = "card";
    if (widget.isLocked) {
      inside = "lock";
    } else if (widget.heroMode) {
      inside = "hero";
    }
    return Padding(
        padding: EdgeInsets.all(24.d),
        child: Asset.load<Image>("deck_placeholder_$inside"));
  }

  Widget _filledCard() {
    var card = widget.card!;
    var name = card.base.isHero ? card.base.fruit.name : card.base.name;
    return LoaderWidget(AssetType.image, name,
        subFolder: "cards", key: getGlobalKey(card.id));
  }
}

class SelectedCards extends ValueNotifier<List<AccountCard?>> {
  SelectedCards(super.value);
  setAtCard(int index, AccountCard? card, {bool toggleMode = true}) {
    value[index] = toggleMode && value[index] == card ? null : card;
    notifyListeners();
  }

  getIds() =>
      "[${value.map((c) => c?.id).where((id) => id != null).join(',')}]";

  bool setCard(AccountCard card, {int exception = -1}) {
    var index = value.indexOf(card);
    if (index > -1) {
      setAtCard(index, null);
      return true;
    }

    for (var i = 0; i < value.length; i++) {
      if (i != exception && value[i] == null) {
        setAtCard(i, card);
        return true;
      }
    }

    var weakest = double.infinity;
    var weakestPosition = 3;
    for (var i = 0; i < value.length; i++) {
      if (i != exception && value[i]!.power < weakest) {
        weakest = value[i]!.power.toDouble();
        weakestPosition = i;
      }
    }
    setAtCard(weakestPosition, card);
    return false;
  }

  void addCard(AccountCard card) {
    if (value.contains(card)) {
      value.remove(card);
    } else {
      value.add(card);
    }
    notifyListeners();
  }

  void clear() {
    value.clear();
    notifyListeners();
  }

  void remove(AccountCard card) {
    value.remove(card);
    notifyListeners();
  }

  void removeWhere(bool Function(AccountCard?) test) {
    value.removeWhere(test);
    notifyListeners();
  }
}
