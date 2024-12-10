import 'package:flutter/material.dart';

import '../../app_export.dart';

class ProfilePageItem extends AbstractHomePageItem {
  const ProfilePageItem({super.key});

  @override
  State<ProfilePageItem> createState() => _ProfilePageItemState();
}

class _ProfilePageItemState extends AbstractHomePageItemState<ProfilePageItem> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [sliverAppBar()],
    );
  }
}
