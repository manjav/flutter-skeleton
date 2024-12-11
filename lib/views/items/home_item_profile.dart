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
        header("header_stats", true),
        _statsBuilder(account),
      ],
    );
  }

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

  Widget _statsBuilder(AccountProvider account) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.d, vertical: 10.d),
        child: Row(
          children: [
            _statBuilder(
                "stats_questions", TColors.purpule, account.leitner.length),
            _statBuilder("stats_corrects", TColors.green,
                account.leitner.values.where((l) => l.lastScore > 50).length),
            _statBuilder("stats_videos", TColors.orange, account.scores.length),
          ],
        ),
      ),
    );
  }

  Widget _statBuilder(String label, Color color, int value) {
    return Expanded(
      child: Widgets.rect(
        margin: EdgeInsets.all(5.d),
        padding: EdgeInsets.all(10.d),
        height: 160.d,
        decoration: BoxDecoration(
            border: Border.all(color: TColors.primary10, width: 1.d),
            borderRadius: BorderRadius.all(Radius.circular(10.d))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            LoaderWidget(AssetType.vector, label, height: 50.d),
            Text(value.compact(), style: TStyles.large.copyWith(color: color)),
            Text(
              label.l(),
              style: TStyles.mediumDetails,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

    );
  }
}
