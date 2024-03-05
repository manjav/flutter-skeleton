import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class OnboardingScreen extends AbstractScreen {
  OnboardingScreen({super.key}) : super(Routes.onboarding);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  Widget contentFactory(double paddingTop) {
    var configs = serviceLocator<NetConnector>().loadingData.configs;
    List<MapEntry> languages = configs["supportedLanguages"].entries.toList();
    return PageView.builder(
      itemCount: 2,
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) =>
          LanguagePage(languages, (code) => onFlagSelect(index, code)),
    );
  }

  @override
  List<Widget> appBarElementsLeft() => [];

  void onFlagSelect(int index, String code) {
    if (index == 0) {
      Pref.nativeLanguage.setString(code);
      _pageController.animateToPage(1,
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    } else {
      Pref.targetLanguage.setString(code);
      Navigator.pop(context);
    }
  }
}

class LanguagePage extends StatefulWidget {
  final List<MapEntry> languages;

  final Function(String)? onItemSelect;
  const LanguagePage(this.languages, this.onItemSelect, {super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final TextEditingController _textInputController = TextEditingController();
  List<MapEntry> _flags = [];

  @override
  void initState() {
    _onSearchBoxChange("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Widgets.rect(
      padding: EdgeInsets.fromLTRB(56.d, 56.d, 56.d, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(8.d),
            child: Text(
              "What is your native language?",
              style: TStyles.large,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.d),
          Widgets.skinnedInput(
            hintText: "Search",
            suffixIcon: const Icon(Icons.search),
            controller: _textInputController,
            onChange: _onSearchBoxChange,
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.all(16.d),
                itemCount: _flags.length,
                itemBuilder: (context, index) => _languageItemBuilder(index)),
          ),
        ],
      ),
    );
  }

  Widget _languageItemBuilder(int index) {
    return Widgets.button(context,
        height: 64.d,
        child: Row(
          children: [
            Asset.load<SvgPicture>("flags/${_flags[index].key}"),
            SizedBox(width: 48.d),
            Text(_flags[index].value)
          ],
        ),
        onPressed: () => widget.onItemSelect?.call(_flags[index].key));
  }

  void _onSearchBoxChange(String text) {
    _flags = widget.languages
        .where((f) => (f.value as String).contains(_textInputController.text))
        .toList();
    setState(() {});
  }
}
