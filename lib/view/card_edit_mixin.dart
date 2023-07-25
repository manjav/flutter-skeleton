  innerChromeFactory() {
    return Positioned(
        left: 0,
        right: 0,
        bottom: 32.d,
        top: 580.d,
        child: Asset.load<Image>("ui_popup_bottom",
            centerSlice: ImageCenterSliceDate(
                200, 114, const Rect.fromLTWH(99, 4, 3, 3))));
  }
