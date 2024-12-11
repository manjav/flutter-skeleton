import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class ProfilePageItem extends AbstractHomePageItem {
  const ProfilePageItem({super.key});

  @override
  State<ProfilePageItem> createState() => _ProfilePageItemState();
}

class _ProfilePageItemState extends AbstractHomePageItemState<ProfilePageItem> {
  @override
  Widget build(BuildContext context) {
    final account = serviceLocator<AccountProvider>();
    return CustomScrollView(
      slivers: [
        sliverAppBar(),
        _idBuilder(account),

  Widget _idBuilder(AccountProvider account) {
    var days = account.account.age.inDays;
    var lenPost = ["today_l", "yesterday_l", "days_ago"];
    return SliverToBoxAdapter(
      child: Column(
        children: [
          LoaderWidget(
              AssetType.vector, "avatar_${account.account.user.avatarUrl}"),
          SizedBox(height: 10.d),
          Text(
            account.account.user.displayName!.startsWith("u_")
                ? "You"
                : account.account.user.displayName!,
            style: TStyles.large,
          ),
          Text(
            "${"join_at".l()} ${days > 1 ? days : ''} ${lenPost[days.max(2)].l()}",
            style: TStyles.smallDetails,
          ),
        ],
      ),
    );
  }
    );
  }
}
