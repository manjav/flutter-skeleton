import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class LessonIntroScreen extends AbstractScreen {
  LessonIntroScreen({super.key}) : super(Routes.intro);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonIntroScreen> {
  String title = "";
  @override
  void initState() {
    steps = Get.arguments["content"].children;
    changeStep(context, 0);
    super.initState();
  }

  @override
  List<Widget> appBarElementsLeft() => [];

  @override
  Widget contentFactory(double paddingTop) {
    if (steps.isEmpty) {
      return const SizedBox();
    }

    var padding = 12.d;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: ListenableBuilder(
        listenable: index,
        builder: (context, child) {
          Talk step = steps[index.value] as Talk;
          return Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: const Alignment(0, -0.5),
                child: DirText(
                  title,
                  style: TStyles.big,
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.1),
                child: DirText(
                  step.nativeValue,
                  textAlign: TextAlign.center,
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.1),
                child: _mainContent(step),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: headerBuilder(
                    context,
                    index,
                    EdgeInsets.fromLTRB(padding, padding, padding, 0),
                    Get.arguments["content"].title,
                    steps),
              ),
              Positioned(
                right: padding,
                bottom: padding,
                height: 44.d,
                child: SkinnedButton(
                  isEnable: index.value < steps.length - 1,
                  label: ">",
                  onPressed: () => changeStep(context, 1),
                ),
              ),
              Positioned(
                left: padding,
                bottom: padding,
                height: 44.d,
                child: SkinnedButton(
                  isEnable: index.value > 0,
                  label: "<",
                  onPressed: () => changeStep(context, -1),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _mainContent(Talk talk) {
    if (talk.personId == "card") {
      return ListenerBox(talk);
    }
    return SpeakerBox(
      narrator: Narrator.onyx,
      value: talk.nativeValue,
    );
  }

  @override
  Future<void> changeStep(BuildContext context, int step) async {
    var index = (this.index.value + step).clamp(0, steps.length);

    // serviceLocator<Sounds>().stopAll();
    var talk = steps[index] as Talk;

    if (talk.personId == "name") {
      title = talk.targetValue;
    }
    this.index.value = index;
    serviceLocator<Speaker>().play(
        talk.personId == "name" ? talk.targetValue : talk.nativeValue,
        narrator: talk.personId == "name" ? Narrator.nova : Narrator.onyx);
    if (talk.personId != "card") return;

    var account = serviceLocator<AccountProvider>();
    serviceLocator<STT>().start(
      locale: account.metadata["targetLanguage"],
      pattern: talk.targetValue,
      exceptions: [account.account.user.displayName!.simple()],
      onResult: _onQuizResult,
    );
  }

  Future<void> _onQuizResult(QuizState state, String text) async {
    const duration = Duration(milliseconds: 1500);
    serviceLocator<STT>().stop();
    if (state == QuizState.success) {
      await Future.delayed(duration);
      serviceLocator<STT>().state.value = QuizState.none;
      if (mounted) {
        onStepResult(context, true);
      }
    } else if (state == QuizState.fail) {
      onStepResult(context, false);
      await Future.delayed(duration);
      serviceLocator<STT>().start();
    }
  }

  Widget footerBuilder() => const SizedBox();
}
