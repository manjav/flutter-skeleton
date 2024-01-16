// ignore_for_file: constant_identifier_names
class SkeletonException implements Exception {
  final String message;
  final int statusCode;
  SkeletonException(this.statusCode, this.message);
}
