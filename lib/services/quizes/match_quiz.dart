import 'package:flutter/material.dart';

import '../../app_export.dart';

class MatchSide extends ChangeNotifier {
  final String value;
  MatchSide? pair;

  bool _isSelected = false;
  bool get isSelected => _isSelected;
  set isSelected(bool value) {
    _isSelected = value;
    notifyListeners();
  }

  bool _isEnable = true;
  bool get isEnable => _isEnable;
  set isEnable(bool value) {
    _isEnable = value;
    notifyListeners();
  }

  MatchSide(this.value);
}

class MatchQuiz extends Quiz {
  MatchSide? selectedSide;
  final List<MatchSide> lefts = [];
  final List<MatchSide> rights = [];

  @override
  void prepare({
    required Talk talk,
    MediaEntry? finalMedia,
    MediaEntry? initialMedia,
    Function(QuizState, String, int, bool, dynamic)? onResult,
  }) {
    super.prepare(
      talk: talk,
      onResult: onResult,
      finalMedia: finalMedia,
      initialMedia: initialMedia,
    );
    this.lefts.clear();
    this.rights.clear();
    final sections = talk.targetValue.split("∆");
    final lefts = sections.first.split("|");
    final rights = sections.last.split("|");
    final length = lefts.length.min(rights.length);
    for (var i = 0; i < length; i++) {
      final left = i < lefts.length ? MatchSide(lefts[i]) : null;
      final right = i < rights.length ? MatchSide(rights[i]) : null;
      if (left != null) {
        left.pair = right;
        this.lefts.add(left);
      }
      if (right != null) {
        right.pair = left;
        this.rights.add(right);
      }
    }
    this.lefts.shuffle();
    this.rights.shuffle();
    state.value = QuizState.ready;
  }

  Future<void> select(MatchSide side) async {
    if (selectedSide != null) {
      var isCorrect = selectedSide!.pair == side;
      if (isCorrect) {
        side.isEnable = selectedSide!.isEnable = false;
        if (lefts.where((c) => c.isEnable).isEmpty) {
          sendResult();
        } else if (rights.where((c) => c.isEnable).isEmpty) {
          sendResult();
        }
      }
      side.isSelected = selectedSide!.isSelected = false;
      selectedSide = null;
    } else {
      side.isSelected = true;
      selectedSide = side;
    }
  }

  Future<void> sendResult() async {
    state.value = QuizState.success;
    await Future.delayed(Duration(milliseconds: 400));

    lefts.clear();
    rights.clear();
    onResult?.call(state.value, "", 0, false, null);
  }
}
