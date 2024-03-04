import 'dart:convert';

class SkuDetails {
  final String? mItemType;
  final String? mSku;
  final String? mType;
  final String? mPrice;
  final int? mPriceAmountMicros;
  final String? mPriceCurrencyCode;
  final String? mTitle;
  String? mDescription;
  final String? mJson;

  SkuDetails(
    this.mItemType,
    this.mSku,
    this.mType,
    this.mPrice,
    this.mPriceAmountMicros,
    this.mPriceCurrencyCode,
    this.mTitle,
    this.mDescription,
    this.mJson,
  );

  Map<String, dynamic> toMap() {
    return {
      'mItemType': mItemType,
      'mSku': mSku,
      'mType': mType,
      'mPrice': mPrice,
      'mPriceAmountMicros': mPriceAmountMicros,
      'mPriceCurrencyCode': mPriceCurrencyCode,
      'mTitle': mTitle,
      'mDescription': mDescription,
      'mJson': mJson,
    };
  }

  factory SkuDetails.fromMap(Map<String, dynamic> map) {
    return SkuDetails(
      map['mItemType'],
      map['mSku'],
      map['mType'],
      map['mPrice'],
      map['mPriceAmountMicros']?.toInt(),
      map['mPriceCurrencyCode'],
      map['mTitle'],
      map['mDescription'],
      map['mJson'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SkuDetails.fromJson(String source) => SkuDetails.fromMap(json.decode(source));
}
