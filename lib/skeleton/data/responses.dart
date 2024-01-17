// ignore_for_file: constant_identifier_names

enum StatusCode {
  C0_SUCCESS,
  C154_INVALID_RESTORE_KEY,
  C403_SERVICE_UNAVAILABLE,
  C503_SERVICE_UNAVAILABLE,
  C700_UPDATE_NOTICE,
  C701_UPDATE_FORCE,
  C702_UPDATE_TEST,
  C901_ENCRYPTION_ERROR,
  C999_UNKNOWN_ERROR,
}

extension StatusCodeintEx on int {
  StatusCode toStatus() {
    for (var r in StatusCode.values) {
      if (this == r.value) return r;
    }
    return StatusCode.C999_UNKNOWN_ERROR;
  }
}

extension StatusCodeExtension on StatusCode {
  int get value {
    return switch (this) {
      StatusCode.C0_SUCCESS => 0,
      StatusCode.C154_INVALID_RESTORE_KEY => 154,
      StatusCode.C403_SERVICE_UNAVAILABLE => 403,
      StatusCode.C503_SERVICE_UNAVAILABLE => 503,
      StatusCode.C700_UPDATE_NOTICE => 700,
      StatusCode.C701_UPDATE_FORCE => 701,
      StatusCode.C702_UPDATE_TEST => 702,
      _ => 999
    };
  }
}

class SkeletonException implements Exception {
  final String message;
  final int statusCode;
  SkeletonException(this.statusCode, this.message);
}
