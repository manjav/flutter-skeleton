import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../utils/assets.dart';
import '../../view/items/page_item.dart';
import '../../view/map_elements/building.dart';
import '../../view/widgets/loaderwidget.dart';
import '../../view/widgets/skinnedtext.dart';
import '../widgets.dart';

class MainMapItem extends AbstractPageItem {
  const MainMapItem({
    super.key,
  }) : super("battle");
  @override
  createState() => _MainMapItemState();
}

class _MainMapItemState extends AbstractPageItemState<AbstractPageItem> {
  @override
  Widget build(BuildContext context) {
    return Widgets.rect(
        color: const Color(0xffAA9A45),
        child:
            BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
          return Stack(children: [
            const LoaderWidget(AssetType.image, "map_main_bg",
                fit: BoxFit.fill, subFolder: "maps"),
            _building(BuildingType.cards, 167, 560),
            _building(BuildingType.tribe, 500, 500),
            _building(BuildingType.mine, 754, 699),
            _building(BuildingType.war, 45, 943),
            _building(BuildingType.battle, 400, 930),
            _building(BuildingType.shop, 773, 1040),
            _building(BuildingType.quest, 169, 1244),
            _building(BuildingType.message, 532, 1268),
            _button("battle", "battle_l", 150, 270, 442),
            _button("quest", "quest_l", 620, 270, 310),
          ]);
        }));
  }

  _button(String icon, String text, double x, double bottom, double width) {
    var bgCenterSlice = ImageCenterSliceDate(
        422, 202, const Rect.fromLTWH(85, 85, 422 - 85 * 2, 202 - 85 * 2));
    return Positioned(
        left: x.d,
        bottom: bottom.d,
        width: width.d,
        height: 202.d,
        child: Widgets.button(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  centerSlice: bgCenterSlice.centerSlice,
                  image: Asset.load<Image>(
                    'ui_button_map',
                    centerSlice: bgCenterSlice,
                  ).image)),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                  top: -80.d,
                  width: 148.d,
                  child: LoaderWidget(AssetType.image, "icon_$icon")),
              Positioned(bottom: 20.d, child: SkinnedText(text.l()))
            ],
          ),
        ));
  }
}

Widget _building(BuildingType type, double x, double y) {
  return Positioned(left: x.d, top: y.d, child: Building(type));
}
// reward would get added soon or later
// Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//   BlocBuilder<AccountBloc, AccountState>(
//     builder: (context, state) {
//       return RewardChess(
//           text: state.account
//               .get(AccountVar.bonus_remaining_time)
//               .toString());
//     },
//   )
// ]),
//   SizedBox(height: 30.d),
//   Expanded(
//     child: AspectRatio(
//       aspectRatio: 1,
//       child: BlocBuilder<AccountBloc, AccountState>(
//         builder: (context, state) {
//           return Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Building(battle, onTap: () {
//                 log("battle");
//               }),
//               const Building(data: MainMapElements.mine),
//               const Building(data: MainMapElements.shop),
//               const Building(data: MainMapElements.message),
//               Building(
//                 data: MainMapElements.quest,
//                 onTap: () {
//                   // Navigator.push(
//                   //     context,
//                   //     MaterialPageRoute(
//                   //         builder: (context) =>
//                   //             const QuestScreen()));
//                 },
//               ),
//               const Building(
//                 data: MainMapElements.millitary,
//               ),
//               const Building(
//                 data: MainMapElements.cards,
//               ),
//               const Building(
//                 data: MainMapElements.greenhouse,
//               ),
//             ],
//           );
//         },
//       ),
//     ),
//   ),
//   SizedBox(height: 40.d),
//   Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Widgets.touchable(
//           onTap: () {
//             // Navigator.push(
//             //     context,
//             //     MaterialPageRoute(
//             //         builder: (context) => const QuestScreen()
//             //         ));
//           },
//           child: SizedBox(
//             width: 300.d,
//             height: 200.d,
//             child: Expanded(
//               child: Stack(clipBehavior: Clip.none, children: [
//                 Asset.load<Image>(MainMapElements.battleBtn.url,
//                     width: 300.d),
//                 Align(
//                     alignment: const Alignment(0, 0.1),
//                     child: SkinnedText("Battle".l())

//                     //  StrockText(
//                     //     text: "battle".l(),
//                     //     frontSize: TStyles.medium.fontSize!)
//                     ),
//                 Align(
//                     alignment: const Alignment(0, -3),
//                     child: SizedBox(
//                       // color: Colors.red,
//                       width: 150.d,
//                       height: 150.d,
//                       child: Asset.load<Image>('icon_battle',
//                           width: 300.d),
//                     )),
//               ]),
//             ),
//           )),
//       SizedBox(width: 40.d),
//       Widgets.touchable(
//           onTap: () {
//             // Navigator.push(
//             //     context,
//             //     MaterialPageRoute(
//             //         builder: (context) => const QuestScreen()));
//           },
//           child: SizedBox(
//             width: 300.d,
//             height: 200.d,
//             child: Expanded(
//               child: Stack(clipBehavior: Clip.none, children: [
//                 Asset.load<Image>(MainMapElements.battleBtn.url,
//                     width: 300.d),
//                 Align(
//                     alignment: const Alignment(0, 0.1),
//                     child: SkinnedText("Quest".l())

//                     //  StrockText(
//                     //     text: "battle".l(),
//                     //     frontSize: TStyles.medium.fontSize!)
//                     ),
//                 Align(
//                     alignment: const Alignment(0, -3),
//                     child: SizedBox(
//                       // color: Colors.red,
//                       width: 150.d,
//                       height: 150.d,
//                       child: Asset.load<Image>('icon_quest',
//                           width: 300.d),
//                     )),
//               ]),
//             ),
//           )),
//     ],
//   ),
//   SizedBox(height: 40.d),
//   BlocBuilder<AccountBloc, AccountState>(
//       builder: (context, state) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         RankingElement(
//             backgroundImageUrl: MainMapElements.league.url,
//             text: state.account
//                 .get(AccountVar.league_rank)
//                 .toString(),
//             alignment: const Alignment(0.45, -0.07)),
//         RankingElement(
//             backgroundImageUrl: MainMapElements.tribe.url,
//             text: state.account.get(AccountVar.rank).toString(),
//             alignment: const Alignment(-0.45, -0.07)),
//       ],
//     );
//   }),
//   SizedBox(height: 250.d),