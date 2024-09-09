import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

enum Difficulty { simple, hint, hidden }

class MicPanel extends StatefulWidget {
  final Talk talk;
  const MicPanel({super.key, required this.talk});

  @override
  State<MicPanel> createState() => _MicPanelState();
}

class _MicPanelState extends State<MicPanel> {
  final List<ValueNotifier<Choice>> _patterns = [];
  final ValueNotifier<QuizState> _state = ValueNotifier(QuizState.none);
  final ValueNotifier<String> _recognizedWords = ValueNotifier("");
  final _correctStyle = TStyles.huge.copyWith(height: 1, color: TColors.green);
  final _defaultStyle =
      TStyles.huge.copyWith(height: 1, color: TColors.primary30);
  final _hiddenStyle =
      TStyles.huge.copyWith(height: 1, color: TColors.transparent);
  SMIInput<bool>? _toggleInput;
  SMIInput<double>? _stateInput;
  SMIInput<double>? _soundLevelInput;

  @override
  void initState() {
    final listener = serviceLocator<ListenerQuiz>();
    _removeListeners(listener);
    _addListeners(listener);
    serviceLocator<Sounds>()
        .getPlayer(widget.talk.targetValue)
        .onPlayerStateChanged
        .listen((state) {
      _toggleInput?.value = state == PlayerState.playing;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final listener = serviceLocator<ListenerQuiz>();
    final words = widget.talk.targetValue.replace().split(" ");
    _patterns.clear();
    _patterns.addAll(
        List.generate(words.length, (i) => ValueNotifier(Choice(words[i]))));
    return Stack(
      alignment: Alignment.center,
      children: [
        _micAnimationBuilder(context, listener),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.talk.type == ContentType.translate
                ? _nativeTextBuilder(TStyles.large)
                : const SizedBox(),
            SizedBox(
                height: widget.talk.type == ContentType.translate ? 30.d : 0),
            _answeringBuilder(context, listener.minMatchLevel),
            SizedBox(height: 30.d),
            widget.talk.type == ContentType.translate
                ? const SizedBox()
                : _nativeTextBuilder(TStyles.medium),
            SizedBox(height: 30.d),
            _wrongResultBuilder(listener),
            SizedBox(height: 20.d),
          ],
        ),
      ],
    );
  }

  Widget _nativeTextBuilder(TextStyle style) =>
      DirText(widget.talk.nativeValue, style: style);

  Widget _micAnimationBuilder(BuildContext context, ListenerQuiz listener) {
    var size = DeviceInfo.size.width * 0.85;
    return LoaderWidget(
      AssetType.animation,
      "mic_panel",
      height: size,
      onRiveInit: (artboard) {
        final controller =
            StateMachineController.fromArtboard(artboard, "State Machine 1");
        _toggleInput = controller?.findInput<bool>("play");
        _stateInput = controller?.findInput<double>("state");
        _soundLevelInput = controller?.findInput<double>("soundLevel");
        controller?.findInput<double>("type")?.value =
            widget.talk.type.micIndex;
        artboard.component<TextValueRun>("messageText")?.text =
            "${widget.talk.type.name}_l".l();
        controller!.addEventListener((s) => _onMicAnimationEvent(s, listener));
        artboard.addController(controller);
      },
      riveAssetLoader: _onRiveAssetLoad,
    );
  }

  Future<bool> _onRiveAssetLoad(asset, Uint8List? bytes) async {
    if (asset is FontAsset) {
      var bytes =
          await rootBundle.load('assets/fonts/dnd_vazir_round_bold.ttf');
      var font = await FontAsset.parseBytes(bytes.buffer.asUint8List());
      asset.font = font;
      return true;
    }
    return false; // load the default embedded asset
  }

