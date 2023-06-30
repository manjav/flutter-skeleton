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
  final double? width;
  final double? height;
  final String? baseUrl;
  final Function(dynamic)? onLoad;

  const LoaderWidget(this.type, this.name,
      {this.width, this.height, this.onLoad, this.baseUrl, Key? key})
      : super(key: key);

  @override
  createState() => _LoaderWidgetState();
}

class _LoaderWidgetState extends State<LoaderWidget> {
  final _loader = Loader();
  String _loadedPath = "";
  Widget? _result;

  @override
  Widget build(BuildContext context) {
    _load();
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _result,
    );
  }

  void _load() {
    var url =
        widget.baseUrl ?? "${LoaderWidget.baseURL}/${widget.type.folder()}";
    var netPath = "${widget.name}.${widget.type.extension}";
    var path = "${widget.name}.${widget.type.type}";
    if (_loader.path != path) {
      _loader.load(path, '$url/$netPath', hash: LoaderWidget.hashMap[path],
          onDone: (file) {
        if (mounted) {
          _result = _getResult();
          setState(() {});
        }
      }, forceUpdate: false);
    }
  }

  Widget? _getResult() {
    if (_loadedPath == _loader.path) return _result;
    if (_loader.bytes == null) return null;
    _loadedPath = _loader.path;

    switch (widget.type) {
      case AssetType.animation:
      case AssetType.animationZipped:
        return RiveAnimation.file(_loader.file!.path,
            onInit: ((p0) => widget.onLoad?.call(p0)), fit: BoxFit.fitWidth);
      case AssetType.image:
        return Image.memory(Uint8List.fromList(_loader.bytes!));
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
