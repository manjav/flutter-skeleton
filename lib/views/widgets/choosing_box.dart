import 'package:flutter/material.dart';
import 'package:lingai/app_export.dart';

enum ButtonMode { text, image, voice }

class ChoosingBox extends StatefulWidget {
  final String answer;
  final ButtonMode mode;
  final List<String> choices;
  final Function(String, bool)? onSelect;

  const ChoosingBox({
    required this.mode,
    required this.answer,
    required this.choices,
    this.onSelect,
    super.key,
  });

  @override
  State<ChoosingBox> createState() => _ChoosingBoxState();
}

class _ChoosingBoxState extends State<ChoosingBox> {
  final ValueNotifier<IntVec2> _feedbacks = ValueNotifier(IntVec2(0, 0));
  @override
  Widget build(BuildContext context) {
    _feedbacks.value = IntVec2(0, 0);
    return Widgets.rect(
      width: 280.d,
      height: widget.mode == ButtonMode.image ? 400 : 200.d,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: (widget.mode == ButtonMode.image ? 1.0 : 2.2)),
        itemCount: widget.choices.length,
        itemBuilder: _choiceItemBuilder,
      ),
    );
  }

  Widget _choiceItemBuilder(BuildContext context, int index) {
    return ValueListenableBuilder(
      valueListenable: _feedbacks,
      builder: (context, value, child) {
        return SkinnedButton(
          width: 100.d,
          color: value.i == index
              ? switch (value.j) {
                  1 => TColors.green,
                  -1 => TColors.red,
                  _ => TColors.white,
                }
              : TColors.white,
          margin: EdgeInsets.all(4.d),
          padding: EdgeInsets.zero,
          onPressed: () => _onChoosing(index),
          child: switch (widget.mode) {
            ButtonMode.text =>
              Text(widget.choices[index], style: TStyles.large),
            ButtonMode.image => _image(widget.choices[index]),
            _ => _player(widget.choices[index]),
          },
        );
      },
    );
  }

  Future<void> _onChoosing(int index) async {
    var isCorrect = widget.choices[index] == widget.answer;
    widget.onSelect?.call(widget.choices[index], isCorrect);
    _feedbacks.value = IntVec2(index, isCorrect ? 1 : -1);
    await Future.delayed(const Duration(milliseconds: 200));
    _feedbacks.value = IntVec2(index, 0);
  }

  Widget _image(String item) => Asset.load<Image>("ui_frame_wood_big");

  Widget _player(String choice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SpeakerBox(value: choice, narrator: Narrator.onyx),
        Widgets.rect(color: TColors.primary20, height: 24.d, width: 4.d),
        const Text("Select"),
      ],
    );
  }
}
