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
          await Get.toNamed(Routes.onboarding);
        }
        _categories = (await account.loadCategories());
        _scores = await account.loadScores();
        setState(() {});
        // await Future.delayed(const Duration(seconds: 1));
        // Get.toNamed(Routes.popupMentor, args: {
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
          padding: EdgeInsets.all(12.d),
          margin: const EdgeInsets.all(12),
          color: colors[index % colors.length],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              isSelected ? _groupsBuilder(category, index) : const SizedBox(),
              DirText(category.title, style: TStyles.largeInvert),
              isSelected
                  ? const SizedBox()
                  : DirText(category.description,
                      style: TStyles.tiny.copyWith(height: 1)),

              // Image.network(category.iconUrl,
              //     height: isSelected ? 50.d : 100.d),
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
        textDirection: TextDirection.rtl,
        children: [
          _lessonItemBuilder(group, 0),
        ],
      ),
    );
  }

  Widget _lessonItemBuilder(GroupContent group, int type) {
    var id = "${group.id}_$type";
    var scoreNotifier = ValueNotifier(_scores![id] ?? 0);
    return Widgets.button(
      context,
      height: 22.d,
      width: DeviceInfo.size.width * 0.8,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          DirText(group.title, style: TStyles.small),
          SizedBox(width: 16.d),
          ValueListenableBuilder(
              valueListenable: scoreNotifier,
              builder: (context, value, child) =>
                  Text(["☆☆☆", "★☆☆", "★★☆", "★★★"][scoreNotifier.value])),
        ],
      ),
      onPressed: () async {
        if (group.children.isEmpty) {
          await serviceLocator<AccountProvider>().loadTalks(group);
        }

        // var routName =
        //     group.children.where((t) => (t as Talk).personId == "name").isEmpty
        //         ? Routes.chat
        //         : Routes.intro;

        // print(group.words);
        var s = await Get.toNamed(Routes.chat,
            arguments: {"content": group, "challengeMode": type == 2});
        if (s == null || s <= scoreNotifier.value) return;
        await serviceLocator<AccountProvider>().saveScore(id, s);
        scoreNotifier.value = s;
      },
    );
  }
}
