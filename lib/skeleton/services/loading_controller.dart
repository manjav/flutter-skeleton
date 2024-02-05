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
        page: const CardDetailsPopup(),
        route: Routes.popupCardDetails,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const CardEnhancePopup(),
        route: Routes.popupCardEnhance,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const CardEvolvePopup(),
        route: Routes.popupCardEvolve,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const HeroEvolvePopup(),
        route: Routes.popupHeroEvolve,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const CollectionPopup(),
        route: Routes.popupCollection,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const CardSelectPopup(),
        route: Routes.popupCardSelect,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const MessagePopup(),
        route: Routes.popupMessage,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const LeaguePopup(),
        route: Routes.popupLeague,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const RankingPopup(),
        route: Routes.popupRanking,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const OpponentsPopup(),
        route: Routes.popupOpponents,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const SupportiveBuildingPopup(),
        route: Routes.popupSupportiveBuilding,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const MineBuildingPopup(),
        route: Routes.popupMineBuilding,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const TreasuryBuildingPopup(),
        route: Routes.popupTreasuryBuilding,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const PotionPopup(),
        route: Routes.popupPotion,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const ComboPopup(),
        route: Routes.popupCombo,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const HeroPopup(1),
        route: Routes.popupHero,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const InboxPopup(),
        route: Routes.popupInbox,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const ProfilePopup(-1),
        route: Routes.popupProfile,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const ProfileEditPopup(),
        route: Routes.popupProfileEdit,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const ProfileAvatarsPopup(),
        route: Routes.popupProfileAvatars,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const SettingsPopup(),
        route: Routes.popupSettings,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const RestorePopup(),
        route: Routes.popupRestore,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const InvitePopup(),
        route: Routes.popupInvite,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const RedeemGiftPopup(),
        route: Routes.popupRedeemGift,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const DailyGiftPopup(),
        route: Routes.popupDailyGift,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const TribeDetailsPopup(),
        route: Routes.popupTribeOptions,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const TribeInvitePopup(),
        route: Routes.popupTribeInvite,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const TribeEditPopup(),
        route: Routes.popupTribeEdit,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const TribeDonatePopup(),
        route: Routes.popupTribeDonate,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const SelectCardTypePopup(),
        route: Routes.popupCardSelectType,
        isOpaque: false,
        type: RouteType.popup,
      ),
      SkeletonPageModel(
        page: const SelectCardCategoryPopup(),
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

    var trackers = Trackers();
    await trackers.initialize();
    services.addService(trackers);

    var sounds = Sounds();
    sounds.initialize();
    sounds.playMusic();
    services.addService(sounds);

    var eventNotification=EventNotification();
    eventNotification.initialize();
    services.addService(eventNotification);

    try {
      var httpConnection = HttpConnection();
      var data = await httpConnection.initialize() as LoadingData;
      services.addService(httpConnection);

      trackers.sendUserData("${data.account.id}", data.account.name);

      if (context.mounted) {
        accountProvider.initialize(data.account);

        var noobSocket = NoobSocket();
        noobSocket.initialize(
            args: [accountProvider, context.read<OpponentsProvider>()]);
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

      var games = Games();
      games.initialize();
      services.addService(games);

      var ads = Ads();
      ads.initialize();
      ads.onUpdate = _onAdsServicesUpdate;
      services.addService(ads);

      services.changeState(ServiceStatus.complete);
      
    } on SkeletonException catch (e) {
      if (context.mounted) {
        services.changeState(ServiceStatus.error, exception: e);
      }
    }
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
