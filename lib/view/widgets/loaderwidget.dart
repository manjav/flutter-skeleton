import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rive/rive.dart';

import '../../utils/assets.dart';
import '../../utils/loader.dart';

class LoaderWidget extends StatefulWidget {
  static String baseURL = "";
  static Map<String, String> hashMap = {};

  final String name;
  final AssetType type;
  final String? subFolder;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final String? baseUrl;
  final Function(Artboard)? onRiveInit;
  final CallbackAssetLoader? riveAssetLoader;

  const LoaderWidget(
    this.type,
    this.name, {
    this.subFolder,
    this.fit,
    this.width,
    this.height,
    this.onRiveInit,
    this.riveAssetLoader,
    this.baseUrl,
    super.key,
  });

  @override
  createState() => _LoaderWidgetState();
  static final Map<String, Loader> cacshedLoders = {};
}

class _LoaderWidgetState extends State<LoaderWidget> {
  late Loader _loader;
  Widget? _result;
  RiveFile? _riveFile;
  String _poolName = "";

  @override
  void initState() {
    _poolName = "${widget.type.name}_${widget.name}";
    _loader = LoaderWidget.cacshedLoders[_poolName] ?? Loader();
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: widget.width, height: widget.height, child: _result);

  Future<void> _load() async {
    var url = widget.baseUrl ??
        "${LoaderWidget.baseURL}/${widget.type.folder(widget.subFolder ?? '')}";
    var netPath = "${widget.name}.${widget.type.extension}";
    var path = "${widget.name}.${widget.type.type}";
    if (_loader.path.isEmpty) {
      await _loader.load(path, '$url/$netPath',
          hash: LoaderWidget.hashMap[path]);
      LoaderWidget.cacshedLoders[_poolName] = _loader;
    }
    if (widget.type == AssetType.animation ||
        widget.type == AssetType.animationZipped) {
      _riveFile = await RiveFile.file(_loader.file!.path,
          assetLoader: widget.riveAssetLoader);
    }
    if (mounted) {
      _result = _getResult();
      setState(() {});
    }
  }

  Widget? _getResult() {
    if (_loader.bytes == null) return null;
    switch (widget.type) {
      case AssetType.animation:
      case AssetType.animationZipped:
        return RiveAnimation.direct(_riveFile!,
            onInit: ((p0) => widget.onRiveInit?.call(p0)), fit: widget.fit);
      case AssetType.image:
        return Image.memory(Uint8List.fromList(_loader.bytes!),
            gaplessPlayback: true);
      case AssetType.vector:
        return SvgPicture.memory(Uint8List.fromList(_loader.bytes!));
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _loader.abort();
    super.dispose();
  }
}