  void _onMicAnimationEvent(RiveEvent event, ListenerQuiz listener) {
    if (event.name == "restart") {
      if (listener.state.value == QuizState.waiting) {
        return;
      }
      widget.talk.lastRecord = null;
      Timer(
        const Duration(milliseconds: 100),
        () => listener.listen(
          talk: widget.talk,
          onResult: listener.onResult,
        ),
      );
    } else if (event.name == "play") {
      serviceLocator<Speaker>().playLocal(widget.talk.targetValue);
    } else if (event.name == "pause") {
      serviceLocator<Sounds>().stopAll();
    }
  }

  Widget _answeringBuilder(BuildContext context, int minMatchLevel) {
    return ValueListenableBuilder(
      valueListenable: _recognizedWords,
      builder: (context, value, child) {
        var items = <Widget>[];
        var words = value.split(" ");
        for (var i = 0; i < _patterns.length; i++) {
          var isCorrect = false;
          var isHidden = _patterns[i].value.text.contains("{") ||
              _patterns[i].value.text.contains("}");
          var style = _defaultStyle;
          if (i < words.length) {
            var rate = ratio(words[i], _patterns[i].value.text.patternize());
            isCorrect = rate > minMatchLevel;
            if (isCorrect) {
              style = _correctStyle;
            }
          }
          items.add(
            ValueListenableBuilder(
              valueListenable: _patterns[i],
              builder: (context, value, child) {
                // print("Hide:$isHidden Correct:$isCorrect =>${_state.value}");
                return Widgets.button(
                  context,
                  radius: 6.d,
                  color: isHidden ? TColors.primary10 : TColors.transparent,
                  margin: EdgeInsets.all(2.d),
                  padding: EdgeInsets.fromLTRB(4.d, 4.d, 4.d, 1.d),
                  child: Text(
                      _patterns[i]
                          .value
                          .text
                          .replaceAll(RegExp(r'[ًٍَُِّ{}]'), ''),
                      style: isHidden && !_patterns[i].value.used && !isCorrect
                          ? _hiddenStyle
                          : style),
                  onPressed: () =>
                      _patterns[i].value = Choice(value.text)..used = true,
                );
              },
            ),
          );
        }
        return Wrap(children: items);
      },
    );
  }

  Widget _wrongResultBuilder(ListenerQuiz stt) {
    return ValueListenableBuilder(
      valueListenable: _state,
      builder: (context, value, child) {
        return value == QuizState.failure
            ? DirText(
                _recognizedWords.value,
                style: TStyles.medium.copyWith(color: TColors.error, height: 1),
                textAlign: TextAlign.center,
              )
            : SizedBox(height: 12.d);
      },
    );
  }

  void _stateListener() {
    final listener = serviceLocator<ListenerQuiz>();
    if (listener.talk != widget.talk) return;
    _state.value = listener.state.value;
    _stateInput?.value = listener.state.value.index.toDouble();
    if (_state.value == QuizState.ready) {
      for (var pattern in _patterns) {
        pattern.value = Choice(pattern.value.text)..used = false;
      }
    } else if (_state.value.index >= QuizState.success.index) {
      for (var pattern in _patterns) {
        pattern.value = Choice(pattern.value.text)..used = true;
      }
    }
  }

  void _soundLevelListener() {
    final listener = serviceLocator<ListenerQuiz>();
    if (listener.talk != widget.talk) return;
    _soundLevelInput?.value = listener.audioLevel.value * 100;
  }

  void _resultListener() {
    final listener = serviceLocator<ListenerQuiz>();
    if (listener.talk != widget.talk) return;
    _recognizedWords.value = listener.recognizedWords.value;
  }

  void _addListeners(ListenerQuiz listener) {
    listener.state.addListener(_stateListener);
    listener.audioLevel.addListener(_soundLevelListener);
    listener.recognizedWords.addListener(_resultListener);
  }

  void _removeListeners(ListenerQuiz listener) {
    listener.state.removeListener(_stateListener);
    listener.audioLevel.removeListener(_soundLevelListener);
    listener.recognizedWords.removeListener(_resultListener);
  }

  @override
  void dispose() {
    _removeListeners(serviceLocator<ListenerQuiz>());
    super.dispose();
  }
}
