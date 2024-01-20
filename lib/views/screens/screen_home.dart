import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  var controller = Get.put(LoadingController());
  List _topics = [];
  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    var data = await rootBundle.loadString("assets/texts/topics.json");
    _topics = jsonDecode(data)["topics"];
    setState(() {});
  }

  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.addListener(() {
      if (services.state.status == ServiceStatus.initialize) {
        setState(() {});
      }
    });
  }

  @override
  Widget appBarFactory(double paddingTop) {
    if (services.state.status.index < ServiceStatus.initialize.index) {
      return const SizedBox();
    }
    return super.appBarFactory(paddingTop);
  }

  @override
  Widget contentFactory() {
    if (services.state.status.index < ServiceStatus.initialize.index) {
      return const SizedBox();
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          if (Platform.isAndroid) {
            var result = await services
                .get<RouteService>()
                .to(Routes.popupMessage, args: {
              "title": "quit_title".l(),
              "message": "quit_message".l(),
              "isConfirm": () {}
            });
            if (result != null) {
              SystemNavigator.pop();
            }
          }
        }
      },
      child: Center(
        child: Widgets.rect(
          height: 555,
          alignment: Alignment.center,
          child: ListView.builder(
            itemBuilder: _topicItemBuilder,
            itemCount: _topics.length,
          ),
        ),
      ),
    );
  }

  Widget _topicItemBuilder(BuildContext context, int index) {
    var id = "topic_${_topics[index]["id"]}";
    return Widgets.button(
      context,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Asset.load<Image>(id),
            SkinnedText(id.l(), style: TStyles.large),
          ],
        ),
      ),
      onPressed: () {
        services.get<RouteService>().to(Routes.chat);
      },
    );
  }
}
