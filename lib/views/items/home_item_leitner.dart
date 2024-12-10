import 'package:flutter/material.dart';

import '../../app_export.dart';

class LeitnerPageItem extends AbstractHomePageItem {
  const LeitnerPageItem({super.key});
  @override
  State<LeitnerPageItem> createState() => _LeitnerPageItemState();
}

class _LeitnerPageItemState extends AbstractHomePageItemState<LeitnerPageItem> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [sliverAppBar()],
    );
  }
}
