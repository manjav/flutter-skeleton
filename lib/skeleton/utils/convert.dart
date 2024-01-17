class Convert{
  static int toInt(dynamic source, [defaultValue = 0]) {
    var value = source ?? defaultValue;
    if (value is double) return value.round();
    if (value is String) return int.parse(value);
    return value;
  }
}