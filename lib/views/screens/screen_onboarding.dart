import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class OnboardingScreen extends AbstractScreen {
  OnboardingScreen({super.key}) : super(Routes.onboarding);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<OnboardingScreen> {
  @override
  List<Widget> appBarElementsLeft() => [];
  final _selectedLanguages = ValueNotifier(MapEntry("en", ""));
  final List<MapEntry> _targetLanguages = [MapEntry("en", "English")];
  List<MapEntry> _nativeLanguages = [];

  @override
  void initState() {
    _getLanguages();
    super.initState();
  }

  Future<void> _getLanguages() async {
    Map result =
        await serviceLocator<NetConnector>().rpc("content_languages_get");
    _nativeLanguages =
        result.entries /* .where((e) => e.key != "en") */ .toList();
    setState(() {});
  }

  @override
  Widget contentFactory(double paddingTop) {
    return Stack(
      children: [
        _languageSelection(),
        _slideShowAnimation(),
      ],
    );
  }

  Widget _languageSelection() {
    if (_nativeLanguages.isEmpty) {
      return SizedBox();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 100.d),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Asset.load<SvgPicture>("logo"),
            SizedBox(width: 10.d),
            Text("Life Talk"),
          ],
        ),
        SizedBox(height: 50.d),
        LanguageSelector(
          "I want to learn:",
          _targetLanguages,
          selectedIndex: 0,
          onChange: (index, code) => _selectedLanguages.value =
              MapEntry(code, _selectedLanguages.value.value),
        ),
        LanguageSelector(
          "My native language is:",
          _nativeLanguages,
          onChange: (index, code) => _selectedLanguages.value =
              MapEntry(_selectedLanguages.value.key, code),
        ),
        Expanded(child: SizedBox()),
        ValueListenableBuilder(
          valueListenable: _selectedLanguages,
          builder: (_, value, child) {
            return SkinnedButton(
              color: TColors.blue,
              height: 70.d,
              isEnable: value.value.isNotEmpty,
              margin: EdgeInsets.all(60.d),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("Lets Learn   ", style: TStyles.bigInvert),
                Asset.load<SvgPicture>("arrow_right"),
              ]),
              onPressed: () async {
      try {
        await serviceLocator<AccountProvider>().update(
                    targetLanguage: _selectedLanguages.value.key,
                    nativeLanguage: _selectedLanguages.value.value,
                  );
      } on SkeletonException catch (e) {
        alert(e.message, "error_${e.statusCode}".l());
      }
      if (mounted) {
        Navigator.pop(context);
      }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _slideShowAnimation() {
    return SizedBox();
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
            child: DirText(
              [
                "My native language is ...",
                "target_language_message".l(),
                "select_name_message".l()
              ][widget.index],
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.d),
          Widgets.skinnedInput(
            controller: _textInputController,
            hintText: [
              "Search",
              "search_l".l(),
              "select_name_prompt".l()
            ][widget.index],
            suffixIcon: Icon(widget.index > 1 ? Icons.person : Icons.search),
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
