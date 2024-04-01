import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class OnboardingScreen extends AbstractScreen {
  OnboardingScreen({super.key}) : super(Routes.onboarding);
  static String nativeLanguage = "", targetLanguage = "";

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<OnboardingScreen> {
  final PageController _pageController = PageController();
  @override
  List<Widget> appBarElementsLeft() => [];

  @override
  Widget contentFactory(double paddingTop) {
    List<MapEntry> languages =
        NetConnector.configs["supportedLanguages"].entries.toList();
    return PageView.builder(
      itemCount: 3,
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) =>
          LanguagePage(index, languages, onChange: _onFlagSelect),
    );
  }

  Future<void> _onFlagSelect(int index, String value) async {
    if (index == 0) {
      OnboardingScreen.nativeLanguage = value;
      _nativeLanguage = value;
      _pageController.animateToPage(1,
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    } else if (index == 1) {
      OnboardingScreen.targetLanguage = value;
      _pageController.animateToPage(2,
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    } else {
      await serviceLocator<AccountProvider>().update(
          nativeLanguage: OnboardingScreen.nativeLanguage,
          targetLanguage: OnboardingScreen.targetLanguage,
          displayName: value);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}

class LanguagePage extends StatefulWidget {
  final int index;
  final List<MapEntry> languages;
  final Function(int, String)? onChange;
  const LanguagePage(this.index, this.languages, {this.onChange, super.key});

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
        crossAxisAlignment: widget.index > 1
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(8.d),
            child: Text(
              ["My native language is ...", "I want to learn..."][widget.index],
              style: TStyles.large,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.d),
          Widgets.skinnedInput(
            hintText: "Search",
            suffixIcon: const Icon(Icons.search),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                  Localization.getLimits(OnboardingScreen.targetLanguage)),
            ],
            onChange: _onSearchBoxChange,
          ),
          widget.index < 2
              ? Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.all(16.d),
                      itemCount: _flags.length,
                      itemBuilder: (context, index) =>
                          _languageItemBuilder(index)),
                )
              : SkinnedButton(
                  icon: "tick",
                  width: 80.d,
                  height: 60.d,
                  cornerRadius: 44.d,
                  padding: EdgeInsets.all(20.d),
                  margin: EdgeInsets.only(top: 40.d),
                  isEnable: _textInputController.text.length > 2,
                  onPressed: () => _submit(_textInputController.text),
                ),
        ],
      ),
    );
  }

  Widget _languageItemBuilder(int index) {
    return Widgets.button(
      context,
      height: 64.d,
      child: Row(
        children: [
          Asset.load<SvgPicture>("flags/${_flags[index].key}"),
          SizedBox(width: 48.d),
          Text(_flags[index].value)
        ],
      ),
      onPressed: () => _submit(_flags[index].key),
    );
  }

  void _onSearchBoxChange(String text) {
    _flags = widget.languages
        .where((f) => (f.value as String).contains(_textInputController.text))
        .toList();
    setState(() {});
  }

  void _submit(String value) => widget.onChange?.call(widget.index, value);
}
