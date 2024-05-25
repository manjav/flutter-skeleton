import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'app_export.dart';

class MyApp extends StatefulWidget {
  static late final DateTime startTime;
  const MyApp({super.key});

  static final firebaseAnalytics = FirebaseAnalytics.instance;
  static final _observer =
      FirebaseAnalyticsObserver(analytics: firebaseAnalytics);

  @override
  createState() => _MyAppState();

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()?.restartApp();
  }
}

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver, ServiceFinderWidgetMixin {
  UniqueKey? key;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      serviceLocator<Sounds>().pauseAll();
    } else if (state == AppLifecycleState.resumed) {
      serviceLocator<Sounds>().playMusic();
    }
  }

  void restartApp() async {
    Overlays.clear();
    LoaderWidget.cachedLoaders.clear();

    Get.reset(clearRouteBindings: true);

    serviceLocator<Sounds>().stopAll();
    await serviceLocator.reset();
    initServices();

    if (mounted) if (Navigator.canPop(context)) Navigator.pop(context);
    _initialize(true);
  }

  _initialize([bool forced = false]) async {
    if (key == null || forced) {
      key = UniqueKey();
    }
    var result = await DeviceInfo.preInitialize(context, forced);
    if (result) {
      Themes.preInitialize();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialize();
    if (!DeviceInfo.isPreInitialized) return const SizedBox();
    return KeyedSubtree(
      key: key,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => serviceLocator<AccountProvider>()),
          ChangeNotifierProvider(
              create: (_) => serviceLocator<OpponentsProvider>())
        ],
        child: GetMaterialApp(
          navigatorObservers: [MyApp._observer],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: Localization.locales,
          theme: Themes.darkData,
          locale: Localization.locales.firstWhere((l) =>
              l.languageCode == Pref.language.getString(defaultValue: 'en')),
          initialRoute: Routes.home,
          textDirection: Localization.dir,
          getPages: [
            _getPage(Routes.home, () => HomeScreen()),
            _getPage(Routes.deck, () => DeckScreen()),
            _getPage(Routes.quest, () => QuestScreen()),
            _getPage(Routes.liveBattleOut, () => LiveOutScreen()),
            _getPage(Routes.liveBattle, () => LiveBattleScreen()),
            _getPage(Routes.intro, () => IntroScreen()),
            _getPage(Routes.popupCardDetails, () => const CardDetailsPopup(),false,Transition.fadeIn),
            _getPage(Routes.popupCardEnhance, () => const CardEnhancePopup()),
            _getPage(Routes.popupCardEvolve, () => const CardEvolvePopup()),
            _getPage(Routes.popupHeroEvolve, () => const HeroEvolvePopup()),
            _getPage(Routes.popupCollection, () => const CollectionPopup()),
            _getPage(Routes.popupCardSelect, () => const CardSelectPopup()),
            _getPage(Routes.popupMessage, () => const MessagePopup()),
            _getPage(Routes.popupLeague, () => const LeaguePopup()),
            _getPage(Routes.popupRanking, () => const RankingPopup()),
            _getPage(Routes.popupOpponents, () => const OpponentsPopup()),
            _getPage(Routes.popupSupportiveBuilding, () => const SupportiveBuildingPopup()),
            _getPage(Routes.popupMineBuilding, () => const MineBuildingPopup()),
            _getPage(Routes.popupTreasuryBuilding, () => const TreasuryBuildingPopup()),
            _getPage(Routes.popupPotion, () => const PotionPopup()),
            _getPage(Routes.popupCombo, () => const ComboPopup()),
            _getPage(Routes.popupHero, () => const HeroPopup()),
            _getPage(Routes.popupInbox, () => const InboxPopup()),
            _getPage(Routes.popupProfile, () => const ProfilePopup()),
            _getPage(Routes.popupProfileEdit, () => const ProfileEditPopup()),
            _getPage(Routes.popupProfileAvatars, () => const ProfileAvatarsPopup()),
            _getPage(Routes.popupSettings, () => const SettingsPopup()),
            _getPage(Routes.popupRestore, () => const RestorePopup()),
            _getPage(Routes.popupInvite, () => const InvitePopup()),
            _getPage(Routes.popupRedeemGift, () => const RedeemGiftPopup()),
            _getPage(Routes.popupDailyGift, () => const DailyGiftPopup()),
            _getPage(Routes.popupTribeOptions, () => const TribeDetailsPopup()),
            _getPage(Routes.popupTribeInvite, () => const TribeInvitePopup()),
            _getPage(Routes.popupTribeEdit, () => const TribeEditPopup()),
            _getPage(Routes.popupTribeDonate, () => const TribeDonatePopup()),
            _getPage(Routes.popupCardSelectType, () => const SelectCardTypePopup()),
            _getPage(Routes.popupCardSelectCategory, () => const SelectCardCategoryPopup()),
            _getPage(Routes.popupChooseName, () => const ChooseNamePopup()),
            _getPage(Routes.popupHelp, () => const HelpPopup()),
            _getPage(Routes.popupFreeGold, () => const FreeGoldPopup()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  GetPage<dynamic> _getPage(
    String routeName,
    page, [
    bool opaque = false,
    Transition transition = Transition.noTransition,
  ]) =>
      GetPage(
        name: routeName,
        page: page,
        opaque: opaque,
        transition: transition,
      );
}
