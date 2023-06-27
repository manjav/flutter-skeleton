import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/services/deviceinfo.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rive/rive.dart';

class Asset {
  static T load<T>(
    String path, {
    BoxFit? fit,
    double? width,
    double? height,
    int? imageCacheWidth,
    int? imageCacheHeight,
    Function(Artboard)? onRiveInit,
    Rect? imageCenterSlice,
    ImageRepeat imageRepeat = ImageRepeat.noRepeat,
  }) {
    var type = _getType(T);
    var address = "assets/${type.name}s/$path.${type.extension}";
    return switch (type) {
      AssetType.animation =>
        RiveAnimation.asset(address, fit: fit, onInit: onRiveInit) as T,
      AssetType.image => Image.asset(
          address,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: imageCacheWidth,
          cacheHeight: imageCacheHeight,
          centerSlice: imageCenterSlice,
        ) as T,
      AssetType.vector => SvgPicture.asset(address,
          width: width, height: height, fit: fit ?? BoxFit.contain) as T,
      _ => null as T
    };
  }

  static AssetType _getType(Type type) {
    return switch (type) {
      RiveAnimation => AssetType.animation,
      Image => AssetType.image,
      DeviceFileSource => AssetType.sound,
      SvgPicture => AssetType.vector,
      _ => AssetType.text
    };
  }
}

enum AssetType {
  animation,
  animationZipped,
  font,
  image,
  sound,
  text,
  vector,
}

extension AssetTypeExtension on AssetType {
  String folder([String staging = '']) {
    switch (this) {
      case AssetType.animation:
      case AssetType.animationZipped:
        return "animations$staging";
      case AssetType.font:
        return "fonts";
      case AssetType.image:
        return "images$staging";
      case AssetType.sound:
        return "sounds";
      case AssetType.text:
        return "text";
      case AssetType.vector:
        return "vectors";
    }
  }

  String get type {
    switch (this) {
      case AssetType.animation:
      case AssetType.animationZipped:
        return "riv";
      case AssetType.font:
        return "ttf";
      case AssetType.image:
        return "webp";
      case AssetType.sound:
        return "mp3";
      case AssetType.text:
        return "json";
      case AssetType.vector:
        return "svg";
    }
  }

  String get extension {
    switch (this) {
      case AssetType.animationZipped:
        return "$type.zip";
      default:
        return type;
    }
  }
}
