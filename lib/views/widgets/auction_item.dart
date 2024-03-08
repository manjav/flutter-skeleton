import 'package:flutter/material.dart';

import '../../app_export.dart';

class AuctionItem extends StatefulWidget {
  final AuctionCard card;
  final int selectedTab;
  final VoidCallback? onBid;
  const AuctionItem({
    required this.card,
    required this.selectedTab,
    this.onBid,
    super.key,
  });

  @override
  State<AuctionItem> createState() => _AuctionItemState();
}

class _AuctionItemState extends State<AuctionItem> {
  int remainingSeconds = 0;

  @override
  initState() {
    int secondsOffset = 24 * 3600 - DateTime.now().secondsSinceEpoch;
    remainingSeconds = widget.card.createdAt + secondsOffset;
    Future.delayed(Duration(seconds: remainingSeconds), () {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var account = serviceLocator<AccountProvider>().account;
    var cardSize = 240.d;
    var radius = Radius.circular(36.d);
    var bidable = widget.card.activityStatus > 0 &&
        (widget.card.ownerId != account.id) &&
        widget.card.maxBidderId != account.id;
    var refreshRate = remainingSeconds <= 0
        ? 24 * 3600
        : remainingSeconds <= 60
            ? 1
            : remainingSeconds < 3600
                ? 60
                : 24 * 3600;
    var imMaxBidder = widget.card.maxBidderId == account.id;
    return Widgets.button(context,
        radius: radius.x,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.all(8.d),
        color: imMaxBidder ? TColors.green40 : TColors.cream15,
        child: Row(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.ltr,
                  children: [
                    Asset.load<Image>("icon_gold", width: 60.d),
                    SizedBox(width: 8.d),
                    SkinnedText(widget.card.maxBid.compact(),
                        style: TStyles.large)
                  ]),
              Widgets.rect(
                  width: cardSize + 16.d,
                  padding: EdgeInsets.all(8.d),
                  child: CardItem(widget.card,
                      size: cardSize,
                      showCooldown: false,
                      // key: getGlobalKey(selectedTab * 10000 + card.id),
                      heroTag: "hero_${widget.selectedTab}_${widget.card.id}")),
            ],
          ),
          Expanded(
              child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                top: 0,
                right: 0,
                width: 200.d,
                height: 70.d,
                child: Widgets.rect(
                  borderRadius:
                      BorderRadius.only(topRight: radius, bottomLeft: radius),
                  color: TColors.black25,
                  child: StreamBuilder(
                    stream: Stream.periodic(
                      Duration(seconds: refreshRate),
                      (computationCount) => computationCount,
                    ),
                    builder: (context, snapshot) {
                      var time = widget.card.activityStatus > 0
                          ? (remainingSeconds - (snapshot.data ?? 0))
                              .toRemainingTime()
                          : "closed_l".l();
                      return SkinnedText("ˣ$time");
                    },
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 8.d,
                bottom: 12.d,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.d),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkinnedText("auction_owner".l(),
                          style: TStyles.small, textAlign: TextAlign.start),
                      SizedBox(
                        height: 4.d,
                      ),
                      Widgets.rect(
                        height: 50.d,
                        width: cardSize,
                        padding: EdgeInsets.symmetric(horizontal: 15.d),
                        borderRadius: BorderRadius.all(radius),
                        color: TColors.black25,
                        child: Row(
                          children: [
                            SkinnedText(
                              widget.card.maxBidderName,
                              style: TStyles.tiny,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 7.d,
                      ),
                      SkinnedText("auction_bid".l(),
                          style: TStyles.small, textAlign: TextAlign.start),
                      SizedBox(
                        height: 4.d,
                      ),
                      Widgets.rect(
                        height: 50.d,
                        width: cardSize,
                        padding: EdgeInsets.symmetric(horizontal: 15.d),
                        borderRadius: BorderRadius.all(radius),
                        color: TColors.black25,
                        child: Row(
                          children: [
                            SkinnedText(widget.card.maxBidderName,
                                style: TStyles.tiny)
                          ],
                        ),
                      ),
                      SizedBox(height: 17.d),
                      bidable
                          ? _getBidButton(widget.card, account, imMaxBidder)
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          )),
        ]));
  }

  _getBidButton(AuctionCard card, Account account, bool imMaxBidder) {
    if (imMaxBidder) {
      return SkinnedButton(
        padding: EdgeInsets.fromLTRB(21.d, 15.d, 12.d, 32.d),
        color: ButtonColor.teal,
        width: 240.d,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Asset.load<Image>("checkbox_on", width: 53.d),
              SizedBox(width: 12.d),
              SkinnedText(
                "auction_bid_leader".l(),
                style: TStyles.small,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
      );
    }
    return SkinnedButton(
      padding: EdgeInsets.fromLTRB(21.d, 15.d, 12.d, 32.d),
      color: ButtonColor.teal,
      onPressed: widget.onBid,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        textDirection: TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkinnedText(
            "Bid".l(),
            style: TStyles.medium,
          ),
          SizedBox(width: 12.d),
          Expanded(
            child: Widgets.rect(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.all(Radius.circular(21.d)),
              color: TColors.black25,
              child: SkinnedText("+${card.bidStep.compact()}",
                  style: TStyles.medium),
            ),
          ),
        ],
      ),
    );
  }
}
