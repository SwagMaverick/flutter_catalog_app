import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/network/error_interceptor.dart';

@module
abstract class DioClient {
  @lazySingleton
  Dio dio(ErrorInterceptor errorInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(errorInterceptor);
    return dio;
  }
}
