// ignore_for_file: constant_identifier_names

enum StatusCode {
  ALREADY_EXISTS(-3),
  NOT_ENOUGH_RESOURCE(-1),
  SUCCESS(0),
  UNAUTHENTICATED(16),
  INVALID_RESTORE_KEY(154),
  UNAUTHORIZED(401),
  FORBIDDEN(403),
  NOT_FOUND(404),
  UNAVAILABLE(503),
  UPDATE_NOTICE(700),
  UPDATE_FORCE(701),
  UPDATE_TEST(702),
  UNKNOWN_ERROR(999);

  final int value;
  const StatusCode(this.value);

  bool get isSuccess => this == StatusCode.SUCCESS;
  bool get isFailure => this != StatusCode.SUCCESS;
}

extension StatusCodeIintExtension on int {
  StatusCode toStatus() {
    for (var r in StatusCode.values) {
      if (this == r.value) return r;
    }
    return StatusCode.UNKNOWN_ERROR;
  }
}

class SkeletonException implements Exception {
  final String message;
  final StatusCode statusCode;
  final dynamic data;
  SkeletonException(this.statusCode, [this.message = "", this.data]);

  @override
  String toString() => "$statusCode: $message";
}
