import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart' as rive;
import '../../skeleton.dart';

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
  final Future<bool> Function(rive.FileAsset asset, Uint8List? embeddedBytes)?
      riveAssetLoader;

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
  static final Map<String, Loader> cachedLoaders = {};

  static Future<Loader> load(AssetType type, String name,
      {String? baseUrl,
      String? subFolder,
      Future<bool> Function(rive.FileAsset asset, Uint8List? embeddedBytes)?
          riveAssetLoader}) async {
    var key = "${type.name}_$name";
    var loader = cachedLoaders[key] ?? Loader();
    var url =
        baseUrl ?? "${LoaderWidget.baseURL}/${type.folder(subFolder ?? "")}";
    var netPath = "$name.${type.extension}";
    var path = "$name.${type.type}";
    if (loader.path.isEmpty) {
      await loader.load(path, '$url/$netPath', hash: hashMap[path]);
    }
    if (type == AssetType.image || type == AssetType.vector) {
      if (loader.bytes != null) {
        loader.metadata = Uint8List.fromList(loader.bytes!);
      }
    }
    if (type == AssetType.animation || type == AssetType.animationZipped) {
      loader.metadata = await RiveFile.file(loader.file!.path,
          assetLoader: riveAssetLoader != null
              ? CallbackAssetLoader(riveAssetLoader)
              : null);
    }
    cachedLoaders[key] = loader;
    return loader;
  }
}

class _LoaderWidgetState extends State<LoaderWidget> {
  Widget? _result;
  String get poolName => "${widget.type.name}_${widget.name}";

  @override
  void initState() {
    _loadWidget();
    super.initState();
  }

  _loadWidget() async {
    await LoaderWidget.load(widget.type, widget.name,
        baseUrl: widget.baseUrl,
        subFolder: widget.subFolder,
        riveAssetLoader: widget.riveAssetLoader);
    if (mounted) {
      _result = _getResult();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: widget.width, height: widget.height, child: _result);

  Widget? _getResult() {
    var loader =
        LoaderWidget.cachedLoaders["${widget.type.name}_${widget.name}"]!;

    if (loader.bytes == null) return null;
    switch (widget.type) {
      case AssetType.animation:
      case AssetType.animationZipped:
        return RiveAnimation.direct(loader.metadata as RiveFile,
            onInit: ((artboard) {
          if (widget.onRiveInit == null) {
            artboard.addController(StateMachineController.fromArtboard(
                artboard, "State Machine 1")!);
          } else {
            widget.onRiveInit?.call(artboard);
          }
        }), fit: widget.fit);
      case AssetType.image:
        if (loader.metadata == null) return null;
        final image =
            Image.memory(loader.metadata as Uint8List, gaplessPlayback: true);
        return image;
      case AssetType.vector:
        return SvgPicture.memory(loader.metadata as Uint8List);
      default:
        return null;
    }
  }

  @override
  void dispose() {
    // _loader.abort();
    super.dispose();
  }
}
