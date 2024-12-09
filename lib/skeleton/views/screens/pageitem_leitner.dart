import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app_export.dart';

class LeitnerPageItem extends StatefulWidget {
  const LeitnerPageItem({super.key});

  @override
  State<LeitnerPageItem> createState() => _LeitnerPageItemState();
}

class _LeitnerPageItemState extends State<LeitnerPageItem> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          toolbarHeight: 20.d,
          expandedHeight: 50.d,
          collapsedHeight: 28.d,
          surfaceTintColor: TColors.transparent,
          backgroundColor: TColors.primary0,
          pinned: true,
          shadowColor: TColors.black,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(bottom: 4.d),
            centerTitle: true,
            title: Asset.load<SvgPicture>("logo_header", height: 48.d),
          ),
        ),
      ],
    );
  }
}
