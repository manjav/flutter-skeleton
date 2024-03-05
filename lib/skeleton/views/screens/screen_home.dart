import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_export.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  List<Content> _categories = [];
  LoadingController controller = Get.put(LoadingController());
  final ValueNotifier<int> _selectedCategory = ValueNotifier(0);

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() {});
  }

// Consumer<AccountProvider>(builder: (_, state, child) {
  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.addListener(() async {
      if (services.state.status == ServiceStatus.initialize) {
        var account = serviceLocator<AccountProvider>();
        if (!account.metadata.containsKey("targetLanguage")) {
          await Future.delayed(const Duration(seconds: 1));
          await serviceLocator<RouteService>().to(Routes.onboarding);
        }
        _categories = (await account.getContents()).categories;
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
