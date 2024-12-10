import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class AbstractHomePageItem extends StatefulWidget {
  const AbstractHomePageItem({super.key});

  @override
  State<AbstractHomePageItem> createState() => AbstractHomePageItemState();
}

class AbstractHomePageItemState<T extends AbstractHomePageItem> extends State<T>
    with ILogger {
  @override
  Widget build(BuildContext context) => const Placeholder();

  Widget sliverAppBar() {
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 20.d,
      expandedHeight: 50.d,
      collapsedHeight: 28.d,
      shadowColor: TColors.black,
      backgroundColor: TColors.primary0,
      surfaceTintColor: TColors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(bottom: 4.d),
        centerTitle: true,
        title: Asset.load<SvgPicture>("logo_header", height: 48.d),
      ),
    );
  }

  Widget categoryTitle(String title, bool visible) {
    if (!visible) {
      return SizedBox();
    }
    return Padding(
      padding: EdgeInsets.only(top: 20.d),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20.d),
          Asset.load<SvgPicture>(title),
          SizedBox(width: 10.d),
          Text(title.l(), style: TStyles.medium),
        ],
      ),
    );
  }
}
