import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_catalog_app/core/errors/exceptions.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.server({int? statusCode}) = ServerFailure;
  const factory Failure.network() = NetworkFailure;
  const factory Failure.timeout() = TimeoutFailure;
  const factory Failure.cancelled() = CancelledFailure;
  const factory Failure.cache() = CacheFailure;
  const factory Failure.unknown() = UnknownFailure;
}

extension AppExceptionToFailure on AppException {
  Failure toFailure() => switch (this) {
        ServerException(:final statusCode) => Failure.server(statusCode: statusCode),
        NetworkException() => const Failure.network(),
        TimeoutException() => const Failure.timeout(),
        CancelledException() => const Failure.cancelled(),
        CacheException() => const Failure.cache(),
      };
}
