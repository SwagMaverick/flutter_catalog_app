import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/errors/exceptions.dart';

@injectable
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        const TimeoutException(),
      DioExceptionType.cancel => const CancelledException(),
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse =>
        ServerException(statusCode: err.response?.statusCode),
      _ => err.error is SocketException
          ? const NetworkException()
          : const ServerException(),
    };
    handler.reject(err.copyWith(error: exception));
  }
}
