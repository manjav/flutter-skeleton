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
  }

  Widget footerBuilder() => const SizedBox();
}
