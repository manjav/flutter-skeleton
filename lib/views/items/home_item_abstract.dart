import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class AbstractHomePageItem extends StatefulWidget {
  const AbstractHomePageItem({super.key});

  @override
  State<AbstractHomePageItem> createState() => AbstractHomePageItemState();
}

class AbstractHomePageItemState<T extends AbstractHomePageItem> extends State<T>
    with ILogger, PopupsMixin, ServiceFinderWidgetMixin {
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
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 4.d),
        title: Asset.load<SvgPicture>("logo_header", height: 48.d),
      ),
    );
  }

  Widget header(String title, bool visible) {
    return SliverToBoxAdapter(
      child: visible
          ? Padding(
              padding: EdgeInsets.only(top: 24.d),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 20.d),
                  LoaderWidget(AssetType.vector, title),
                  SizedBox(width: 10.d),
                  Text(title.l(), style: TStyles.large),
                ],
              ),
            )
          : SizedBox(),
    );
  }
}
