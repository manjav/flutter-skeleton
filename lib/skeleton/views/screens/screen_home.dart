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

  Map<String, int>? _scores;

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
        _categories = (await account.loadCategories());
        _scores = await account.loadScores();
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
            _contentItemBuilder(category.children[i] as GroupContent)
        ],
      ),
    );
  }

  Widget _contentItemBuilder(GroupContent group) {
    return Widgets.rect(
      radius: 16.d,
      padding: EdgeInsets.all(12.d),
      child: Column(
        children: [
          for (var i = 4; i >= 0; i--) _lessonItemBuilder(group, i),
          Row(children: [
            Image.network(group.iconUrl, height: 40.d),
            SizedBox(width: 12.d),
            SizedBox(
              width: DeviceInfo.size.width * 0.6,
              child: Text(group.title, style: TStyles.small),
            )
          ])
        ],
      ),
    );
  }

  Widget _lessonItemBuilder(GroupContent group, int type) {
    var id = "${group.id}_$type";
    var scoreNotifier = ValueNotifier(_scores![id] ?? 0);
    return Widgets.button(context,
        height: 50.d,
        width: DeviceInfo.size.width * 0.6,
        child: Row(
          children: [
            Text("lesson_$type".l()),
            SizedBox(width: 16.d),
            ValueListenableBuilder(
                valueListenable: scoreNotifier,
                builder: (context, value, child) =>
                    Text(["☆☆☆", "★☆☆", "★★☆", "★★★"][scoreNotifier.value])),
          ],
        ), onPressed: () async {
      if (group.children.isEmpty) {
        await serviceLocator<AccountProvider>().loadTalks(group);
      }
      // print(group.words);
      var s = await serviceLocator<RouteService>().to(
          switch (type) {
            1 => Routes.dictation,
            0 || 2 => Routes.speak,
            3 => Routes.match,
            _ => Routes.word,
          },
          args: {"content": group, "challengeMode": type == 2});
      if (s == null || s <= scoreNotifier.value) return;
      await serviceLocator<AccountProvider>().saveScore(id, s);
      scoreNotifier.value = s;
    });
  }
}
