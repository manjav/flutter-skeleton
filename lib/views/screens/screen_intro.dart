import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fruitcraft/app_export.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class IntroScreen extends AbstractScreen {
  IntroScreen({super.key}) : super(Routes.intro);

  @override
  createState() => _IntroScreenState();
}

class _IntroScreenState extends AbstractScreenState<IntroScreen> {
  @override
  appBarElementsLeft() => [];

  @override
  appBarElementsRight() => [];

  @override
  void onTutorialFinish(data) {
    Get.toNamed(Routes.deck);
    super.onTutorialFinish(data);
  }

  @override
  Widget contentFactory() {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          LoaderWidget(
            AssetType.image,
            "background_dust",
            subFolder: "backgrounds",
            height: Get.height,
            width: Get.width,
            fit: BoxFit.fill,
          ),
          Consumer<AccountProvider>(builder: (context, account, child) {
            if (account.account.tutorial_id < 1) return const SizedBox();
            return Positioned(
              top: 82.d,
              left: 59.d,
              child: AnimatedOpacity(
                duration: 200.ms,
                opacity: account.account.tutorial_id == 0 ? 0.0 : 1.0,
                child: SkinnedButton(
                  label: "already_have_a_village".l(),
                  width: 380.d,
                  onPressed: () async {
                    serviceLocator<RouteService>()
                        .to(Routes.popupRestore, args: {"onlySet": true});
                  },
                  color: ButtonColor.violet,
                ),
              ),
            );
          }),
          Consumer<AccountProvider>(builder: (context, account, child) {
            return Positioned(
              bottom: 550.d,
              width: Get.width,
              child: AnimatedOpacity(
                duration: 200.ms,
                opacity: account.account.tutorial_id == 0 ? 1.0 : 0,
                child: Widgets.rect(
                  color: TColors.black25,
                  padding: EdgeInsets.symmetric(vertical: 20.d, horizontal: 70.d),
                  child: Column(
                    children: [
                      Text(
                        "Select your language",
                        style: TStyles.medium.copyWith(color: TColors.white),
                      ),
                      SizedBox(
                        height: 39.d,
                      ),
                      SkinnedButton(
                        height: 150.d,
                        width: 650.d,
                        color: ButtonColor.green,
                        label: "English",
                        onPressed: () =>
                            onSelectLanguage(Localization.locales[0]),
                      ),
                      SizedBox(
                        height: 39.d,
                      ),
                      SkinnedButton(
                        height: 150.d,
                        width: 650.d,
                        color: ButtonColor.green,
                        label: "فارسی",
                        onPressed: () =>
                            onSelectLanguage(Localization.locales[1]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Consumer<AccountProvider>(builder: (context, account, child) {
            return AnimatedPositioned(
              duration: 300.ms,
              bottom: account.account.tutorial_id == 0 ? 200.d : -200.d,
              width: Get.width,
              child: LoaderWidget(
                AssetType.image,
                "logo",
                height: 140.d,
                width: 341.d,
              ),
            );
          })
        ],
      ),
    );
  }

  onSelectLanguage(Locale locale) async {
    await Get.updateLocale(locale);
    Pref.language.setString(locale.languageCode);
    await serviceLocator<Localization>().changeLocal(locale);
    if (context.mounted) {
      serviceLocator<AccountProvider>()
          .update(context, {"tutorial_index": 1, "tutorial_id": 1});
      checkTutorial();
    }
  }
}
