import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_export.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  List<ParentContent> _categories = [];
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
        _categories = (await account.loadCategories()).categories;
        setState(() {});
        // await Future.delayed(const Duration(seconds: 1));
        // serviceLocator<RouteService>().to(Routes.popupMentor, args: {
        //   "message":
        //       "سلام من قلیدونم. به ده ما خوش اومدی!\nما تو دهاتمون به ترکی صحبت می‌کنیم اما نگران نباش. من به تو کمک می‌کنم تا بتونی زبون ما رو یاد بگیری. خوب بریم اول بقالی محل کمی خرید کنیم."
        // });
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
        child: ListView.builder(
          itemCount: _categories.length,
          itemBuilder: _categoryItemBuilder,
          reverse: true,
        ),
      ),
    );
  }

  Widget _categoryItemBuilder(BuildContext context, int index) {
    var category = _categories[index];
    const colors = [
      TColors.cyan,
      TColors.orange,
      TColors.blue,
      TColors.green,
      TColors.teal,
      TColors.primary60,
      TColors.red,
      TColors.gray
    ];
    return ValueListenableBuilder(
      valueListenable: _selectedCategory,
      builder: (context, value, child) {
        var isSelected = value == index;
        return Widgets.button(
          context,
          color: colors[index % colors.length],
          padding: EdgeInsets.all(12.d),
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              isSelected ? _groupsBuilder(category, index) : const SizedBox(),
              SizedBox(height: isSelected ? 10.d : 0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: 240.d,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.title, style: TStyles.largeInvert),
                          isSelected
                              ? const SizedBox()
                              : Text(category.description,
                                  style:
                                      TStyles.smallInvert.copyWith(height: 1)),
                        ],
                      )),
                  Image.network(category.iconUrl,
                      height: isSelected ? 50.d : 100.d),
                ],
              ),
            ],
          ),
          onPressed: () {
            _selectedCategory.value = isSelected ? -1 : index;
          },
        );
      },
    );
  }

  Widget _groupsBuilder(ParentContent category, int index) {
    return Widgets.rect(
      radius: 12.d,
      color: TColors.white50,
      padding: EdgeInsets.all(8.d),
      child: Column(
        children: [
          for (var i = category.children.length - 1; i >= 0; i--)
            _contentItemBuilder(category.children[i] as ParentContent)
        ],
      ),
    );
  }

  Widget _contentItemBuilder(ParentContent content) {
    return Widgets.rect(
      radius: 16.d,
      padding: EdgeInsets.all(12.d),
      child: Column(
        children: [
          _lessonItemBuilder(content, 2),
          _lessonItemBuilder(content, 1),
          _lessonItemBuilder(content, 0),
          Row(children: [
            Image.network(content.iconUrl, height: 40.d),
            SizedBox(width: 12.d),
            SizedBox(
              width: DeviceInfo.size.width * 0.6,
              child: Text(content.title, style: TStyles.small),
            )
          ])
        ],
      ),
    );
  }

  _lessonItemBuilder(ParentContent content, int type) {
    return Widgets.button(context,
        height: 50.d,
        width: DeviceInfo.size.width * 0.6,
        child: Text("lesson_$type".l()), onPressed: () async {
      if (content.children.isEmpty) {
        await serviceLocator<AccountProvider>().loadContent(content);
      }
      serviceLocator<RouteService>().to(
          switch (type) { 1 => Routes.listen, _ => Routes.speak },
          args: {"content": content, "challengeMode": type == 2});
    });
  }
}
