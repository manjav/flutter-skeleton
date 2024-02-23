import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class LessonListenScreen extends AbstractScreen {
  LessonListenScreen({super.key}) : super(Routes.listen);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonListenScreen>
    with LessonMixin {
  bool _charByChar = false;
  List<Choice> _choices = [];
  List<String> _answers = [], _pattern = [];
  final ValueNotifier<int> _quizState = ValueNotifier(0);

  @override
  Future<void> nextStep(int index) async {
    if (index < scenario!.thread.length) {
      var chat = scenario!.thread[index].chats
          .where((c) => c.type == ChatType.user)
          .first;

      _pattern = chat.value.split(" ");
      _charByChar = _pattern.length < 2;
      if (_charByChar) {
        _pattern = switch (chat.value.length) {
          < 5 => chat.value.split(""),
          _ => chat.value.splitByLength(2),
        };
      }

      _choices = List.generate(_pattern.length, (i) => Choice(_pattern[i]));
      _choices.shuffle();
      _answers = [];
    }
    await super.nextStep(index);
  }

  @override
  void startQuiz(Chat chat) {
    _quizState.value = 0;
  }

  bool _chechAnswers() {
    for (var i = 0; i < _answers.length; i++) {
      if (_answers[i] != _pattern[i]) {
        return false;
      }
    }
    return true;
  }

  Future<void> _onQuizComplete() async {
    var isCorrect = _chechAnswers();
    if (isCorrect) {
      _quizState.value = -2;
      onQuizResult(true);
    } else {
      onQuizResult(false);
      _quizState.value = -1;
      await Future.delayed(const Duration(seconds: 1));
      _answers = [];
      for (var c in _choices) {
        c.used = false;
      }
      _quizState.value = 0;
    }
  }

  @override
  Widget footerBuilder() {
    var size = 80.d;
    var chat = currentTalk!.chats.where((c) => c.type == ChatType.user).first;
    return ValueListenableBuilder<int>(
      valueListenable: _quizState,
      builder: (context, value, child) => Padding(
        padding: EdgeInsets.all(8.d),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Widgets.button(
                  context,
                  radius: size,
                  width: size * 0.5,
                  height: size * 0.5,
                  color: TColors.primary10,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(12.d),
                  child: StreamBuilder(
                    stream: serviceLocator<Sounds>()
                        .getPlayer(chat.value)
                        .onPlayerStateChanged,
                    builder: (context, snapshot) => Asset.load<SvgPicture>(
                        snapshot.data == PlayerState.playing ? "stop" : "play",
                        width: size * 0.3),
                  ),
                  onPressed: () => serviceLocator<Speaker>()
                      .play(chat.value, narrator: chat.type.narrator),
                ),
                DirText(currentTalk!.chats.first.value),
              ],
            ),
            SizedBox(height: 8.d),
            _answerBox(),
            SizedBox(height: 8.d),
            _wrapper(_choices.length, _choiceItemBuilder),
          ],
        ),
      ),
    );
  }

  Widget _answerBox() {
    return Widgets.rect(
      radius: 20.d,
      color: TColors.primary10,
      padding: EdgeInsets.fromLTRB(16.d, 6.d, 6.d, 6.d),
      constraints: BoxConstraints.expand(height: 64.d),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _wrapper(_answers.length,
                  (i) => Text("${_answers[i]}${_charByChar ? "" : "  "}")),
            ),
          ),
          SizedBox(width: 8.d),
          _answers.isEmpty
              ? const SizedBox()
              : Widgets.button(
                  context,
                  width: 80.d,
                  color: switch (_quizState.value) {
                    -2 => TColors.green.withOpacity(0.2),
                    -1 => TColors.error.withOpacity(0.2),
                    _ => TColors.primary20,
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 14.d,
                    width: 13.d,
                    child: switch (_quizState.value) {
                      -2 => Asset.load<SvgPicture>("mic_success", width: 32.d),
                      -1 => Asset.load<SvgPicture>("mic_fail", width: 32.d),
                      _ => Asset.load<SvgPicture>("clear", width: 24.d),
                    },
                  ),
                  onPressed: () {
                    if (_quizState.value > -1) {
                      var last = _answers.removeLast();
                      _choices.lastWhere((c) => c.text == last).used = false;
                      _quizState.value = _answers.length;
                    }
                  },
                ),
        ],
      ),
    );
  }

  Widget _wrapper(
    int itemCount,
    Widget Function(int) itemBuilder,
  ) {
    return Wrap(
      children: [
        for (var i = 0; i < itemCount; i++) itemBuilder(i),
      ],
    );
  }

  Widget _choiceItemBuilder(int index) {
    var choice = _choices[index];
    return Widgets.button(
      context,
      padding: EdgeInsets.symmetric(horizontal: 12.d, vertical: 8.d),
      margin: EdgeInsets.all(3.d),
      color: choice.used ? TColors.primary20 : TColors.primary10,
      child: Opacity(opacity: choice.used ? 0 : 1, child: Text(choice.text)),
      onPressed: () {
        if (_quizState.value < 0 || choice.used) return;
        _answers.add(choice.text);
        _quizState.value = _answers.length;
        choice.used = true;
        if (_answers.length == _pattern.length) {
          _onQuizComplete();
        }
      },
    );
  }
}

class Choice {
  bool used = false;
  final String text;
  Choice(this.text);
}
