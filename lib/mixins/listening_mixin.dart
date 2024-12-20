import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app_export.dart';

mixin ListeningMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  ValueNotifier<bool> micProblemOccures = ValueNotifier(true);

  @override
  void initState() {
    // serviceLocator<ListenerQuiz>().state.addListener(
    //   () {
    //     if (serviceLocator<ListenerQuiz>().state.value == QuizState.error) {
    //       micProblemOccures.value = true;
    //     }
    //   },
    // );
    super.initState();
  }

  Widget microphoneBuilder(LessonController controller, Talk talk) {
    return Column(
      children: [
        Expanded(child: MicPanel(talk: talk)),
        ValueListenableBuilder(
          valueListenable: micProblemOccures,
          builder: (context, value, child) {
            return Widgets.button(context,
                height: 18.d,
                child: value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Asset.load<SvgPicture>("cant_speak"),
                          SizedBox(width: 8.d),
                          Text(
                            "cant_speak".l(),
                            style: TStyles.medium
                                .copyWith(color: TColors.primary20),
                          ),
                        ],
                      )
                    : SizedBox(),
                onPressed: () => _skipListening(controller));
          },
        )
      ],
    );
  }

  void listen(
    Talk talk, {
    MediaEntry? initialMedia,
    MediaEntry? finalMedia,
  }) {
    final account = serviceLocator<AccountProvider>();

    // Change fuzzy acceptance level based on answer length
    final pattern = talk.targetValue;
    var minMatchLevel = 95;
    if (pattern.length < 10) {
      minMatchLevel = 84;
    } else if (pattern.length < 20) {
      minMatchLevel = 88;
    } else if (pattern.length < 30) {
      minMatchLevel = 92;
    }

    final initalVoice = talk.getText(talk.textSide);
    initialMedia ??= (initalVoice.isNotEmpty
        ? MediaEntry(MediaType.voice, initalVoice)
        : null);
    finalMedia ??= talk.type != ContentType.repeat
        ? MediaEntry(MediaType.voice, talk.targetValue)
        : null;

    serviceLocator<ListenerQuiz>().prepare(
      talk: talk,
      finalMedia: finalMedia,
      initialMedia: initialMedia,
      minMatchLevel: minMatchLevel,
      locale: account.metadata["targetLanguage"],
      onResult: (state, text, score, repeated, data) => onQiuzResult(
        state,
        text,
        score,
        talk,
        repeated,
        data,
      ),
    );
  }

  void onQiuzResult(
    QuizState state,
    String text,
    int score,
    Talk talk,
    bool repeated,
    dynamic data,
  );

  Future<void> _skipListening(LessonController controller) async {
    await modal([
      _modalButton("stt_skip_technical"),
      _modalButton("stt_skip_not_now"),
      _modalButton("stt_skip_ever"),
    ], isDismissible: false);
    controller.changeSerie(1);
  }

  Widget _modalButton(String text) => Widgets.button(
        context,
        height: 56.d,
        alignment: Alignment.center,
        child: DirText(text.l(), style: TStyles.large),
        onPressed: () {
          ListenerQuiz.skipReason = text;
          Navigator.pop(context);
        },
      );
}
