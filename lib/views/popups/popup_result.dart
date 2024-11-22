import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifetalk/app_export.dart';
import 'package:lifetalk/skeleton/mixins/feast_mixin.dart';
import 'package:rive/rive.dart';

class ResultScreen extends AbstractScreen {
  ResultScreen({super.key}) : super(Routes.popupResult);

  @override
  State<ResultScreen> createState() => _PopupState();
}

class _PopupState extends AbstractScreenState<ResultScreen> {
  String? message;

  @override
  List<Widget> appBarElementsLeft() => [];

  @override
  Widget contentFactory(double paddingTop) => GroupResult(args: widget.args);
}

class GroupResult extends StatefulWidget {
  final Map<String, dynamic> args;
  const GroupResult({super.key, required this.args});

  @override
  State<GroupResult> createState() => _GroupResultState();
}

class _GroupResultState extends State<GroupResult> with FeastMixin {
  StateMachineController? _controller;
  int _score = 0;
  int _scoreLevel = 60;
  SMIInput<double>? _scoreInput;
  final _scoresLevel = [100, 95, 90, 85, 70];

  @override
  void initState() {
    super.initState();
    children = [animationBuilder("result")];
    process(() async {
      int findLevel(int score) {
        for (var level in _scoresLevel) {
          if (_score >= level) return level;
        }
        return 60;
      }

      _score = widget.args["score"];
      _scoreLevel = findLevel(_score);
      return true;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    _controller = super.onRiveInit(artboard, stateMachineName);
    _scoreInput = _controller!.findInput<double>("icon");
    _scoreInput?.value = _score > 90 ? 1 : (_score < 70 ? 2 : 0);

    final formatter = NumberFormat("00");
    updateRiveText("message", "done_label".l());
    updateRiveText("scoreLabel", "score_level_$_scoreLevel".l());
    updateRiveText("scoreValue", formatter.format(_score));
    updateRiveText("sentencesLabel", "sentences_label".l());
    updateRiveText(
        "sentencesValue", formatter.format(widget.args["sentenceCount"]));
    return _controller!;
  }

  @override
  void dismiss() {
    super.dismiss();
    Navigator.pop(context);
  }
}
