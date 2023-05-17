class Ads<Type> {
  final Type _data;
  final AdsType _adsType;
  Ads(this._data, this._adsType);
  Type get data => _data;
  AdsType get adsType => _adsType;
}

enum AdsType { online, offline }
