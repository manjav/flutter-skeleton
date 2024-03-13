import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lingai/app_export.dart';

class MatchBox extends StatefulWidget {
  final ButtonMode mode;
  final List<MatchVM> choices;
  final Function(String, bool)? onSelect;

  const MatchBox({
    required this.mode,
    required this.choices,
    this.onSelect,
    super.key,
  });

  @override
  State<MatchBox> createState() => _WidgetState();
}

class MatchVM {
  final int index;
  bool isEnable = true;
  final String key, value;
  MatchVM(this.index, this.key, this.value);
}

class _WidgetState extends State<MatchBox> {
  String _lastAnswer = "";
  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _listBuilder(widget.choices, widget.mode, true),
        _listBuilder(widget.choices, ButtonMode.voice, false),
      ],
    );
  }

  Widget _listBuilder(List<MatchVM> list, ButtonMode mode, bool isKey) {
    list.shuffle();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < list.length; i++)
          _choiceItemBuilder(i, list[i], mode, isKey)
      ],
    );
  }

  Widget _choiceItemBuilder(
    int index,
    MatchVM pair,
    ButtonMode mode,
    bool isKey,
  ) {
    var buttonId = (index + 1) * (isKey ? 1 : -1);
    var item = isKey ? pair.key : pair.value;
    return ValueListenableBuilder(
      valueListenable: _selectedIndex,
      builder: (context, value, child) {
        return SkinnedButton(
          isEnable: pair.isEnable,
          height: 100.d,
          width: mode == ButtonMode.image ? 100.d : 170.d,
          color: pair.isEnable
              ? (value == buttonId ? TColors.blue : TColors.white)
              : TColors.teal,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.all(4.d),
          child: switch (mode) {
            ButtonMode.text => Text(item, style: TStyles.large),
            ButtonMode.image => _image(item),
            _ => _player(item),
          },
          onPressed: () => _onChoosing(index, pair, isKey),
        );
      },
    );
  }

  Future<void> _onChoosing(int index, MatchVM pair, bool isKey) async {
    var buttonId = (index + 1) * (isKey ? 1 : -1);
    if (_lastAnswer.isNotEmpty) {
      var isCorrect =
          _lastAnswer == pair.value && _selectedIndex.value != buttonId;
      if (isCorrect) {
        pair.isEnable = false;
      }
      widget.onSelect?.call(_lastAnswer, isCorrect);
      _lastAnswer = "";
      _selectedIndex.value = 0;
    } else {
      _selectedIndex.value = _selectedIndex.value == buttonId ? 0 : buttonId;
      _lastAnswer = pair.value;
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Widget _image(String item) => Asset.load<Image>("ui_frame_wood_big");

  Widget _player(String choice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SpeakerBox(value: choice, narrator: Narrator.onyx),
        Widgets.rect(color: TColors.primary20, height: 24.d, width: 4.d),
        Text("select_l".l()),
      ],
    );
  }
}
