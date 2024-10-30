import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../app_export.dart';

class ImitationScreen extends AbstractScreen {
  ImitationScreen({super.key}) : super(Routes.imitation);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<ImitationScreen>
    with LessonMixin, ListeningMixin, VideoPlayerMixin {
  final ValueNotifier<VideoIntry?> _videoData = ValueNotifier(null);
  final List<VideoIntry> _captions = [];
  final ValueNotifier<bool> _captionMode = ValueNotifier(false);
  @override
  void initState() {
    initializeController();
    super.initState();
  }

  void _onSlideChange() {
    _playYoutube(controller.currentSlide);
  }

  Future<void> _playYoutube(ParentContent slide) async {
    final youtubeContents = controller.currentSlide.children
        .where((c) => c.type == ContentType.youtube);
    _captions.clear();
    if (youtubeContents.isEmpty) {
      _videoData.value = null;
      return;
    }
    _videoData.value = VideoIntry.parse(youtubeContents.first.targetValue);

    final list =
        slide.children.where((c) => c.type == ContentType.caption).toList();
    for (var caption in list) {
      var seconds = _getMilliSeconds(caption.nativeValue);
      _captions.add(VideoIntry(
        "",
        _captions.lastOrNull != null ? _captions.last.end ?? 0 : 0,
        seconds,
      )..data = caption);
    }
    if (youtubeController == null) {
      playYoutube(_videoData.value!);
      youtubeController!.addListener(() {
        _setCurrentCaption();
        if (youtubeController!.value.playerState == PlayerState.ended) {
          _nextSlide();
        }
      });
    } else {
      youtubeController?.load(_videoData.value!.id,
          startAt: _videoData.value!.start, endAt: _videoData.value?.end);
    }
  }

  void _setCurrentCaption() {
    final milliseconds = youtubeController!.value.position.inMilliseconds;
    for (var caption in _captions) {
      if (caption.start <= milliseconds && (caption.end ?? 0) > milliseconds) {
        this.caption.value = caption.data;
        return;
      }
    }
  }

  int _getMilliSeconds(String time) {
    final times = time.split("，");
    final digits = times.first.split(":");
    final duration = Duration(
      hours: int.parse(digits[0]),
      minutes: int.parse(digits[1]),
      seconds: int.parse(digits[2]),
      milliseconds: int.parse(times[1]),
    );
    return duration.inMilliseconds;
  }

}
