import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_export.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  LoadingController controller = Get.put(LoadingController());
  final ValueNotifier<int> _selectedCategory = ValueNotifier(0);
  Contents? _contents;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() {});
  }

  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.addListener(() async {
      if (services.state.status == ServiceStatus.initialize) {
        if (Pref.targetLanguage.getString().isEmpty) {
          await Future.delayed(const Duration(seconds: 1));
          await serviceLocator<RouteService>().to(Routes.onboarding);
          controller.connect(services);
        }
        _contents = serviceLocator<NetConnector>().loadingData.contents;
        _contents!.categories.add(_contents!.categories.first);
        setState(() {});
      }
    });
  }

  @override
  List<Widget> appBarElementsLeft() => [];

  @override
  Widget contentFactory(double paddingTop) {
    if (services.state.status.index < ServiceStatus.initialize.index) {
      return const SizedBox();
    }
    return PopScope(
      canPop: false,
      child: Widgets.rect(
        height: 555,
        alignment: Alignment.center,
      ),
    );
  }
}
