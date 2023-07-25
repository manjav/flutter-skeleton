import 'package:flutter/material.dart';

import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../widgets.dart';
import 'loaderwidget.dart';

class CardHolder extends StatefulWidget {
  final AccountCard? card;
  final Function()? onTap;
  final bool heroMode;
  final bool showPower;
  const CardHolder(
      {this.card,
      this.heroMode = false,
      this.onTap,
      super.key,
      this.showPower = true});

  @override
  State<CardHolder> createState() => _CardHolderState();
}

class _CardHolderState extends State<CardHolder> {
  @override
  Widget build(BuildContext context) {
    var balloonData =
        ImageCenterSliceDate(50, 57, const Rect.fromLTWH(11, 11, 2, 2));
    var slicingData = ImageCenterSliceDate(117, 117);
    return Column(children: [
      widget.card == null || !widget.showPower
          ? const SizedBox()
          : Widgets.rect(
              padding: EdgeInsets.all(12.d),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      centerSlice: balloonData.centerSlice,
                      image: Asset.load<Image>(
                        "deck_balloon",
                        centerSlice: balloonData,
                      ).image)),
              child: Text(widget.card!.power.compact(),
                  style: TStyles.mediumInvert)),
      Widgets.button(
          onPressed: () => widget.onTap?.call(),
          width: widget.heroMode ? 202.d : 184.d,
          height: widget.heroMode ? 202.d : 184.d,
          padding: EdgeInsets.all(12.d),
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  centerSlice: slicingData.centerSlice,
                  image: Asset.load<Image>(
                    "deck_placeholder",
                    centerSlice: slicingData,
                  ).image)),
          child: widget.card == null ? _emptyCard() : _filledCard())
    ]);
  }

  Widget _emptyCard() {
    return Padding(
        padding: EdgeInsets.all(24.d),
        child: Asset.load<Image>(
            "deck_placeholder_${widget.heroMode ? 'hero' : 'card'}"));
  }

  Widget _filledCard() {
    return LoaderWidget(
        AssetType.image, widget.card!.base.get<String>(CardFields.name),
        subFolder: "cards");
  }
}

class SelectedCards extends ValueNotifier<List<AccountCard?>> {
  SelectedCards(super.value);
  setAtCard(int index, AccountCard? card) {
    value[index] = card;
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
      if (i != exception && value[i] == null || i == value.length - 1) {
        setAtCard(i, card);
        return true;
      }
    }
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
}
