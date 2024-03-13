import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class LessonWordScreen extends AbstractScreen {
  LessonWordScreen({super.key}) : super(Routes.word);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonWordScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    var content = Get.arguments["content"];
    steps = (content as GroupContent).words;
    steps.shuffle();
    nextStep(context);
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
    return Stack(
      children: [
        Positioned(
          left: padding,
          right: padding,
          top: paddingTop + padding + headerHeight,
          bottom: 400.d,
          child: PageView.builder(
            itemCount: steps.length,
            itemBuilder: _contentBuilder,
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
          ),
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
        ValueListenableBuilder(
          valueListenable: headerSize,
          builder: (context, value, child) {
            return AnimatedPositioned(
              left: 0,
              right: 0,
              top: DeviceInfo.size.height - value,
              curve: value == 0 ? Curves.easeIn : Curves.easeOutBack,
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: footerKey,
                decoration: BoxDecoration(
                  color: TColors.primary0,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.d),
                    topRight: Radius.circular(32.d),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TColors.primary20,
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, -2.d), // changes position of shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.all(padding),
                child: footerBuilder(),
              ),
            );
          },
        )
      ],
    );
  }

  @override
  updateContent() async {
    if (index.value < steps.length - 1) {
      _pageController.animateToPage(index.value + 1,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  @override
  Future<void> nextStep(BuildContext context) async {
    await super.nextStep(context);
    if (index.value < steps.length) {
      serviceLocator<Dictator>().initialize(args: [steps[index.value]]);
    }
  }

  @override
  void startQuiz(Content child) {
    serviceLocator<Dictator>().start(onResult: _onQuizResult);
  }

  Future<void> _onQuizResult(QuizState state, String value) async {
    var state = serviceLocator<Dictator>().state.value;
    if (state == QuizState.success) {
      onQuizResult(context, true);
    } else if (state == QuizState.fail) {
      onQuizResult(context, false);
      await Future.delayed(const Duration(seconds: 1));
      serviceLocator<Dictator>().reset();
    }
  }

  Widget _contentBuilder(BuildContext context, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text("word_hint".l()),
        index == 2
            ? SpeakerBox(
                value: steps[index].targetValue,
                narrator: steps[index].type.narrator,
                width: 100.d,
              )
            : Asset.load<Image>("ui_frame_wood_big"),
      ],
    );
  }

  Widget footerBuilder() {
    if (index.value >= steps.length) return const SizedBox();
    if (index.value < 3) {
      return ChoosingBox(
        mode: [
          ButtonMode.text,
          ButtonMode.voice,
          ButtonMode.image
        ][index.value],
        choices: List.from(steps),
        answer: steps[index.value].id,
        onSelect: (text, isCorrect) => onQuizResult(context, isCorrect),
      );
    }
    return const DictationBox();
  }
}
