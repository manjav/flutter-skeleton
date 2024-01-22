import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../app_export.dart';

class LoadingController extends GetxController with ServiceFinderMixin {
  @override
  Future<void> onReady() async {
    super.onReady();

    var context = Get.context!;

    var services = getServices(context);
    var accountProvider = context.read<AccountProvider>();

    Overlays.insert(
      Get.overlayContext!,
      const LoadingOverlay(),
    );

    var route = RouteService();
    route.pages = [
      SkeletonPageModel(page: HomeScreen(), route: Routes.home, isOpaque: true),
      SkeletonPageModel(page: DeckScreen(), route: Routes.deck, isOpaque: true),
      SkeletonPageModel(
          page: QuestScreen(), route: Routes.quest, isOpaque: true),
      SkeletonPageModel(
          page: AttackOutScreen(
            Routes.questOut,
          ),
          route: Routes.questOut,
          isOpaque: true),
      SkeletonPageModel(
          page: AttackOutScreen(
            Routes.battleOut,
          ),
          route: Routes.battleOut,
          isOpaque: true),
      SkeletonPageModel(
          page: LiveOutScreen(), route: Routes.liveBattleOut, isOpaque: true),
      SkeletonPageModel(
          page: LiveBattleScreen(), route: Routes.liveBattle, isOpaque: true),
      SkeletonPageModel(
        page: CardDetailsPopup(),
        route: Routes.popupCardDetails,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: CardEnhancePopup(),
        route: Routes.popupCardEnhance,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: CardEvolvePopup(),
        route: Routes.popupCardEvolve,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: HeroEvolvePopup(),
        route: Routes.popupHeroEvolve,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: CollectionPopup(),
        route: Routes.popupCollection,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: CardSelectPopup(),
        route: Routes.popupCardSelect,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: MessagePopup(),
        route: Routes.popupMessage,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: LeaguePopup(),
        route: Routes.popupLeague,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: RankingPopup(),
        route: Routes.popupRanking,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: OpponentsPopup(),
        route: Routes.popupOpponents,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: SupportiveBuildingPopup(),
        route: Routes.popupSupportiveBuilding,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: MineBuildingPopup(),
        route: Routes.popupMineBuilding,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: TreasuryBuildingPopup(),
        route: Routes.popupTreasuryBuilding,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: PotionPopup(),
        route: Routes.popupPotion,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: ComboPopup(),
        route: Routes.popupCombo,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: HeroPopup(1),
        route: Routes.popupHero,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: InboxPopup(),
        route: Routes.popupInbox,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: ProfilePopup(-1),
        route: Routes.popupProfile,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: ProfileEditPopup(),
        route: Routes.popupProfileEdit,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: ProfileAvatarsPopup(),
        route: Routes.popupProfileAvatars,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: SettingsPopup(),
        route: Routes.popupSettings,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: RestorePopup(),
        route: Routes.popupRestore,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: InvitePopup(),
        route: Routes.popupInvite,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: RedeemGiftPopup(),
        route: Routes.popupRedeemGift,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: DailyGiftPopup(),
        route: Routes.popupDailyGift,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: TribeDetailsPopup(),
        route: Routes.popupTribeOptions,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: TribeInvitePopup(),
        route: Routes.popupTribeInvite,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: TribeEditPopup(),
        route: Routes.popupTribeEdit,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: TribeDonatePopup(),
        route: Routes.popupTribeDonate,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: SelectCardTypePopup(),
        route: Routes.popupCardSelectType,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: SelectCardCategoryPopup(),
        route: Routes.popupCardSelectCategory,
        isOpaque: false,
        type: RouteType.popup,
      ),
    ];
    services.addService(route);

    var deviceInfo = DeviceInfo();
    deviceInfo.initialize();
    services.addService(deviceInfo);

    var themes = Themes();
    themes.initialize();
    services.addService(themes);

    var localization = Localization();
    await localization.initialize(args: [context]);
    services.addService(localization);

    var firebase = FirebaseAnalytics.instance;

    var trackers = Trackers(firebase);
    await trackers.initialize();
    services.addService(trackers);
    
    try {
      var httpConnection = HttpConnection();
      var data = await httpConnection.initialize() as LoadingData;
      services.addService(httpConnection);

      trackers.sendUserData("${data.account.id}", data.account.name);

      if (context.mounted) {
        accountProvider.initialize(data.account);

        var noobSocket = NoobSocket();
        noobSocket.initialize(
            args: [data.account, context.read<OpponentsProvider>()]);
        services.addService(noobSocket);

        services.changeState(ServiceStatus.initialize);

        var inbox = Inbox();
        inbox.initialize(args: [context,data.account]);
        services.addService(inbox);

        var notifications = Notifications();
        notifications.initialize(
            args: ["${data.account.id}", data.account.getSchedules()]);
        services.addService(notifications);
      }
    } on SkeletonException catch (e) {
      if (context.mounted) {
        services.changeState(ServiceStatus.error, exception: e);
      }
    }

    var games = Games();
    games.initialize();
    services.addService(games);

    var ads = Ads();
    ads.initialize();
    ads.onUpdate = _onAdsServicesUpdate;
    services.addService(ads);

    var sounds = Sounds();
    sounds.initialize();
    sounds.playMusic();
    services.addService(sounds);
    services.changeState(ServiceStatus.complete);
  }

  _onAdsServicesUpdate(Placement? placement) {
    var sounds = getService<Sounds>(Get.context!);
    if (Pref.music.getBool()) {
      if (placement!.state == AdState.show) {
        sounds.stopAll();
      } else if (placement.state == AdState.closed ||
          placement.state == AdState.failedShow) {
        sounds.playMusic();
      }
    }
  }
}
