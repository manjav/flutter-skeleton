import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  var steps = [
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
  ];

  ValueNotifier<bool> enableTouch = ValueNotifier(false);
  int index = -1;

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
            return Positioned(
              bottom: 550.d,
              width: Get.width,
              child: AnimatedOpacity(
                duration: 200.ms,
                opacity: account.account.tutorial_id == 0 ? 1.0 : 0,
                child: Widgets.rect(
                  color: TColors.black25,
                  padding:
                      EdgeInsets.symmetric(vertical: 20.d, horizontal: 70.d),
                  child: Column(
                    children: [
                      SkinnedText(
                        "Select your language",
                        style: TStyles.medium.copyWith(color: TColors.white),
                        hideStroke: true,
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
          }),
          TutorialCharacter(
            show: steps[0],
            text: "olive_says_that_we're_under_attack",
            dialogueSide: DialogueSide.right,
            characterName: "character_olive",
            bottom: 400.d,
          ),
          TutorialCharacter(
            show: steps[1],
            text: "sarhang_is_suprised",
            dialogueSide: DialogueSide.left,
            characterName: "character_sarhang",
            bottom: 400.d,
          ),
          TutorialCharacter(
            show: steps[2],
            text: "porteghula_enters",
            dialogueSide: DialogueSide.top,
            characterName: "character_porteghula",
            bottom: 400.d,
            dialogueHeight: 350.d,
            characterSize: Size(666.d, 859.d),
          ),
          TutorialCharacter(
            show: steps[3],
            text: "sarhang_asks_player_for_help",
            dialogueSide: DialogueSide.left,
            characterName: "character_sarhang",
            bottom: 400.d,
          ),
          ValueListenableBuilder(
            valueListenable: enableTouch,
            builder: (context, value, child) {
              if (!value) return const SizedBox();
              return Widgets.touchable(
                context,
                onTap: () async {
                  if (index == -1) return;
                  steps[index++].value = false;
                  if (index == 4) {
                    await accountProvider.updateTutorial(context, 1, 10);
                    Get.offNamed(Routes.deck);
                    return;
                  }
                  serviceLocator<AccountProvider>().update(
                      context, {"tutorial_index": index, "tutorial_id": index});
                  await Future.delayed(700.ms);
                  steps[index].value = true;
                },
              );
            },
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
                  width: 400.d,
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
        ],
      ),
    );
  }

  onSelectLanguage(Locale locale) async {
    Overlays.insert(
      context,
      IntroFeastOverlay(
        onClose: (data) {
          if (context.mounted) {
            serviceLocator<AccountProvider>()
                .update(context, {"tutorial_index": 1, "tutorial_id": 1});
            index = 0;
            enableTouch.value = true;
            steps[0].value = true;
          }
        },
      ),
    );
    Pref.language.setString(locale.languageCode);
    await serviceLocator<Localization>().changeLocal(locale);
    await Get.updateLocale(locale);
  }
}
