// import 'package:flutter/cupertino.dart';
// import 'package:looterking/src/data/infra.dart';
// import 'package:looterking/src/display/popups/popup.dart';
// import 'package:looterking/src/display/popups/rewards/levelup.dart';
// import 'package:looterking/src/services/services.dart';

// import '../../models/result.dart';

class Rules {}

// class Rules with ChangeNotifier {
//   late Resources resources;
//   var islands = <String, Island>{};
//   var wallet = Wallet();
//   var levels = <Level>[];
//   var orders = <int, Order>{};
//   var auctionRules = AuctionRules();
//   var storeData = <String, Bundle>{};

//   Map<String, dynamic> changes = {};

//   bool get isHintMode => wallet['_level'] < 3;
//   int get getAvailableOrderIndex {
//     var index = 0;
//     for (var order in orders.entries) {
//       if (has(order.value.bundle.incomes).response.isSuccess()) return index;
//       ++index;
//     }
//     return -1;
//   }

//   List<String> getFirstOrderMerge() {
//     for (var entry in orders.entries) {
//       for (var income in entry.value.bundle.incomes.keys) {
//         var req = resources[income]!.links.isEmpty
//             ? {income: 1}
//             : resources[income]!.links;
//         if (has(req).response.isSuccess()) {
//           return req.keys.toList();
//         }
//       }
//     }
//     return [];
//   }

//   load(dynamic data, Result<List> resourceData) {
//     // Init Islands
//     data["islands"].forEach((k, v) {
//       var origins = <String, Origin>{};
//       for (var origin in v['origins']) {
//         origins[origin] = Origin(origin);
//       }
//       islands[k] = Island(
//           v['index'],
//           k,
//           origins,
//           wallet['__$k'],
//           v['rarity'].toDouble(),
//           v['unlockAt'],
//           Bundle.fromData(v['bundle']),
//           Bundle.fromData(v['unlockBundle']),
//           GlobalKey());
//     });

//     // Init Levels
//     for (var level in data["levels"]) {
//       levels.add(Level(level['length'], Map.castFrom(level['rewards'])));
//     }

//     // Init Reources
//     resources = Resources(this);
//     for (var e in resourceData.data) {
//       var resource = Resource().fromDynamic(e, wallet["${e['id']}"]);
//       if (resource.island != null) {
//         ++islands[resource.island]!.itemCount;
//         if (wallet.containsKey(resource.type)) {
//           ++islands[resource.island]!.itemFoundCount;
//         }
//       }
//       resources[resource.type] = resource;
//     }

//     // Init Store data
//     for (var entry in data["storeData"].entries) {
//       storeData[entry.key] = Bundle.fromData(entry.value);
//     }

//     notifyListeners();
//   }

//   Result<Map<String, int>> exchange(Bundle bundle) {
//     var result = has(bundle.incomes);
//     if (result.response != Responses.success) {
//       return result;
//     }
//     bundle.incomes.forEach((key, value) {
//       wallet[key] = wallet[key] - value;
//       result.data[key] = -value;
//     });
//     bundle.outcomes.forEach((key, value) {
//       var has = wallet.containsKey(key);
//       if (!has && !key.startsWith('_')) {
//         resources[key]!.isNew = true;
//       }
//       var oldValue = has ? wallet[key] : 0;
//       wallet[key] = oldValue + value;
//       result.data[key] = value;
//     });
//     return result;
//   }

//   Result<Map<String, int>> has(Map<String, int> requirements) {
//     var lacks = <String, int>{};
//     var response = Responses.success;
//     requirements.forEach((key, value) {
//       if (!wallet.containsKey(key)) {
//         response = Responses.notFound;
//         lacks[key] = value;
//       } else {
//         var lack = value - wallet[key];
//         if (lack > 0) {
//           response = Responses.notEnough;
//           lacks[key] = lack;
//         }
//       }
//     });
//     return Result(response, "has", lacks);
//   }

//   List<int> getLevelBounaries(int level) {
//     var requiredXP = 0;
//     for (var i = 0; i < level - 1; i++) {
//       requiredXP += levels[i].length;
//     }
//     return [requiredXP, requiredXP + levels[level - 1].length];
//   }

//   checkLevelUp(BuildContext context, Services services) async {
//     var level = wallet['_level'];
//     var xp = wallet['_xp'];
//     var levelBoundaries = getLevelBounaries(level);
//     var distancce = xp - levelBoundaries[1];
//     if (distancce > -1 && !LevelupPopup.isActive) {
//       LevelupPopup.isActive = true;
//       await Popup.force(context, (ctx) => LevelupPopup(services, level + 1),
//           overlayMode: true, barrierDismissible: false);
//       LevelupPopup.isActive = false;
//     }
//   }

//   void notifyChanges({Map<String, dynamic>? args}) {
//     if (args != null) {
//       changes = args;
//     } else {
//       changes.clear();
//     }
//     notifyListeners();
//   }
// }
