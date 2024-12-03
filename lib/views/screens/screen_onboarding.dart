import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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
  int _slideIndex = -1;
  TextStyle? _errorStyle;
  TextValueRun? _slideTitleText;
  TextValueRun? _slideCaptionText;
  List<MapEntry> _nativeLanguages = [];
  final _selectedLanguages = ValueNotifier(MapEntry("en", ""));
  final List<MapEntry> _targetLanguages = [MapEntry("en", "English")];

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    Map result =
        await serviceLocator<NetConnector>().rpc("content_languages_get");
    _nativeLanguages = result.entries.where((e) => e.key != "en").toList();
    final location = await FlutterTimezone.getLocalTimezone();
    final languageCode = Localization.timeZoneToLanguage[location] ?? "";
    if (languageCode.isNotEmpty) {
      _selectedLanguages.value =
          MapEntry(_selectedLanguages.value.key, languageCode);
    }

    serviceLocator<Trackers>().design("pv_onboarding_lang");
    setState(() {});
  }

  @override
  Widget contentFactory(double paddingTop) {
    return Stack(
      children: [
        _slideShowAnimation(),
        _languageSelection(),
      ],
    );
  }

  Widget _languageSelection() {
    if (_nativeLanguages.isEmpty || _slideIndex > -1) {
      return SizedBox();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(height: 10.d),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Asset.load<SvgPicture>("logo", width: 50.d),
            SizedBox(width: 10.d),
            Text("title_l".l(), style: TStyles.large),
          ],
        ),
        LanguageSelector(
          "I want to learn:",
          _targetLanguages,
          selectedIndex: 0,
          onChange: (index, code) => _selectedLanguages.value =
              MapEntry(code, _selectedLanguages.value.value),
        ),
        LanguageSelector(
          "My native language is:",
          titleStyle: _errorStyle,
          _nativeLanguages,
          selectedIndex: _nativeLanguages
              .indexWhere((e) => e.key == _selectedLanguages.value.value),
          onChange: (index, code) => _selectedLanguages.value =
              MapEntry(_selectedLanguages.value.key, code),
        ),
        ValueListenableBuilder(
          valueListenable: _selectedLanguages,
          builder: (_, value, child) {
            return SkinnedButton(
              color: TColors.blue,
              isEnable: value.value.isNotEmpty,
              onDisablePressed: () {
                toast("Select native languages!");
                setState(() {
                  _errorStyle = TStyles.large.copyWith(color: TColors.error);
                });
              },
              margin: EdgeInsets.all(60.d),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("Lets Learn   ", style: TStyles.bigInvert),
                Asset.load<SvgPicture>("arrow_right"),
              ]),
              onPressed: () async {
                try {
                  final account = serviceLocator<AccountProvider>();
                  await account.update(
                    targetLanguage: _selectedLanguages.value.key,
                    nativeLanguage: _selectedLanguages.value.value,
                  );
                  _slideIndex = 0;
                  Localization.languageCode = _selectedLanguages.value.value;
                  serviceLocator<Trackers>().sendUserData(
                    nativeLanguage: Localization.languageCode,
                  );
                  await serviceLocator<Localization>().initialize();
                  setState(() {});
                } on SkeletonException catch (e) {
                  alert(e.message, "error_${e.statusCode}".l());
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _slideShowAnimation() {
    if (_slideIndex < 0) {
      return SizedBox();
    }
    return LoaderWidget(
      AssetType.animation,
      "onboarding",
      fit: BoxFit.fitWidth,
      riveAssetLoader: _onRiveAssetLoad,
      onRiveInit: (Artboard artboard) {
        final controller =
            StateMachineController.fromArtboard(artboard, "State Machine 1");
        _slideTitleText = artboard.component<TextValueRun>("titleText");
        _slideCaptionText = artboard.component<TextValueRun>("captionText");
        controller!.addEventListener(_onSlidShowEventChange);
        artboard.addController(controller);
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

  Future<void> _onSlidShowEventChange(RiveEvent event) async {
    if (event.name != "step") {
      return;
    }
    await Future.delayed(Duration(milliseconds: 10));
    _slideIndex = event.properties["step"].round();
    if (_slideIndex >= 100 && mounted) {
      Navigator.pop(context);
    } else {
      _slideTitleText?.text = "onboarding_title_$_slideIndex".l();
      _slideCaptionText?.text = "onboarding_caption_$_slideIndex".l();
      serviceLocator<Trackers>().design("pv_onboarding_slideshow_$_slideIndex");
    }
  }
}

class LanguageSelector extends StatefulWidget {
  final String title;
  final bool enabled;
  final int maxtItems;
  final int selectedIndex;
  final List<MapEntry> data;
  final TextStyle? titleStyle;
  final Function(int, String)? onChange;

  const LanguageSelector(
    this.title,
    this.data, {
    this.onChange,
    this.titleStyle,
    this.maxtItems = 4,
    this.enabled = true,
    this.selectedIndex = -1,
    super.key,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = -1;
  final _itemHeight = 64.d;
  final _itemMargin = 5.d;

  @override
  void initState() {
    _selectedIndex = widget.selectedIndex;
    if (_selectedIndex > -1) {
      Future.delayed(
        Duration(milliseconds: 400),
        () => _scrollController.animateTo(
          _itemHeight * _selectedIndex,
          curve: Curves.easeOutExpo,
          duration: Duration(milliseconds: _selectedIndex * 100),
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Widgets.rect(
      padding: EdgeInsets.fromLTRB(30.d, 20.d, 30.d, 10.d),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: widget.titleStyle),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16.d)),
            child: Widgets.rect(
              color: TColors.primary20,
              height: (_itemHeight + _itemMargin * 2) *
                      widget.data.length.max(widget.maxtItems) -
                  (widget.data.length > widget.maxtItems ? _itemMargin * 5 : 0),
              child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  controller: _scrollController,
                  itemCount: widget.data.length,
                  itemBuilder: (context, index) => _languageItemBuilder(index)),
            ),
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
          Asset.load<SvgPicture>("flags/${widget.data[index].key}"),
          Expanded(
            child: Text(
              widget.data[index].value,
              textAlign: TextAlign.center,
              style: selected ? TStyles.mediumInvert : TStyles.medium,
            ),
          )
        ],
      ),
      onPressed: () {
        widget.onChange?.call(index, widget.data[index].key);
        setState(() => _selectedIndex = index);
      },
    );
  }
}
