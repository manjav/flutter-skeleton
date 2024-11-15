import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

class OnboardingScreen extends AbstractScreen {
  OnboardingScreen({super.key}) : super(Routes.onboarding);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<OnboardingScreen> {
  @override
  List<Widget> appBarElementsLeft() => [];
  final _slideMode = ValueNotifier(true);
  final _selectedLanguages = ValueNotifier(MapEntry("en", ""));
  final List<MapEntry> _targetLanguages = [MapEntry("en", "English")];
  List<MapEntry> _nativeLanguages = [];
  SMIInput<double>? _pageInput;

  @override
  void initState() {
    _getLanguages();
    super.initState();
  }

  Future<void> _getLanguages() async {
    Map result =
        await serviceLocator<NetConnector>().rpc("content_languages_get");
    _nativeLanguages = result.entries.where((e) => e.key != "en").toList();
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
    if (_nativeLanguages.isEmpty || _pageInput == null) {
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
    if (_pageInput != null && _pageInput!.value > 5) {
      return SizedBox();
    }
    return Widgets.touchable(
      context,
      child: LoaderWidget(
        AssetType.animation,
        "features",
        fit: BoxFit.cover,
        riveAssetLoader: _onRiveAssetLoad,
        onRiveInit: (Artboard artboard) {
          final controller =
              StateMachineController.fromArtboard(artboard, "State Machine 1");
          _pageInput = controller?.findInput<double>("state");
          artboard.addController(controller!);
        },
      ),
      onTap: () {
        _pageInput?.value++;
        if (_pageInput!.value > 5) {
          setState(() {});
        }
      },
    );
  }

  Future<bool> _onRiveAssetLoad(asset, Uint8List? bytes) async {
    if (asset is FontAsset) {
      var bytes =
          await rootBundle.load('assets/fonts/dnd_vazir_round_bold.ttf');
      var font = await FontAsset.parseBytes(bytes.buffer.asUint8List());
      asset.font = font;
      return true;
    }
    return false;
  }
}

class LanguageSelector extends StatefulWidget {
  final String title;
  final bool enabled;
  final int maxtItems;
  final int selectedIndex;
  final List<MapEntry> data;
  final Function(int, String)? onChange;

  const LanguageSelector(
    this.title,
    this.data, {
    this.onChange,
    this.enabled = true,
    this.maxtItems = 4,
    this.selectedIndex = -1,
    super.key,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final TextEditingController _textInputController = TextEditingController();
  List<MapEntry> _data = [];
  int _selectedIndex = -1;
  final _itemHeight = 64.d;
  final _itemMargin = 5.d;

  @override
  void initState() {
    _onSearchBoxChange("");
    _selectedIndex = widget.selectedIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Widgets.rect(
      padding: EdgeInsets.fromLTRB(30.d, 30.d, 30.d, 10.d),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title),
          SizedBox(height: _itemMargin),
          _data.length > widget.maxtItems
              ? Widgets.skinnedInput(
                  controller: _textInputController,
                  hintText: "Search",
                  suffixIcon: Icon(Icons.search),
                  // inputFormatters: <TextInputFormatter>[
                  //   FilteringTextInputFormatter.allow(Localization.getLimits(
                  //       OnboardingScreen.targetLanguage)),
                  // ],
                  onChange: _onSearchBoxChange,
                )
              : SizedBox(),
          SizedBox(
            height: (_itemHeight + _itemMargin * 2) *
                _data.length.max(widget.maxtItems),
            child: ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: _data.length,
                itemBuilder: (context, index) => _languageItemBuilder(index)),
          ),
          SizedBox(height: 10.d),
        ],
      ),
    );
  }

  Widget _languageItemBuilder(int index) {
    final selected = _selectedIndex == index;
    return Widgets.button(
      context,
      height: _itemHeight,
      padding: EdgeInsets.all(10.d),
      margin: EdgeInsets.all(_itemMargin),
      color: selected ? TColors.teal : TColors.primary10,
      child: Row(
        children: [
          Asset.load<SvgPicture>("flags/${_data[index].key}"),
          Expanded(
            child: Text(
              _data[index].value,
              textAlign: TextAlign.center,
              style: selected ? TStyles.mediumInvert : TStyles.medium,
            ),
          )
        ],
      ),
      onPressed: () {
        widget.onChange?.call(index, _data[index].key);
        setState(() => _selectedIndex = index);
      },
    );
  }

  void _onSearchBoxChange(String text) {
    _data = widget.data
        .where((f) => (f.value as String).contains(_textInputController.text))
        .toList();
    if (text.isNotEmpty) {
      setState(() {});
    }
  }
}
