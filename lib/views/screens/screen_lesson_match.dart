import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class LessonMatchScreen extends AbstractScreen {
  LessonMatchScreen({super.key}) : super(Routes.match);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonMatchScreen> {
  @override
  void initState() {
    var content = Get.arguments["content"];
    steps = (content as GroupContent).words;
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
      alignment: Alignment.center,
      children: [
        MatchBox(
          mode: ButtonMode.text,
          choices: List.generate(
              steps.length,
              (i) => MatchVM(
                    i,
                    steps[i].targetValue,
                    steps[i].nativeValue,
                  )),
          onSelect: (text, isCorrect) => onQuizResult(context, isCorrect),
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

  Widget footerBuilder() => const SizedBox();
}
