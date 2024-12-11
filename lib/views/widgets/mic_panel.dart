import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final List<Choice> _answerWords = [];
  final ValueNotifier<QuizState> _state = ValueNotifier(QuizState.none);
  final ValueNotifier<String> _recognizedWords = ValueNotifier("");
  SMIInput<bool>? _toggleInput;
  SMIInput<double>? _stateInput;
  SMIInput<double>? _soundLevelInput;

  @override
  void initState() {
    final listener = serviceLocator<ListenerQuiz>();
    _removeListeners(listener);
    _addListeners(listener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final listener = serviceLocator<ListenerQuiz>();
    final words = widget.talk.targetValue.split(" ");
    _answerWords.clear();
    _answerWords.addAll(List.generate(words.length, (i) => Choice(words[i])));
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
            HiddenWords(
              _answerWords,
              _recognizedWords,
              // minMatchLevel: listener.minMatchLevel,
            ),
            SizedBox(height: 20.d),
            widget.talk.type == ContentType.translate
                ? const SizedBox()
                : _nativeTextBuilder(TStyles.smallDetails),
            SizedBox(height: 20.d),
            _wrongResultBuilder(listener),
            SizedBox(height: 50.d),
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
      "mic_state_machine",
      height: size,
      onRiveInit: (artboard) {
        var voiceMode = listener.initialMedia == null ||
            listener.initialMedia!.type == MediaType.voice;
        final controller =
            StateMachineController.fromArtboard(artboard, "State Machine 1");
        _toggleInput = controller?.findInput<bool>("play");
        _stateInput = controller?.findInput<double>("state");
        _soundLevelInput = controller?.findInput<double>("soundLevel");
        controller?.findInput<double>("type")?.value =
            widget.talk.type.micIndex;
        controller?.findInput<bool>("speaker")?.value = voiceMode;
        artboard.component<TextValueRun>("messageText")?.text =
            "${widget.talk.type.name}_l".l();
        controller!.addEventListener((s) => _onMicAnimationEvent(s, listener));
        _stateInput?.value = listener.state.value.index.toDouble();
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
    final media = serviceLocator<MediaService>();
    media.autoStart = true;

    // log trecker event
    serviceLocator<Trackers>().design(
        "bt_${event.name}|${listener.talk!.parent!.majority!.type.name}",
        parameters: {
          "state": _state.value.name,
          "slide_index": listener.talk!.parent!.index,
          "video_id": listener.talk!.parent!.parent!.parent!.iconUrl,
        });

    if (event.name == "toggle") {
      if (_state.value == QuizState.running) {
        listener.stop();
      } else {
        widget.talk.lastRecord = null;
        Timer(const Duration(milliseconds: 100), () => listener.start());
      }
    } else if (event.name == "play") {
      media.play(listener.initialMedia);
    } else if (event.name == "slow") {
      media.play(listener.initialMedia, playbackRate: 0.75);
    }
  }

  Widget _wrongResultBuilder(ListenerQuiz stt) {
    return ValueListenableBuilder(
      valueListenable: _state,
      builder: (context, value, child) {
        return value == QuizState.failure
            ? DirText(
                _recognizedWords.value,
                textAlign: TextAlign.center,
                style: TStyles.medium.copyWith(color: TColors.error, height: 1),
              )
            : SizedBox(height: 12.d);
      },
    );
  }

  void _stateListener() {
    final listener = serviceLocator<ListenerQuiz>();
    if (listener.talk != widget.talk) return;
    _state.value = listener.state.value;
    // print(
    //     "id => ${listener.talk!.id} ${widget.talk.id} ${listener.state.value} ${listener.state.value.index}");
    _stateInput?.value = listener.state.value.index.toDouble();
  }

  void _mediaStateListener(MediaState event) {
    final listener = serviceLocator<ListenerQuiz>();
    if (listener.talk != widget.talk) return;
    _toggleInput?.value = event == MediaState.playing;
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
    listener.initialMedia?.onStateChanged.listen(_mediaStateListener);
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
